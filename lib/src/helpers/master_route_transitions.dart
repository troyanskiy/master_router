part of '../main.dart';

enum MasterRouteTransition {
  Default,
  Fade,
  SlideUp,
  SlideBack,
  None,
}

///
/// Fade transition
///
Widget _fadeTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

///
/// Slide up transition
///
Widget _slideUpTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

///
/// Slide up transition
///
Widget _slideBackTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

///
/// Slide up transition
///
Widget _noneTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return child;
}
