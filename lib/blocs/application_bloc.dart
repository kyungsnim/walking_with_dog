import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:walking_with_dog/models/geometry.dart';
import 'package:walking_with_dog/models/location.dart';
import 'package:walking_with_dog/models/place.dart';
import 'package:walking_with_dog/models/place_search.dart';
import 'package:walking_with_dog/services/geolocator_service.dart';
import 'package:walking_with_dog/services/marker_service.dart';
import 'package:walking_with_dog/services/places_service.dart';

class ApplicationBloc with ChangeNotifier {
  final geoLocatorService = GeolocatorService();
  final placesService = PlacesService();
  final markerService = MarkerService();

  //Variables
  Position? currentLocation;
  List<PlaceSearch> searchResults = [];
  StreamController<Place> selectedLocation = StreamController<Place>();
  StreamController<LatLngBounds> bounds = StreamController<LatLngBounds>();
  late Place selectedLocationStatic;
  String placeType = '';
  List<Place> placeResults = [];
  List<Marker> markers = [];

  ApplicationBloc() {
    setCurrentLocation();
  }


  setCurrentLocation() async {
    currentLocation = await geoLocatorService.getCurrentLocation();
    selectedLocationStatic = Place(name: '',
      geometry: Geometry(location: Location(
          lat: currentLocation!.latitude, lng: currentLocation!.longitude),), address: '',);
    notifyListeners();
  }

  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }


  setSelectedLocation(String placeId) async {
    var sLocation = await placesService.getPlace(placeId);
    selectedLocation.add(sLocation);
    selectedLocationStatic = sLocation;
    searchResults = [];
    notifyListeners();
  }

  clearSelectedLocation() {
    selectedLocation = StreamController<Place>();
    selectedLocationStatic = Place(name: '',
      geometry: Geometry(location: Location(
          lat: currentLocation!.latitude, lng: currentLocation!.longitude),), address: '',);
    searchResults = [];
    placeType = '';
    notifyListeners();
  }

  togglePlaceType(String value, bool selected) async {
    if (selected) {
      placeType = value;
    } else {
      placeType = '';
    }

    if (placeType != null) {
      // var places = await placesService.getPlaces(
      //     selectedLocationStatic.geometry.location.lat,
      //     selectedLocationStatic.geometry.location.lng, placeType);
      placesService.getPlaces(
          selectedLocationStatic.geometry.location.lat,
          selectedLocationStatic.geometry.location.lng, placeType).then((places) {
        markers= [];
        if (places != null && places.length > 0) {
          var newMarker = markerService.createMarkerFromPlace(places[0],false);
          markers.add(newMarker);
        }

        var locationMarker = markerService.createMarkerFromPlace(selectedLocationStatic,true);
        markers.add(locationMarker);

        var _bounds = markerService.bounds(Set<Marker>.of(markers));
        bounds.add(_bounds);
      });
      notifyListeners();
    }
  }



  @override
  void dispose() {
    selectedLocation.close();
    bounds.close();
    super.dispose();
  }}
