Here is a detailed, complete, step-by-step example for both solutions, including all widgets, providers, and lifecycles.

Solution 1: State-Driven Sync (Recommended)
This approach keeps business logic in the Notifier (which can be unit-tested in pure Dart) and UI lifecycles in the Widgets.

The Flow of Data
[User Types Name] -> TextFormField onChanged -> calls notifier.updateName()
                                                       |
                                               Computes Discount Rule
                                                       |
[UI Input Field] <- ref.listen updates Controller <- Emits New State (State.discount)
Complete Code Implementation
1. The State & Provider Configuration
dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// The State represents only the PURE data. No UI controllers here!
class CreateClientState {
  final String name;
  final String discount;
  const CreateClientState({
    required this.name,
    required this.discount,
  });
  CreateClientState copyWith({
    String? name,
    String? discount,
  }) {
    return CreateClientState(
      name: name ?? this.name,
      discount: discount ?? this.discount,
    );
  }
}
// The Notifier contains the business rules. This is 100% testable in pure Dart tests.
class CreateClientNotifier extends AutoDisposeNotifier<CreateClientState> {
  @override
  CreateClientState build() {
    return const CreateClientState(name: '', discount: '');
  }
  void updateName(String name) {
    // Business Rule: If name starts with 's' or 'S', discount is 10%. Otherwise, empty.
    final String discount = (name.startsWith('s') || name.startsWith('S')) ? '10' : '';
    
    state = state.copyWith(
      name: name,
      discount: discount,
    );
  }
  void updateDiscount(String discount) {
    state = state.copyWith(discount: discount);
  }
  void submit() {
    print("Submitting to DB: ${state.name} with ${state.discount}% discount");
  }
}
// Provider definition
final createClientNotifierProvider = NotifierProvider.autoDispose<CreateClientNotifier, CreateClientState>(
  CreateClientNotifier.new,
);
2. The Main Screen (Parent Widget)
The parent screen instantiates the text controllers, manages their disposal, and passes them to the child widgets.

dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class CreateClientScreen extends ConsumerStatefulWidget {
  const CreateClientScreen({super.key});
  @override
  ConsumerState<CreateClientScreen> createState() => _CreateClientScreenState();
}
class _CreateClientScreenState extends ConsumerState<CreateClientScreen> {
  // 1. Instantiated locally inside the UI State
  late final TextEditingController _nameController;
  late final TextEditingController _discountController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _discountController = TextEditingController();
  }
  @override
  void dispose() {
    // 2. Disposed cleanly when leaving the screen
    _nameController.dispose();
    _discountController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 3. Pass controllers down to components
            ClientPersonalInfoWidget(nameController: _nameController),
            const SizedBox(height: 16),
            ClientDiscountWidget(discountController: _discountController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(createClientNotifierProvider.notifier).submit();
              },
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}
3. Child Widget: Personal Info Widget
This widget updates the Notifier whenever the user types in the Name field.

dart
class ClientPersonalInfoWidget extends ConsumerWidget {
  final TextEditingController nameController;
  const ClientPersonalInfoWidget({super.key, required this.nameController});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      controller: nameController,
      onChanged: (val) {
        // Send updates back to the notifier to evaluate business rules
        ref.read(createClientNotifierProvider.notifier).updateName(val);
      },
      decoration: const InputDecoration(
        labelText: 'Client Name',
        border: OutlineInputBorder(),
      ),
    );
  }
}
4. Child Widget: Discount Widget (The State Listener)
This widget uses ref.listen to observe state updates from the notifier and updates its input field text automatically.

dart
class ClientDiscountWidget extends ConsumerWidget {
  final TextEditingController discountController;
  const ClientDiscountWidget({super.key, required this.discountController});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to state updates from Riverpod
    ref.listen<CreateClientState>(createClientNotifierProvider, (previous, next) {
      final stateDiscount = next.discount;
      
      // 2. Update controller text only if it differs to prevent infinite loops 
      // or cursor jumping while typing.
      if (discountController.text != stateDiscount) {
        discountController.text = stateDiscount;
      }
    });
    return TextFormField(
      controller: discountController,
      onChanged: (val) {
        // Allow the user to manually override the discount
        ref.read(createClientNotifierProvider.notifier).updateDiscount(val);
      },
      decoration: const InputDecoration(
        labelText: 'Automatic Discount (%)',
        border: OutlineInputBorder(),
      ),
    );
  }
}
