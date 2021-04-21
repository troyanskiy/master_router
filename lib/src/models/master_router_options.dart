part of '../main.dart';

class MasterRouterOptions {
  final bool asSingleton;
  final GlobalKey<NavigatorState>? navigatorKey;

  const MasterRouterOptions({
    this.asSingleton = true,
    this.navigatorKey,
  });
}
