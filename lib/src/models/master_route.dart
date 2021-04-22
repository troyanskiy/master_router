part of '../main.dart';

typedef MasterRouteWidgetBuilder = Widget Function(
  BuildContext context,
  MasterRouteParamsAbstract? params,
);

typedef MasterRoutePageRouteBuilder = Route Function(
  BuildContext context,
  RouteSettings settings,
  WidgetBuilder widgetBuilder,
);

typedef MasterRouteParamsBuilder<T extends MasterRouteParamsAbstract?> = T
    Function(
  Map<String, String> pathParams,
  Map<String, String> queryParams,
);

class MasterRoute {
  final MasterRouteParamsBuilder? paramsBuilder;
  final MasterRoutePageRouteBuilder? pageRouteBuilder;
  final MasterRouteWidgetBuilder builder;
  final MasterRouteTransition transition;
  final Duration? transitionDuration;
  final bool? fullscreenDialog;

  final List<MasterRoute>? subRoutes;

  MasterRoute? parentRoute;

  bool get isAny => _isAny;

  late bool _isAny;

  late String _name;
  late String _path;

  late List<_RouteSegment> _routeSegments;

  String get path => _path;

  String get name => _name;

  MasterRoute({
    required String path,
    required this.builder,
    this.pageRouteBuilder,
    this.paramsBuilder,
    this.transition = MasterRouteTransition.Default,
    this.transitionDuration,
    this.fullscreenDialog,
    this.subRoutes,
    String? name,
  }) {
    _path = path;

    _isAny = path == '**';

    _name = name ?? path;
  }

  ///
  /// Init route with parent route
  /// Called from master router
  ///
  void _initWithParent(MasterRoute? route) {
    parentRoute = route;

    final pathNotWithRoot = !_path.startsWith('/');

    if (pathNotWithRoot) {
      if (route == null) {
        _path = '/' + _path;
      } else {
        _path = route.path + '/' + _path;
      }
    }

    if (!_isAny) {
      final uri = Uri(path: path);

      _routeSegments = uri.pathSegments
          .map((urlSegment) => _RouteSegment.fromString(urlSegment))
          .where((routeSegment) => routeSegment.isNotEmpty)
          .toList(growable: false);
    }
  }

  ///
  /// Get route config
  ///
  MasterRouteConfig? _tryGetRouteConfig(Uri? uri) {
    if (isAny) {
      return MasterRouteConfig(
        route: this,
      );
    }

    if (uri == null || _routeSegments.length != uri.pathSegments.length) {
      return null;
    }

    Map<String, String> pathParams = {};

    for (int i = 0; i < _routeSegments.length; i++) {
      final routeSegment = _routeSegments[i];
      final testPathSegment = uri.pathSegments[i];

      if (!routeSegment.match(testPathSegment)) {
        return null;
      }

      if (routeSegment.isParam) {
        pathParams[routeSegment.name] = testPathSegment;
      }
    }

    return MasterRouteConfig(
      route: this,
      params: paramsBuilder?.call(pathParams, uri.queryParameters),
    );
  }

  ///
  /// Get route name
  ///
  String _getRouteLocation(MasterRouteParamsAbstract? params) {
    final queryParams = params?.getQueryParams() ?? {};
    final pathParams = params?.getPathParams() ?? {};

    return Uri(
      pathSegments: _routeSegments.map((routeSegment) {
        if (routeSegment.isParam) {
          final paramValue = pathParams[routeSegment.name];

          if (paramValue == null) {
            throw MasterRoutePathParamMissingException(
              path: _path,
              pathParam: routeSegment.name,
            );
          }

          if (!routeSegment.match(paramValue)) {
            throw MasterRoutePathParamDoesNotMatchException(
              path: _path,
              pathParam: routeSegment.name,
              paramValue: paramValue,
            );
          }

          return paramValue;
        }

        return routeSegment.name;
      }),
      queryParameters: queryParams.isEmpty ? null : queryParams,
    ).toString();
  }
}

///
/// MasterRoutePathParamDoesNotMatchException
///
class MasterRoutePathParamDoesNotMatchException implements Exception {
  final String? path;
  final String? pathParam;
  final String? paramValue;

  const MasterRoutePathParamDoesNotMatchException({
    this.path,
    this.pathParam,
    this.paramValue,
  });
}

///
/// MasterRoutePathParamMissingException
///
class MasterRoutePathParamMissingException implements Exception {
  final String? path;
  final String? pathParam;

  const MasterRoutePathParamMissingException({
    this.path,
    this.pathParam,
  });
}

///
/// Route Segment helper
///
class _RouteSegment {
  final bool isParam;
  final String name;
  final Set<String>? possibleValues;

  _RouteSegment({
    required this.isParam,
    required this.name,
    this.possibleValues,
  });

  factory _RouteSegment.fromString(String urlSegment) {
    final isParam = urlSegment.startsWith(':');
    Set<String>? possibleValues;
    String name;

    if (isParam) {
      List<String> parsedName = urlSegment.substring(1).split('=');
      name = parsedName.first;

      if (parsedName.length == 2) {
        possibleValues = Set.of(parsedName.last.split('|'));
      }
    } else {
      name = urlSegment;
    }

    return _RouteSegment(
      isParam: isParam,
      name: name,
      possibleValues: possibleValues,
    );
  }

  ///
  /// If that segment is empty
  ///
  bool get isEmpty => name.isEmpty;

  ///
  /// If that segment is empty
  ///
  bool get isNotEmpty => name.isNotEmpty;

  ///
  /// Does it match test segment
  ///
  bool match(String test) {
    if (isParam) {
      return possibleValues?.contains(test) ?? true;
    }

    return name == test;
  }
}
