import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/constants.dart';
import '../providers/client_provider.dart';
import '../../../../core/base/base_stateful_screen.dart';

class CreateClientScreen extends BaseStatefulScreen<CreateClientState> {
  const CreateClientScreen({super.key});

  @override
  BaseScreenState<CreateClientScreen, CreateClientState> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends BaseScreenState<CreateClientScreen, CreateClientState> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _addressController;
  late final TextEditingController _openingBalanceController;
  late final TextEditingController _creditDueLimitController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _addressController = TextEditingController();
    _openingBalanceController = TextEditingController();
    _creditDueLimitController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _openingBalanceController.dispose();
    _creditDueLimitController.dispose();
    super.dispose();
  }

  @override
  dynamic get provider => createClientNotifierProvider;

  @override
  bool get isLoading => ref.watch(createClientNotifierProvider.select((s) => s.isLoading));

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Add New Client',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: Colors.indigo,
      elevation: 0,
    );
  }

  @override
  Widget body(BuildContext context) {
    final firstNameError = ref.watch(createClientNotifierProvider.select((s) => s.firstNameError));
    final mobileError = ref.watch(createClientNotifierProvider.select((s) => s.mobileError));
    final partyTypeId = ref.watch(createClientNotifierProvider.select((s) => s.partyTypeId));
    final isFormValid = ref.watch(createClientNotifierProvider.select((s) => s.isFormValid));
    final isLoading = ref.watch(createClientNotifierProvider.select((s) => s.isLoading));

    final notifier = ref.read(createClientNotifierProvider.notifier);

    ref.listen<CreateClientState>(createClientNotifierProvider, (previous, current) {
      if (current.isSuccess && !(previous?.isSuccess ?? false)) {
        ref.invalidate(clientListProvider); // Invalidate list provider to trigger refresh
        context.pop();
      }
    });

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Client Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.indigo,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // First Name
                    TextField(
                      controller: _firstNameController,
                      onChanged: notifier.updateFirstName,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        errorText: firstNameError,
                        prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    TextField(
                      controller: _lastNameController,
                      onChanged: notifier.updateLastName,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mobile Number
                    TextField(
                      controller: _mobileController,
                      onChanged: notifier.updateMobile,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        errorText: mobileError,
                        prefixIcon: const Icon(Icons.phone, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextField(
                      controller: _emailController,
                      onChanged: notifier.updateEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextField(
                      controller: _addressController,
                      onChanged: notifier.updateAddress,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Opening Balance
                    TextField(
                      controller: _openingBalanceController,
                      onChanged: notifier.updateOpeningBalance,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Opening Balance',
                        prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Credit Due Limit
                    TextField(
                      controller: _creditDueLimitController,
                      onChanged: notifier.updateCreditDueLimit,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Credit Due Limit',
                        prefixIcon: const Icon(Icons.credit_card, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Party Type Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: partyTypeId.isEmpty ? null : partyTypeId,
                      decoration: InputDecoration(
                        labelText: 'Party Type',
                        prefixIcon: const Icon(Icons.group, color: Colors.indigo),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: PartyTypeClass.partyTypeList.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['id'],
                          child: Text(type['name'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          notifier.setPartyType(val);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: (isFormValid && !isLoading) ? () => notifier.submitClient() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Client',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
