import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../domain/usecases/create_client.dart';
import '../../domain/usecases/get_clients.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../../../core/base/base_state.dart';
import '../../../../core/base/base_notifier.dart';

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

// Client List State & Notifier
class ClientListState extends BaseState {
  final List<Client> clients;
  final int page;
  final String searchQuery;
  final bool isPaging;

  const ClientListState({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    this.clients = const [],
    this.page = 1,
    this.searchQuery = '',
    this.isPaging = false,
  });

  @override
  ClientListState copyWithBase({
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

  ClientListState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<Client>? clients,
    int? page,
    String? searchQuery,
    bool? isPaging,
  }) {
    return ClientListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      clients: clients ?? this.clients,
      page: page ?? this.page,
      searchQuery: searchQuery ?? this.searchQuery,
      isPaging: isPaging ?? this.isPaging,
    );
  }
}

class ClientListNotifier extends BaseNotifier<ClientListState> {
  @override
  ClientListState build() {
    Future.microtask(() => fetchClients(refresh: true));
    return ClientListState();
  }

  Future<void> fetchClients({bool refresh = false}) async {
    if (state.isLoading || state.isPaging) return;

    final targetPage = refresh ? 1 : state.page;
    if (!refresh) {
      state = state.copyWith(isPaging: true);
    }

    final getClients = ref.read(getClientsUseCaseProvider);
    
    await executeTask(
      getClients(GetClientsParams(page: targetPage, search: state.searchQuery)),
      showLoading: refresh,
      onSuccess: (newClients) {
        state = state.copyWith(
          clients: refresh ? newClients : [...state.clients, ...newClients],
          page: refresh ? 2 : state.page + 1,
          isPaging: false,
        );
      },
      onError: (_) {
        state = state.copyWith(isPaging: false);
      }
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    fetchClients(refresh: true);
  }
}

final clientListProvider = NotifierProvider<ClientListNotifier, ClientListState>(
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
