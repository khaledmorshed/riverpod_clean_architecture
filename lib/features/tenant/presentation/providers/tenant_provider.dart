import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../../domain/usecases/verify_domain.dart';
import '../../data/datasources/tenant_remote_datasource.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../../../core/base/base_state.dart';
import '../../../../core/base/base_notifier.dart';

final tenantRemoteDataSourceProvider = Provider<TenantRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TenantRemoteDataSourceImpl(dioClient);
});

final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  final remoteDataSource = ref.watch(tenantRemoteDataSourceProvider);
  return TenantRepositoryImpl(remoteDataSource);
});

final verifyDomainUseCaseProvider = Provider<VerifyDomain>((ref) {
  final repository = ref.watch(tenantRepositoryProvider);
  return VerifyDomain(repository);
});

class TenantState extends BaseState {
  final Tenant? tenant;
  final String? domainError;
  final bool isFormValid;

  const TenantState({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    this.tenant,
    this.domainError,
    this.isFormValid = false,
  });

  @override
  TenantState copyWithBase({
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

  TenantState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    Tenant? tenant,
    String? domainError,
    bool? isFormValid,
  }) {
    return TenantState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      tenant: tenant ?? this.tenant,
      domainError: domainError ?? this.domainError,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class TenantNotifier extends BaseNotifier<TenantState> {
  final domainController = TextEditingController();

  @override
  TenantState build() {
    domainController.addListener(_validateForm);

    ref.onDispose(() {
      domainController.dispose();
    });

    return TenantState();
  }

  void _validateForm() {
    final domain = domainController.text.trim();
    String? error;

    if (domain.isEmpty) {
      error = 'Store URL cannot be empty';
    } else if (!domain.contains('.')) {
      // Basic check for valid domain
      error = 'Enter a valid store URL';
    }

    state = state.copyWith(
      domainError: error,
      isFormValid: error == null && domain.isNotEmpty,
    );
  }

  Future<void> verifyDomain() async {
    if (!state.isFormValid) return;

    final verifyUseCase = ref.read(verifyDomainUseCaseProvider);

    await executeTask(
      verifyUseCase(domainController.text.trim()),
      onSuccess: (tenantData) {
        ref.read(localStorageProvider).saveTenant(tenantData.domain);
        state = state.copyWith(tenant: tenantData, successMessage: 'Domain verified successfully!');
      },
    );
  }
}

final tenantNotifierProvider = NotifierProvider.autoDispose<TenantNotifier, TenantState>(
  TenantNotifier.new,
);
