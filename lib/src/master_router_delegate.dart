part of 'main.dart';

class MasterRouterDelegate extends RouterDelegate<MasterRouteConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<MasterRouteConfig> {
  MasterRouterDelegate(this._masterRouter);

  MasterRouter _masterRouter;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _masterRouter.navigatorKey;

  List<MasterRouteConfig> _routeConfigs = [];

  @override
  Widget build(BuildContext context) {
    if (_routeConfigs.isEmpty) {
      return Container();
    }

    return Navigator(
      key: navigatorKey,
      pages: _routeConfigs.map((e) => e.getPage(context)).toList(),
      onPopPage: (route, result) {
        if (_routeConfigs.length < 2 || !route.didPop(result)) {
          return false;
        }

        _routeConfigs.last._popCompleter.complete(result);

        _routeConfigs.removeLast();

        notifyListeners();

        return true;
      },
    );
  }

  MasterRouteConfig? get currentConfiguration =>
      _routeConfigs.isEmpty ? null : _routeConfigs.last;

  // Future<bool> popRoute() async {
  //   print('popRoute');
  //   if (_masterRouter.canPop()) {
  //     return true;
  //   }
  //
  //   return false;
  // }

  Future<void> push(MasterRouteConfig configuration) async {
    _routeConfigs.add(configuration);
    notifyListeners();
  }

  @override
  Future<void> setInitialRoutePath(MasterRouteConfig configuration) {
    MasterRouteConfig? parentConfig = configuration.createParentRouteConfig();

    while (parentConfig != null) {
      _routeConfigs.insert(0, parentConfig);
      parentConfig = parentConfig.createParentRouteConfig();
    }

    return super.setInitialRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(MasterRouteConfig configuration) async {
    final locationIndex = _routeConfigs.indexWhere(
      (config) => config.location == configuration.location,
    );

    if (locationIndex == -1) {
      _routeConfigs.add(configuration);
    } else {
      _routeConfigs = _routeConfigs.sublist(0, locationIndex + 1);
    }

  }
}
