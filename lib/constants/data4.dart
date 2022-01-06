import 'package:geolocator/geolocator.dart';
import 'package:map_elevation/map_elevation.dart';

double startLatPoint = 0; //127.13573328; //0;
double startLngPoint = 0; //37.41896772; //0;
Position? myLocation;
List<List<double>> raw = [];

List<ElevationPoint> getPoints() {
  return raw.map((e) => ElevationPoint(e[1], e[0], e[2])).toList();
}
