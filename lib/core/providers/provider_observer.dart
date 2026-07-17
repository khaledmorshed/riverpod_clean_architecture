import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

base class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (kDebugMode) {
      final providerName = context.provider.name ?? context.provider.runtimeType;
      developer.log(
        'Provider $providerName updated (State type: ${newValue?.runtimeType})',
        name: 'RIVERPOD',
      );
    }
  }

  @override
  void didAddProvider(
    ProviderObserverContext context,
    Object? value,
  ) {
    if (kDebugMode) {
      final providerName = context.provider.name ?? context.provider.runtimeType;
      developer.log(
        'Provider $providerName added',
        name: 'RIVERPOD',
      );
    }
  }

  @override
  void didDisposeProvider(
    ProviderObserverContext context,
  ) {
    if (kDebugMode) {
      final providerName = context.provider.name ?? context.provider.runtimeType;
      developer.log(
        'Provider $providerName disposed',
        name: 'RIVERPOD',
      );
    }
  }
}
