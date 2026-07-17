import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/base/base_stateful_screen.dart';
import '../providers/tenant_provider.dart';

class InstallationScreen extends BaseStatefulScreen<TenantState> {
  const InstallationScreen({super.key});

  @override
  BaseScreenState<InstallationScreen, TenantState> createState() => _InstallationScreenState();
}

class _InstallationScreenState extends BaseScreenState<InstallationScreen, TenantState> {
  late final TextEditingController _domainController;

  @override
  void initState() {
    super.initState();
    _domainController = TextEditingController();
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  @override
  dynamic get provider => tenantNotifierProvider;

  @override
  bool get isLoading => ref.watch(tenantNotifierProvider.select((s) => s.isLoading));

  @override
  Widget body(BuildContext context) {
    final domainError = ref.watch(tenantNotifierProvider.select((s) => s.domainError));
    final isFormValid = ref.watch(tenantNotifierProvider.select((s) => s.isFormValid));
    final isLoading = ref.watch(tenantNotifierProvider.select((s) => s.isLoading));

    final notifier = ref.read(tenantNotifierProvider.notifier);

    ref.listen<TenantState>(tenantNotifierProvider, (previous, current) {
      if (current.tenant != null && previous?.tenant == null) {
        context.goNamed(AppRoutes.login);
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withValues(alpha: 0.95),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.settings_suggest,
                        size: 64,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Store Verification',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your store URL to verify your configuration.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Store URL field
                      TextField(
                        controller: _domainController,
                        onChanged: notifier.updateDomain,
                        decoration: InputDecoration(
                          labelText: 'Store URL',
                          hintText: 'e.g. mystore.example.com',
                          errorText: domainError,
                          prefixIcon: const Icon(Icons.domain, color: Colors.indigo),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Verify Button
                      ElevatedButton(
                        onPressed: (isFormValid && !isLoading)
                            ? () => notifier.verifyDomain()
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
                          'Verify Store',
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
