import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_provider.dart';
import '../../../../core/base/base_stateful_screen.dart';
import '../../../../core/widgets/paging_view.dart';
import 'create_client_screen.dart';

class ClientListScreen extends BaseStatefulScreen<ClientListState> {
  const ClientListScreen({super.key});

  @override
  BaseScreenState<ClientListScreen, ClientListState> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends BaseScreenState<ClientListScreen, ClientListState> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  dynamic get provider => clientListProvider;

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Client Directory',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      backgroundColor: Colors.indigo,
      elevation: 0,
    );
  }

  @override
  Widget? floatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateClientScreen()),
        );
      },
      backgroundColor: Colors.indigo,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Add Client', style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget body(BuildContext context) {
    final state = ref.watch(clientListProvider);
    final notifier = ref.read(clientListProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
          children: [
            // Search Bar Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => notifier.setSearchQuery(val),
                    decoration: const InputDecoration(
                      hintText: 'Search clients by name, phone or email...',
                      prefixIcon: Icon(Icons.search, color: Colors.indigo),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            // Client List
            Expanded(
              child: PagingView(
                onRefresh: () async {
                  ref.read(clientListProvider.notifier).fetchClients(refresh: true);
                },
                onLoadNextPage: () {
                  ref.read(clientListProvider.notifier).fetchClients();
                },
                isLoadingNextPage: state.isPaging,
                child: state.clients.isEmpty && !state.isLoading
                    ? const Center(
                        child: Text(
                          'No clients found.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.clients.length + ((state.isLoading || state.isPaging) ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.clients.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
                              ),
                            );
                          }

                          final client = state.clients[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.indigo.shade100,
                                child: const Icon(Icons.person, size: 28, color: Colors.indigo),
                              ),
                              title: Text(
                                client.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.indigo,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(client.phone, style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          client.address,
                                          style: TextStyle(color: Colors.grey.shade600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Total Due',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${client.totalDue}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      );
  }
}
