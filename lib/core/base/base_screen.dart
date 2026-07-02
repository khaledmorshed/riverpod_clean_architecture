import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_state.dart';
import 'base_notifier.dart';

abstract class BaseScreen<T extends BaseState> extends ConsumerWidget {
  const BaseScreen({Key? key}) : super(key: key);

  /// Subclasses must provide the provider to watch/listen to.
  dynamic get provider;

  Widget body(BuildContext context, WidgetRef ref);

  PreferredSizeWidget? appBar(BuildContext context, WidgetRef ref) => null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenToState(context, ref);
    final state = ref.watch(provider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          annotatedRegion(context, ref),
          if (state.isLoading) _showLoading(),
        ],
      ),
    );
  }

  void _listenToState(BuildContext context, WidgetRef ref) {
    ref.listen<T>(provider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        showErrorSnackBar(context, next.errorMessage!);
      }
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        showSuccessSnackBar(context, next.successMessage!);
      }
    });
  }

  Widget annotatedRegion(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor(),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Material(
        color: Colors.transparent,
        child: pageScaffold(context, ref),
      ),
    );
  }

  Widget pageScaffold(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: pageBackgroundColor(),
      appBar: appBar(context, ref),
      floatingActionButton: floatingActionButton(context, ref),
      body: pageContent(context, ref),
      bottomNavigationBar: bottomNavigationBar(context, ref),
      drawer: drawer(context, ref),
    );
  }

  Widget pageContent(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: body(context, ref),
    );
  }

  void showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  Color pageBackgroundColor() {
    return Colors.white; 
  }

  Color statusBarColor() {
    return Colors.white;
  }

  Widget? floatingActionButton(BuildContext context, WidgetRef ref) {
    return null;
  }

  Widget? bottomNavigationBar(BuildContext context, WidgetRef ref) {
    return null;
  }

  Widget? drawer(BuildContext context, WidgetRef ref) {
    return null;
  }

  Widget _showLoading() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
