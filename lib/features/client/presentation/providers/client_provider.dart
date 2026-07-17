import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/client.dart';
import '../../domain/usecases/create_client.dart';
import '../../domain/usecases/get_clients.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../../../core/base/base_state.dart';
import '../../../../core/base/base_notifier.dart';
import '../../../../core/base/paginated_state.dart';
import '../../../../core/base/paginated_notifier.dart';

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
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String address;
  final String openingBalance;
  final String creditDueLimit;
  final String partyTypeId;
  final String? firstNameError;
  final String? mobileError;
  final bool isFormValid;

  const CreateClientState({
    super.isLoading = false,
    super.errorMessage,
    super.successMessage,
    this.isSuccess = false,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.mobile = '',
    this.address = '',
    this.openingBalance = '',
    this.creditDueLimit = '',
    this.partyTypeId = '',
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
    String? firstName,
    String? lastName,
    String? email,
    String? mobile,
    String? address,
    String? openingBalance,
    String? creditDueLimit,
    String? partyTypeId,
    String? firstNameError,
    String? mobileError,
    bool? isFormValid,
  }) {
    return CreateClientState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      openingBalance: openingBalance ?? this.openingBalance,
      creditDueLimit: creditDueLimit ?? this.creditDueLimit,
      partyTypeId: partyTypeId ?? this.partyTypeId,
      firstNameError: firstNameError ?? this.firstNameError,
      mobileError: mobileError ?? this.mobileError,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

class CreateClientNotifier extends BaseNotifier<CreateClientState> {
  @override
  CreateClientState build() {
    return const CreateClientState();
  }

  void updateFirstName(String val) {
    state = state.copyWith(firstName: val);
    _validateForm();
  }

  void updateLastName(String val) {
    state = state.copyWith(lastName: val);
  }

  void updateEmail(String val) {
    state = state.copyWith(email: val);
  }

  void updateMobile(String val) {
    state = state.copyWith(mobile: val);
    _validateForm();
  }

  void updateAddress(String val) {
    state = state.copyWith(address: val);
  }

  void updateOpeningBalance(String val) {
    state = state.copyWith(openingBalance: val);
  }

  void updateCreditDueLimit(String val) {
    state = state.copyWith(creditDueLimit: val);
  }

  void setPartyType(String id) {
    state = state.copyWith(partyTypeId: id);
    _validateForm();
  }

  void _validateForm() {
    final firstName = state.firstName.trim();
    final mobile = state.mobile.trim();

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
      isFormValid: firstNameErr == null && mobileErr == null && state.partyTypeId.isNotEmpty && firstName.isNotEmpty && mobile.isNotEmpty,
    );
  }

  Future<void> submitClient() async {
    if (!state.isFormValid) return;

    state = state.copyWith(isSuccess: false);

    final params = CreateClientParams(
      firstName: state.firstName,
      lastName: state.lastName,
      email: state.email,
      phone: state.mobile,
      address: state.address,
      openingBalance: state.openingBalance,
      creditDueLimit: state.creditDueLimit,
      partyTypeId: state.partyTypeId,
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
