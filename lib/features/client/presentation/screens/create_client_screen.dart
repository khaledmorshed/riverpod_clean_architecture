import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../providers/client_provider.dart';
import '../../../../core/base/base_screen.dart';

class CreateClientScreen extends BaseScreen<CreateClientState> {
  const CreateClientScreen({super.key});

  @override
  dynamic get provider => createClientNotifierProvider;

  @override
  PreferredSizeWidget? appBar(BuildContext context, WidgetRef ref) {
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
  Widget body(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createClientNotifierProvider);
    final notifier = ref.read(createClientNotifierProvider.notifier);

    ref.listen<CreateClientState>(createClientNotifierProvider, (previous, current) {
      if (current.isSuccess && !(previous?.isSuccess ?? false)) {
        ref.invalidate(clientListProvider); // Invalidate list provider to trigger refresh
        Navigator.pop(context);
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.95),
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
                        controller: notifier.firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          errorText: state.firstNameError,
                          prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      TextField(
                        controller: notifier.lastNameController,
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
                        controller: notifier.mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          errorText: state.mobileError,
                          prefixIcon: const Icon(Icons.phone, color: Colors.indigo),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextField(
                        controller: notifier.emailController,
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
                        controller: notifier.addressController,
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
                        controller: notifier.openingBalanceController,
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
                        controller: notifier.creditDueLimitController,
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
                        value: notifier.partyTypeId.isEmpty ? null : notifier.partyTypeId,
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
                        onPressed: (state.isFormValid && !state.isLoading)
                            ? () => notifier.submitClient()
                            : null,
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
      );
  }
}
