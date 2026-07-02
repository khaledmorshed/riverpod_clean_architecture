import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';
import 'base_state.dart';

abstract class BaseNotifier<T extends BaseState> extends Notifier<T> {
  Future<void> executeTask<R>(
    Future<Either<Failure, R>> task, {
    Function(R data)? onSuccess,
    Function(Failure failure)? onError,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      state = state.copyWithBase(
        isLoading: true, 
        errorMessage: null, 
        successMessage: null,
      ) as T;
    }

    final result = await task;

    result.fold(
      (failure) {
        state = state.copyWithBase(
          isLoading: false, 
          errorMessage: failure.message,
        ) as T;
        if (onError != null) onError(failure);
      },
      (data) {
        state = state.copyWithBase(isLoading: false) as T;
        if (onSuccess != null) onSuccess(data);
      },
    );
  }
}
