import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';
import 'base_notifier.dart';
import 'paginated_state.dart';

abstract class PaginatedNotifier<T, Params> extends BaseNotifier<PaginatedState<T>> {
  Future<Either<Failure, List<T>>> fetchCall(Params params);
  Params buildParams(int page, String search);

  int _activeRequestId = 0;

  @override
  PaginatedState<T> build() {
    Future.microtask(() => fetchItems(refresh: true));
    return PaginatedState<T>();
  }

  Future<void> fetchItems({bool refresh = false}) async {
    // If it's a regular pagination load (not a refresh) and we are loading, ignore.
    if (!refresh && (state.isLoading || state.isPaging)) return;

    final targetPage = refresh ? 1 : state.page;
    final requestId = ++_activeRequestId;

    if (!refresh) {
      state = state.copyWith(isPaging: true);
    }

    final params = buildParams(targetPage, state.searchQuery);

    await executeTask(
      fetchCall(params),
      showLoading: refresh,
      ignoreConcurrency: refresh, // Overlapping search queries are allowed
      onSuccess: (newItems) {
        // Discard out-of-order responses if a newer request was fired
        if (requestId != _activeRequestId) return;

        state = state.copyWith(
          items: refresh ? newItems : [...state.items, ...newItems],
          page: refresh ? 2 : state.page + 1,
          isPaging: false,
        );
      },
      onError: (_) {
        if (requestId != _activeRequestId) return;
        state = state.copyWith(isPaging: false);
      },
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchItems(refresh: true);
  }
}
