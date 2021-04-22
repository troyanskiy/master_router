part of '../main.dart';

class MasterRouteConfig<T extends Object?> {
  final MasterRoute route;
  final MasterRouteParamsAbstract? params;

  final _popCompleter = Completer<T?>();

  Widget? _childWidget;
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
  /// Get or create material page
  ///
  Page get page => _MasterRouterPage<T>(config: this);

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
      parentParams = parentRoute.paramsBuilder
          ?.call(params!.getPathParams(), params!.getQueryParams());
    }

    return MasterRouteConfig(
      route: parentRoute,
      params: parentParams,
    );
  }

  Widget getChildWidget(BuildContext context) {
    _childWidget ??= route.builder(context, params);

    return _childWidget!;
  }
}

class _MasterRouterPage<T extends Object?> extends Page {
  final MasterRouteConfig config;

  _MasterRouterPage({
    required this.config,
  }) : super(
    key: ValueKey(config),
    name: config.route.name,
    arguments: config.params,
  );

  @override
  Route createRoute(BuildContext context) {

    if (config.route.pageRouteBuilder != null) {
      return config.route.pageRouteBuilder!(
        context,
        this,
        config.getChildWidget
      );
    }

    final transition = config.route.transition;

    if (transition == MasterRouteTransition.Default) {
      return MaterialPageRoute<T>(
        settings: this,
        fullscreenDialog: config.route.fullscreenDialog ?? false,
        builder: config.getChildWidget,
      );
    }

    RouteTransitionsBuilder? transitionsBuilder;

    switch (transition) {
      case MasterRouteTransition.Fade:
        transitionsBuilder = _fadeTransitionBuilder;
        break;

      case MasterRouteTransition.SlideUp:
        transitionsBuilder = _slideUpTransitionBuilder;
        break;

      case MasterRouteTransition.SlideBack:
        transitionsBuilder = _slideBackTransitionBuilder;
        break;

      case MasterRouteTransition.None:
        transitionsBuilder = _noneTransitionBuilder;
        break;
    }

    final Duration? transitionDuration = transitionsBuilder == null ||
        transitionsBuilder == _noneTransitionBuilder
        ? Duration.zero
        : config.route.transitionDuration;

    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, _, __) => config.getChildWidget(context),
      transitionDuration:
      transitionDuration ?? const Duration(milliseconds: 250),
      transitionsBuilder: transitionsBuilder ?? _noneTransitionBuilder,
    );
  }
}
