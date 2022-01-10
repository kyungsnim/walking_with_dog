import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as lc;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:walking_with_dog/constants/constants.dart';
import 'package:walking_with_dog/constants/data4.dart';
import 'package:walking_with_dog/screens/walk_result_screen.dart';
import 'package:walking_with_dog/widgets/loading_indicator.dart';

class WalkScreen extends StatefulWidget {
  const WalkScreen({Key? key}) : super(key: key);

  @override
  _WalkScreenState createState() => _WalkScreenState();
}

class _WalkScreenState extends State<WalkScreen>
    with AutomaticKeepAliveClientMixin {
  /// 산책 시간 관련
  IconData _icon = Icons.play_arrow;
  Color _color = kPrimaryFirstColor;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isPausing = false;
  int _totalHours = 0; // TOTAL TIME HOURS
  int _totalMinutes = 0; // TOTAL TIME MINUTES
  int _totalSeconds = 0; // TOTAL TIME SECONDS
  int _finalHours = 0;
  int _finalMinutes = 0;
  int _finalSeconds = 0;
  String _status = '산책 시작';

  CameraPosition? _initialLocation;
  GoogleMapController? mapController;
  late Position _currentPosition;
  Set<Marker> _markers = {};

  double _totalDistance = 0.0;
  double _finalDistance = 0.0;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  lc.Location location = lc.Location();
  StreamSubscription? _locationSubscription;
  bool? _serviceEnabled;
  lc.PermissionStatus? _permissionGranted;
  lc.LocationData? _oldLocationData;
  lc.LocationData? _newLocationData;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      // Permissions are denied forever, handle appropriately.
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // 시작, 일시정지 버튼
  void _click() {
    _isPlaying = !_isPlaying;

    /// 시작버튼 누른 경우
    if (_isPlaying) {
      _icon = Icons.pause;
      _color = Colors.grey;
      _status = '일시 중지';
      _start();
      setState(() {
        _isPausing = false;
        /// 산책거리 계산 재시작
        _locationSubscription!.resume();
      });
    } else { /// 일시중지버튼 누른 경우
      _icon = Icons.play_arrow;
      _color = kPrimaryFirstColor;
      _status = '산책 시작';
      _pause();
      setState(() {
        _isPausing = true;
        /// 산책거리 계산 중지
        _locationSubscription!.pause();
      });
    }
  }

  _start() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000),
            (timer) {
          setState(() {
            _isPlaying = true;

            /// total time
            _totalSeconds++;
            if (_totalSeconds == 60) {
              _totalSeconds = 0;
              _totalMinutes++;
            }
            if (_totalMinutes == 60) {
              _totalMinutes = 0;
              _totalHours++;
            }
          });
        });
  }

  // 타이머 중지(취소)
  void _pause() {
    _timer?.cancel();
  }

  // 초기화
  void _reset() {
    /// 재생 중 RESET하는 경우
    if (_isPlaying) {
      _pause();
    }
    setState(() {

      _isPlaying = false;
      _isPausing = false;

      _timer?.cancel();
      _locationSubscription!.pause();
      _locationSubscription!.cancel();

      _finalHours = _totalHours;
      _finalMinutes = _totalMinutes;
      _finalSeconds = _totalSeconds;
      _finalDistance = _totalDistance;
      _totalMinutes = 0;
      _totalSeconds = 0;
      _totalHours = 0;
      _totalDistance = 0;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    /// background에도 동작하도록
    _determinePosition().then(((_) {
      location.enableBackgroundMode(enable: true);

      /// 현재 위치 받아와서 초기 카메라위치 설정 및 위치 저
      location.getLocation().then((location) async {
        setState(() {
          _initialLocation = CameraPosition(target: LatLng(location.latitude!, location.longitude!), zoom: 18);
        });

        // _currentPosition = location;
        _newLocationData = location;
        _oldLocationData = location;
      });

    }));

    /// 내 현재 위치 가져오기
    _getCurrentLocation();
  }

  permissionCheckAndSubscription() async {
    /// 위치서비스 사용 가능여부 체크
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    /// 위치 권한여부 체크
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == lc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != lc.PermissionStatus.granted) {
        return;
      }
    }

    /// 위치 구독
    _locationSubscription =
        location.onLocationChanged.listen((lc.LocationData currentLocation) {
          /// 위치 변경시마다 totalDistance에 거리값 더해주기
          if(_isPlaying) {
            _totalDistance += (measureExact(
                _oldLocationData!.latitude, _oldLocationData!.longitude));
            // Use current location
            setState(() {
              print('currentLocation.longitude! : ${currentLocation.longitude!}');
              print('currentLocation.latitude!: ${currentLocation.latitude!}');
              /// 산책경로 추가
              raw.add(
                  [currentLocation.longitude!, currentLocation.latitude!, 200]);

              /// 이전 위치 변경
              _oldLocationData = _newLocationData;

              /// 새로운 위치 변경
              _newLocationData = currentLocation;
              // _calculateDistance(_newLocationData!, _oldLocationData!);

              /// 위치 이동마다 카메라 위치도 이동시켜주기
              mapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                        currentLocation.latitude!, currentLocation.longitude!),
                    zoom: 18.0
                  ),
                ),
              );
            });
          }
        });
  }

  /// 두 구간 거리 계산
  measureExact(lat, lng) {
    // generally used geo measurement function
    var R = 6378.137; // Radius of earth in KM
    var dLat =
        lat * math.pi / 180 - _newLocationData!.latitude! * math.pi / 180;
    var dLon =
        lng * math.pi / 180 - _newLocationData!.longitude! * math.pi / 180;
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_newLocationData!.latitude! * math.pi / 180) *
            math.cos(lat * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = R * c;
    return d; //.toStringAsFixed(2); // meters
  }

  void _updatePosition(CameraPosition _position) async {
    /// 위치 이동될 때마다 puppy 마커도 이동시켜 주기
    var m = _markers.firstWhere((p) => p.markerId == MarkerId('puppy'),
        orElse: () {return const Marker(markerId: MarkerId('null'));});
    _markers.remove(m);
    final Uint8List markerIcon = await getBytesFromAsset('assets/marker.png', 150);
    final Marker marker = Marker(icon: BitmapDescriptor.fromBytes(markerIcon), markerId: const MarkerId('puppy'), position: LatLng(_position.target.latitude, _position.target.longitude));
    _markers.add(marker);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.width;
    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: ListView(
          children: [
            _initialLocation == null ?
            SizedBox(
              width: Get.width,
              height: Get.height * 0.55,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    loadingIndicator(),
                    const SizedBox(height: 10),
                    const Text('현재 위치를 가져오고 있습니다.')
                  ],
                )
              )
            ) :
            Stack(
              children: <Widget>[
                // Map View
                SizedBox(
                  height: Get.height * 0.55,
                  width: Get.width,
                  child: GoogleMap(
                    markers: Set<Marker>.from(_markers),
                    initialCameraPosition: _initialLocation!,
                    // myLocationEnabled: true,
                    // myLocationButtonEnabled: true,
                    mapType: MapType.normal,
                    // zoomGesturesEnabled: true,
                    // zoomControlsEnabled: true,
                    // polylines: Set<Polyline>.of(polylines.values),
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    onCameraMove: ((_position) => _updatePosition(_position)),
                  ),
                ),
                // Show zoom buttons
                // SafeArea(
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 10.0),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: <Widget>[
                //         ClipOval(
                //           child: Material(
                //             color: Colors.grey.shade400, // button color
                //             child: InkWell(
                //               splashColor: Colors.grey, // inkwell color
                //               child: const SizedBox(
                //                 width: 50,
                //                 height: 50,
                //                 child: Icon(Icons.add),
                //               ),
                //               onTap: () {
                //                 mapController!.animateCamera(
                //                   CameraUpdate.zoomIn(),
                //                 );
                //               },
                //             ),
                //           ),
                //         ),
                //         const SizedBox(height: 20),
                //         ClipOval(
                //           child: Material(
                //             color: Colors.grey.shade400, // button color
                //             child: InkWell(
                //               splashColor: Colors.grey, // inkwell color
                //               child: const SizedBox(
                //                 width: 50,
                //                 height: 50,
                //                 child: Icon(Icons.remove),
                //               ),
                //               onTap: () {
                //                 mapController!.animateCamera(
                //                   CameraUpdate.zoomOut(),
                //                 );
                //               },
                //             ),
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '산책시간',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: Get.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _totalHours > 0
                                  ? Text(
                                '$_totalHours:',
                                style: TextStyle(
                                  fontSize: Get.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : const SizedBox(),
                              Text(
                                _totalMinutes < 10
                                    ? '0$_totalMinutes'
                                    : '$_totalMinutes',
                                style: TextStyle(
                                  fontSize: Get.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _totalSeconds < 10
                                    ? ':0$_totalSeconds'
                                    : ':$_totalSeconds',
                                style: TextStyle(
                                  fontSize: Get.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('산책거리',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: Get.width * 0.05,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 10),
                          Text(
                            '${_totalDistance.toStringAsFixed(2)}km',
                            style: TextStyle(
                              fontSize: Get.width * 0.08,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _isPausing ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                      child: Material(
                        child: InkWell(
                          // splashColor: Colors.grey, // inkwell color
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: kPrimaryFirstColor, width: 2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            height: 100,
                            width: 100,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Icon(
                                    _icon,
                                    size: 50,
                                    color: _color,
                                  ),
                                ),
                                Text(
                                  _status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Get.width * 0.045,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {

                            /// 산책 기록 시작
                            permissionCheckAndSubscription().then((_) {
                              _click();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                      child: Material(
                        child: InkWell(
                          splashColor: Colors.grey, // inkwell color
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: Colors.redAccent, width: 2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            height: 100,
                            width: 100,
                            child: Column(
                              children: [
                                const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Icon(
                                    Icons.stop,
                                    size: 50,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                Text(
                                  '산책 종료',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Get.width * 0.045,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
                            /// 산책종료
                            _reset();

                            /// 결과 페이지로 이동
                            Get.to(() => WalkResultScreen(_finalHours, _finalMinutes, _finalSeconds, _finalDistance))!.then((_) {
                              /// 산책경로 초기화
                              setState(() {
                                raw = [];
                              });
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ) : Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: Material(
                    child: InkWell(
                      splashColor: Colors.grey, // inkwell color
                      child: Container(
                        decoration: BoxDecoration(
                          border:
                          Border.all(color: _isPlaying ? Colors.grey : kPrimaryFirstColor, width: 2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        height: 100,
                        width: 100,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: Icon(
                                _icon,
                                size: 50,
                                color: _color,
                              ),
                            ),
                            Text(
                              _status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Get.width * 0.045,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {

                        _getReturnCurrentLocation().then((position) async {

                          /// 시작 지점 저장
                          setState(() {
                            startLatPoint = position.latitude;
                            startLngPoint = position.longitude;
                          });

                          final Uint8List markerIcon = await getBytesFromAsset('assets/marker.png', 150);
                          final Marker marker = Marker(icon: BitmapDescriptor.fromBytes(markerIcon), markerId: const MarkerId('puppy'), position: LatLng(startLatPoint, startLngPoint));
                          _markers.add(marker);
                        });

                        /// 산책 기록 시작
                        permissionCheckAndSubscription().then((_) {
                          ///
                          _click();
                        });
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      setState(() {
        myLocation = position;
        print('CURRENT POS: $_currentPosition');
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });

      // await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the current location
  _getReturnCurrentLocation() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  // Method for retrieving the address

  // _getAddress() async {
  //   try {
  //     // Places are retrieved using the coordinates
  //     List<Placemark> p = await GeocodingPlatform.instance
  //         .placemarkFromCoordinates(
  //         _currentPosition.latitude, _currentPosition.longitude);
  //
  //     // Taking the most probable result
  //     Placemark place = p[0];
  //
  //     setState(() {
  //       // Structuring the address
  //       _currentAddress =
  //       "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
  //
  //       // Update the text of the TextField
  //       startAddressController.text = _currentAddress;
  //
  //       // Setting the user's present location as the starting address
  //       _startAddress = _currentAddress;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  bool get wantKeepAlive => true;
}
