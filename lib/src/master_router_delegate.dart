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
      pages: _routeConfigs.map((e) => e.page).toList(),
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


  Future<void> push(
    MasterRouteConfig configuration, {
    bool removeBelow = false,
    int? removeLast,
  }) async {
    if (removeBelow) {
      _routeConfigs.forEach((c) => c._popCompleter.complete(null));
      _routeConfigs.clear();
    } else if (removeLast != null) {
      int removeLastCount = removeLast;
      while (removeLastCount-- > 0) {
        _routeConfigs.last._popCompleter.complete(null);
        _routeConfigs.removeLast();
      }
    }

    _routeConfigs.add(configuration);

    notifyListeners();
  }

  void removeRange(
    int startIndex,
    int endIndex, {
    bool notify = true,
  }) {
    if (endIndex < 0) {
      endIndex += _routeConfigs.length;
    }

    if (startIndex >= endIndex) {
      return;
    }

    for (int i = startIndex; i < endIndex; i++) {
      _routeConfigs[i]._popCompleter.complete(null);
    }
    _routeConfigs.removeRange(startIndex, endIndex);

    if (notify) {
      notifyListeners();
    }
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
