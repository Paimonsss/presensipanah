import 'package:flutter/material.dart';

/// Route ringan dengan fade transition — hemat CPU/GPU dibanding
/// MaterialPageRoute yang pakai slide animation berat.
class LightweightRoute<T> extends PageRouteBuilder<T> {
  LightweightRoute({
    required WidgetBuilder builder,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            );
          },
        );
}

/// Helper functions untuk navigasi ringan
void lightPush(BuildContext context, Widget page) {
  Navigator.push(
    context,
    LightweightRoute(builder: (_) => page),
  );
}

void lightPushReplacement(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    LightweightRoute(builder: (_) => page),
  );
}

void lightPushAndRemoveAll(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(
    context,
    LightweightRoute(builder: (_) => page),
    (route) => false,
  );
}
