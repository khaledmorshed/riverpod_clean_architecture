import 'base_state.dart';

class PaginatedState<T> extends BaseState {
  final List<T> items;
  final int page;
  final String searchQuery;
  final bool isPaging;

  const PaginatedState({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    this.items = const [],
    this.page = 1,
    this.searchQuery = '',
    this.isPaging = false,
  });

  @override
  PaginatedState<T> copyWithBase({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return copyWith(
      isLoading: isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  PaginatedState<T> copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<T>? items,
    int? page,
    String? searchQuery,
    bool? isPaging,
  }) {
    return PaginatedState<T>(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      items: items ?? this.items,
      page: page ?? this.page,
      searchQuery: searchQuery ?? this.searchQuery,
      isPaging: isPaging ?? this.isPaging,
    );
  }
}
