import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/create_client.dart';
import '../../domain/usecases/get_clients.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../../../core/base/base_state.dart';
import '../../../../core/base/base_notifier.dart';
import '../../../../core/base/paginated_state.dart';
import '../../../../core/base/paginated_notifier.dart';

final clientRemoteDataSourceProvider = Provider<ClientRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ClientRemoteDataSourceImpl(dioClient);
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final remoteDataSource = ref.watch(clientRemoteDataSourceProvider);
  return ClientRepositoryImpl(remoteDataSource);
});

final getClientsUseCaseProvider = Provider<GetClients>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return GetClients(repository);
});

final createClientUseCaseProvider = Provider<CreateClient>((ref) {
  final repository = ref.watch(clientRepositoryProvider);
  return CreateClient(repository);
});

// Client List Notifier using Generic PaginatedNotifier
class ClientListNotifier extends PaginatedNotifier<Client, GetClientsParams> {
  @override
  Future<Either<Failure, List<Client>>> fetchCall(GetClientsParams params) {
    return ref.read(getClientsUseCaseProvider)(params);
  }

  @override
  GetClientsParams buildParams(int page, String search) {
    return GetClientsParams(page: page, search: search);
  }
}

final clientListProvider = NotifierProvider<ClientListNotifier, PaginatedState<Client>>(
  ClientListNotifier.new,
);

// Create Client State & Notifier
class CreateClientState extends BaseState {
  final bool isSuccess;
  final String? firstNameError;
  final String? mobileError;
  final bool isFormValid;

  const CreateClientState({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    this.isSuccess = false,
    this.firstNameError,
    this.mobileError,
    this.isFormValid = false,
  });

  @override
  CreateClientState copyWithBase({
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

  CreateClientState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isSuccess,
    String? firstNameError,
    String? mobileError,
    bool? isFormValid,
  }) {
    return CreateClientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      firstNameError: firstNameError ?? this.firstNameError,
      mobileError: mobileError ?? this.mobileError,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class CreateClientNotifier extends BaseNotifier<CreateClientState> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final openingBalanceController = TextEditingController();
  final creditDueLimitController = TextEditingController();
  String partyTypeId = '';

  @override
  CreateClientState build() {
    firstNameController.addListener(_validateForm);
    mobileController.addListener(_validateForm);

    ref.onDispose(() {
      firstNameController.dispose();
      lastNameController.dispose();
      emailController.dispose();
      mobileController.dispose();
      addressController.dispose();
      openingBalanceController.dispose();
      creditDueLimitController.dispose();
    });

    return CreateClientState();
  }

  void _validateForm() {
    final firstName = firstNameController.text;
    final mobile = mobileController.text;

    String? firstNameErr;
    String? mobileErr;

    if (firstName.isEmpty) {
      firstNameErr = 'First name cannot be empty';
    }
    if (mobile.isEmpty) {
      mobileErr = 'Mobile number cannot be empty';
    }

    state = state.copyWith(
      firstNameError: firstNameErr,
      mobileError: mobileErr,
      isFormValid: firstNameErr == null && mobileErr == null && partyTypeId.isNotEmpty,
    );
  }

  void setPartyType(String id) {
    partyTypeId = id;
    _validateForm();
  }

  Future<void> submitClient() async {
    if (!state.isFormValid) return;

    state = state.copyWith(isSuccess: false);

    final params = CreateClientParams(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: mobileController.text,
      address: addressController.text,
      openingBalance: openingBalanceController.text,
      creditDueLimit: creditDueLimitController.text,
      partyTypeId: partyTypeId,
    );

    final createClient = ref.read(createClientUseCaseProvider);
    
    await executeTask(
      createClient(params),
      onSuccess: (_) {
        state = state.copyWith(isSuccess: true, successMessage: 'Client created successfully!');
      },
    );
  }
}

final createClientNotifierProvider = NotifierProvider.autoDispose<CreateClientNotifier, CreateClientState>(
  CreateClientNotifier.new,
);
