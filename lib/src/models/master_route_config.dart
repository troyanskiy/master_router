part of '../main.dart';

class MasterRouteConfig<T extends Object?> {
  final MasterRoute route;
  final MasterRouteParamsAbstract? params;

  final _popCompleter = Completer<T?>();

  Page? _page;
  String? _location;
  
  String get location {
    _location ??= route._getRouteLocation(params);
    
    return _location!;
  }

  MasterRouteConfig({
    required this.route,
    this.params,
  });

  ///
  /// Create config for parent
  ///
  MasterRouteConfig? createParentRouteConfig() {
    final parentRoute = route.parentRoute;

    if (parentRoute == null) {
      return null;
    }

    MasterRouteParamsAbstract? parentParams;

    if (params != null) {
      parentParams = parentRoute.paramsBuilder?.call(
        params!.getPathParams(),
        params!.getQueryParams()
      );
    }

    return MasterRouteConfig(
      route: parentRoute,
      params: parentParams,
    );
  }

  ///
  /// Get or create material page
  ///
  Page getPage(BuildContext context) {
    _page ??= MaterialPage<T>(
      key: ValueKey(location),
      name: route.name,
      arguments: params,
      fullscreenDialog: route.fullscreenDialog ?? false,
      child: route.builder(context, params),
    );

    return _page!;
  }
}

class _MasterRouterPage extends Page {
  final MasterRouteConfig _masterRouteConfig;

  _MasterRouterPage(this._masterRouteConfig)
      : super(key: ValueKey(_masterRouteConfig));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      fullscreenDialog: _masterRouteConfig.route.fullscreenDialog ?? false,
      builder: (context) {
        return _masterRouteConfig.route.builder(
          context,
          _masterRouteConfig.params,
        );
      },
    );
  }
}
