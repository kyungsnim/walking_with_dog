import 'package:walking_with_dog/models/geometry.dart';

class Place {
  final Geometry geometry;
  final String name;
  final String address;

  Place({required this.geometry,required this.name,required this.address});

  factory Place.fromJson(Map<String,dynamic> json){
    return Place(
        geometry:  Geometry.fromJson(json['geometry']),
        name: json['name'],
        address: json['formatted_address'],
    );
  }
}