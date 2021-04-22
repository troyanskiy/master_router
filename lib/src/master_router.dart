part of 'main.dart';

// typedef MasterRouteConfigPredicate = bool Function(MasterRouteConfig config);

class MasterRouter {
  static MasterRouter? _instance;

  MasterRouter._({
    required this.options,
  }) {
    _navigatorKey = options.navigatorKey ?? GlobalKey<NavigatorState>();
    _masterRouterDelegate = MasterRouterDelegate(this);
    _masterRouteInformationParser = MasterRouteInformationParser(this);
  }

  factory MasterRouter({
    MasterRouterOptions options = const MasterRouterOptions(),
  }) {
    if (options.asSingleton) {
      return _instance ??= MasterRouter._(options: options);
    } else {
      return MasterRouter._(options: options);
    }
  }

  final MasterRouterOptions options;

  late GlobalKey<NavigatorState> _navigatorKey;

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  List<MasterRoute> _routes = [];
  Map<String, MasterRoute> _routesMapNamed = {};

  NavigatorState get navigator => _navigatorKey.currentState!;

  late MasterRouteInformationParser _masterRouteInformationParser;

  MasterRouteInformationParser get routeInformationParser =>
      _masterRouteInformationParser;

  late MasterRouterDelegate _masterRouterDelegate;

  MasterRouterDelegate get routerDelegate => _masterRouterDelegate;

  ///
  /// Add route
  ///
  void addRoute(
    MasterRoute route, {
    MasterRoute? parentRoute,
  }) {
    route._initWithParent(parentRoute);

    if (_routesMapNamed.containsKey(route.name)) {
      throw Exception('Route with the same name exists ${route.name}');
    }

    final existingRouteIndex = _routes.indexWhere((r) => r.path == route.path);

    _routesMapNamed[route.name] = route;

    if (existingRouteIndex == -1) {
      _routes.add(route);
    } else {
      print('!!! Route ${route.path} exists and will be replaced with new !!!');
      _routes[existingRouteIndex] = route;
    }

    if (route.subRoutes != null) {
      this.addRoutes(route.subRoutes!, parentRoute: route);
    }
  }

  ///
  /// Add routes
  ///
  void addRoutes(
    List<MasterRoute> routes, {
    MasterRoute? parentRoute,
  }) =>
      routes.forEach((route) => addRoute(route, parentRoute: parentRoute));

  ///
  /// Can Pop
  ///
  bool canPop() => navigator.canPop();

  ///
  /// Pop
  ///
  void pop<T extends Object?>([T? result]) => navigator.pop<T>(result);

  ///
  /// Maybe Pop
  ///
  void maybePop<T extends Object?>([T? result]) =>
      navigator.maybePop<T>(result);

  ///
  /// Pop Until
  ///
  void popUntil(RoutePredicate predicate) => navigator.popUntil(predicate);

  ///
  /// Push named
  ///
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    MasterRouteParamsAbstract? arguments,
    bool? removeBelow,
    int? removeLast,
  }) {
    final route = _routesMapNamed[routeName];

    if (route == null) {
      return Future.value();
    }

    final config = MasterRouteConfig<T>(route: route, params: arguments);

    routerDelegate.push(
      config,
      removeBelow: removeBelow ?? false,
      removeLast: removeLast,
    );

    return config._popCompleter.future;
  }

  ///
  /// Push Named And Remove Until
  ///
  Future<T?> popUntilAndPushNamed<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    MasterRouteParamsAbstract? arguments,
  }) {
    popUntil(predicate);
    return pushNamed(newRouteName, arguments: arguments);
  }

  ///
  /// Pop And Push Named
  ///
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    MasterRouteParamsAbstract? arguments,
  }) {
    pop(result);
    return pushNamed(routeName, arguments: arguments);
  }

  ///
  /// Get route config
  ///
  MasterRouteConfig? _getMasterRouteByLocation(String? location) {
    Uri? uri;

    if (location != null) {
      while (location!.length > 1 && location.endsWith('/')) {
        location = location.substring(0, location.length - 1);
      }

      uri = Uri.tryParse(location);
    }

    for (final route in _routes) {
      final routeConfig = route._tryGetRouteConfig(uri);

      if (routeConfig != null) {
        return routeConfig;
      }
    }
  }

  ///
  /// Route factory
  ///
// Route<dynamic>? onGenerateRoute(RouteSettings settings) {
//   for (final route in _routes) {
//     final routeWidget = route._getRoute(settings);
//
//     if (routeWidget != null) {
//       return routeWidget;
//     }
//   }
// }
}
