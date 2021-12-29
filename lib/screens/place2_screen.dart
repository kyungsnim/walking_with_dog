import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:walking_with_dog/blocs/application_bloc.dart';
import 'package:walking_with_dog/models/place.dart';
import 'package:provider/provider.dart';
import 'package:walking_with_dog/widgets/loading_indicator.dart';

class Place2Screen extends StatefulWidget {
  @override
  _Place2ScreenState createState() => _Place2ScreenState();
}

class _Place2ScreenState extends State<Place2Screen> {
  Completer<GoogleMapController> _mapController = Completer();
  late StreamSubscription locationSubscription;
  // late StreamSubscription boundsSubscription;
  final _locationController = TextEditingController();

  @override
  void initState() {
    final applicationBloc =
    Provider.of<ApplicationBloc>(context, listen: false);

    //Listen for selected Location
    locationSubscription = applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _locationController.text = place.name;
        _goToPlace(place);
      } else
        _locationController.text = "";
    });

    applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
    super.initState();
  }



  @override
  void dispose() {
    // final applicationBloc =
    // Provider.of<ApplicationBloc>(context, listen: false);
    // applicationBloc.dispose();
    if(_locationController != null) {
      _locationController.dispose();
    }
    if(locationSubscription != null) {
      locationSubscription.cancel();
    }
    // if(boundsSubscription != null) {
    //   boundsSubscription.cancel();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
        body: (applicationBloc.currentLocation == null)
            ? loadingIndicator()
            : ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Search by City',
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => applicationBloc.searchPlaces(value),
                onTap: () => applicationBloc.clearSelectedLocation(),
              ),
            ),
            Stack(
              children: [
                applicationBloc.currentLocation == null ? SizedBox() : Container(
                  height: 300.0,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          applicationBloc.currentLocation!.latitude,
                          applicationBloc.currentLocation!.longitude),
                      zoom: 14,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                    },
                    markers: Set<Marker>.of(applicationBloc.markers),
                  ),
                ),
                if (applicationBloc.searchResults != null &&
                    applicationBloc.searchResults.length != 0)
                  Container(
                      height: 300.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.6),
                          backgroundBlendMode: BlendMode.darken)),
                if (applicationBloc.searchResults != null)
                  Container(
                    height: 300.0,
                    child: ListView.builder(
                        itemCount: applicationBloc.searchResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              applicationBloc
                                  .searchResults[index].description,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              applicationBloc.setSelectedLocation(
                                  applicationBloc
                                      .searchResults[index].placeId);
                            },
                          );
                        }),
                  ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('근처',
                  style: TextStyle(
                      fontSize: 25.0, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  FilterChip(
                      label: Text('애견업체'),
                      onSelected: (val) => applicationBloc
                          .togglePlaceType('pet_store', val),
                      selected: applicationBloc.placeType  =='pet_store',
                      selectedColor: Colors.blue),
                  FilterChip(
                    label: Text('캠핑장'),
                    onSelected: (val) => applicationBloc.togglePlaceType(
                        'campground', val),
                    selected:
                    applicationBloc.placeType  =='campground',
                    selectedColor: Colors.blue,
                  ),
                  FilterChip(
                      label: Text('약국'),
                      onSelected: (val) => applicationBloc
                          .togglePlaceType('pharmacy', val),
                      selected:
                      applicationBloc.placeType  =='pharmacy',
                      selectedColor: Colors.blue),
                  FilterChip(
                      label: Text('은행'),
                      onSelected: (val) =>
                          applicationBloc
                              .togglePlaceType('bank', val),
                      selected:
                      applicationBloc.placeType  =='bank',
                      selectedColor: Colors.blue),
                ],
              ),
            )
          ],
        ));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 12.0),
      ),
    );
  }
}
