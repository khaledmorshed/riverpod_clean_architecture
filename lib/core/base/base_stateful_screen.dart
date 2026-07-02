import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_state.dart';

abstract class BaseStatefulScreen<T extends BaseState> extends ConsumerStatefulWidget {
  const BaseStatefulScreen({super.key});
}

abstract class BaseScreenState<W extends BaseStatefulScreen<T>, T extends BaseState> extends ConsumerState<W> {
  
  /// Subclasses must provide the provider to watch/listen to.
  dynamic get provider;

  Widget body(BuildContext context);

  PreferredSizeWidget? appBar(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    _listenToState(context);
    final state = ref.watch(provider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          annotatedRegion(context),
          if (state.isLoading) _showLoading(),
        ],
      ),
    );
  }

  void _listenToState(BuildContext context) {
    ref.listen<T>(provider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        showErrorSnackBar(context, next.errorMessage!);
      }
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        showSuccessSnackBar(context, next.successMessage!);
      }
    });
  }

  Widget annotatedRegion(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor(),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Material(
        color: Colors.transparent,
        child: pageScaffold(context),
      ),
    );
  }

  Widget pageScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackgroundColor(),
      appBar: appBar(context),
      floatingActionButton: floatingActionButton(context),
      body: pageContent(context),
      bottomNavigationBar: bottomNavigationBar(context),
      drawer: drawer(context),
    );
  }

  Widget pageContent(BuildContext context) {
    return SafeArea(
      child: body(context),
    );
  }

  void showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  Color pageBackgroundColor() {
    return Colors.white; 
  }

  Color statusBarColor() {
    return Colors.white;
  }

  Widget? floatingActionButton(BuildContext context) {
    return null;
  }

  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }

  Widget? drawer(BuildContext context) {
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
