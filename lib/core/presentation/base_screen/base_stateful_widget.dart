import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseStatefulWidget extends ConsumerStatefulWidget {
  const BaseStatefulWidget({super.key});
}

abstract class BaseState<T extends BaseStatefulWidget> extends ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    onInit();
  }

  /// Override this method in child classes if needed for post-init or initial state setup.
  void onInit() {}
}
