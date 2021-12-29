import 'package:map_elevation/map_elevation.dart';

double startLatPoint = 0;
double startLngPoint = 0;
List<List<double>> raw = [];

List<ElevationPoint> getPoints() {
  return raw.map((e) => ElevationPoint(e[1], e[0], e[2])).toList();
}
