import 'package:flutter/material.dart';
import 'navigation_helper.dart';

class SafeNavigationWrapper extends StatelessWidget {
  final Widget child;
  
  const SafeNavigationWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          NavigationHelper.safePop(context);
        }
      },
      child: child,
    );
  }
}