import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';
import 'base_notifier.dart';
import 'paginated_state.dart';

abstract class PaginatedNotifier<T, Params> extends BaseNotifier<PaginatedState<T>> {
  Future<Either<Failure, List<T>>> fetchCall(Params params);
  Params buildParams(int page, String search);

  @override
  PaginatedState<T> build() {
    Future.microtask(() => fetchItems(refresh: true));
    return PaginatedState<T>();
  }

  Future<void> fetchItems({bool refresh = false}) async {
    if (state.isLoading || state.isPaging) return;

    final targetPage = refresh ? 1 : state.page;
    if (!refresh) {
      state = state.copyWith(isPaging: true);
    }

    final params = buildParams(targetPage, state.searchQuery);

    await executeTask(
      fetchCall(params),
      showLoading: refresh,
      onSuccess: (newItems) {
        state = state.copyWith(
          items: refresh ? newItems : [...state.items, ...newItems],
          page: refresh ? 2 : state.page + 1,
          isPaging: false,
        );
      },
      onError: (_) {
        state = state.copyWith(isPaging: false);
      },
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchItems(refresh: true);
  }
}
