part of 'main.dart';

class MasterRouteInformationParser
    extends RouteInformationParser<MasterRouteConfig> {
  MasterRouter _masterRouter;

  MasterRouteInformationParser(this._masterRouter);

  @override
  Future<MasterRouteConfig> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final config = _masterRouter._getMasterRouteByLocation(
      routeInformation.location,
    );

    if (config == null) {
      throw Exception(
        'Route config not found for ${routeInformation.location}',
      );
    }

    return config;
  }

  @override
  RouteInformation? restoreRouteInformation(MasterRouteConfig configuration) =>
      RouteInformation(location: configuration.location);
}
