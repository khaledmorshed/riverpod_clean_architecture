abstract class BaseState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const BaseState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Abstract method that subclasses must implement to allow the BaseNotifier
  /// to update the generic state properties while preserving subclass specific data.
  BaseState copyWithBase({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  });
}
