import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walking_with_dog/constants/constants.dart';

class Place3Screen extends StatefulWidget {
  @override
  _Place3ScreenState createState() => _Place3ScreenState();
}

class _Place3ScreenState extends State<Place3Screen> {
  GooglePlace? googlePlace;
  List<AutocompletePrediction> predictions = [];
  late Position location;
  @override
  void initState() {
    // String? apiKey = DotEnv().env['API_KEY'];
    googlePlace = GooglePlace(myGoogleApiKey);
    super.initState();
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
      setState(() {
        location = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Search",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black54,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    autoCompleteSearch(value);
                  } else {
                    if (predictions.length > 0 && mounted) {
                      setState(() {
                        predictions = [];
                      });
                    }
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(predictions[index].description!),
                      onTap: () {
                        debugPrint(predictions[index].placeId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(
                              predictions[index].placeId!,
                              googlePlace!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(onTap: () {
                          _launchURL();
                        }, child: renderItem('assets/icon/icon_1.png', '식당'),),
                        renderItem('assets/icon/icon_2.png', '카페'),
                        renderItem('assets/icon/icon_3.png', '유치원'),
                      ],
                    ),
                    SizedBox(height: Get.width * 0.06),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        renderItem('assets/icon/icon_4.png', '병원'),
                        renderItem('assets/icon/icon_5.png', '용품점'),
                        renderItem('assets/icon/icon_6.png', '미용'),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: Image.asset("assets/powered_by_google.png"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL() async {
    String _url = 'https://map.naver.com/v5/search/%EB%B6%84%EB%8B%B9%20%EC%95%A0%EA%B2%AC%20%EC%8B%9D%EB%8B%B9';
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace!.autocomplete.get(value, region: 'locality', language: 'ko_KR', radius: 2000, location: LatLon(location.latitude, location.longitude));
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  renderItem(String path, String name) {
    return Column(
      children: [
        Image.asset(path, width: Get.width * 0.2, height: Get.width * 0.1,),
        SizedBox(height: 3),
        Text(name),
      ],
    );
  }
}

class DetailsPage extends StatefulWidget {
  final String placeId;
  final GooglePlace googlePlace;

  DetailsPage(this.placeId, this.googlePlace);

  @override
  _DetailsPageState createState() =>
      _DetailsPageState(this.placeId, this.googlePlace);
}

class _DetailsPageState extends State<DetailsPage> {
  final String placeId;
  final GooglePlace googlePlace;

  _DetailsPageState(this.placeId, this.googlePlace);

  DetailsResult? detailsResult;
  List<Uint8List> images = [];

  @override
  void initState() {
    getDetils(this.placeId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          getDetils(this.placeId);
        },
        child: Icon(Icons.refresh),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 250,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.memory(
                            images[index],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        child: Text(
                          "Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      detailsResult != null && detailsResult!.types != null
                          ? Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: detailsResult!.types!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Chip(
                                label: Text(
                                  detailsResult!.types![index],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.blueAccent,
                              ),
                            );
                          },
                        ),
                      )
                          : Container(),
                      Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.location_on),
                          ),
                          title: Text(
                            detailsResult != null &&
                                detailsResult!.formattedAddress != null
                                ? '주소: ${detailsResult!.formattedAddress}'
                                : "주소 없음",
                          ),
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(left: 15, top: 10),
                      //   child: ListTile(
                      //     leading: CircleAvatar(
                      //       child: Icon(Icons.location_searching),
                      //     ),
                      //     title: Text(
                      //       detailsResult != null &&
                      //           detailsResult!.geometry != null &&
                      //           detailsResult!.geometry!.location != null
                      //           ? 'Geometry: ${detailsResult!.geometry!.location!.lat.toString()},${detailsResult!.geometry!.location!.lng.toString()}'
                      //           : "Geometry: null",
                      //     ),
                      //   ),
                      // ),
                      Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.timelapse),
                          ),
                          title: Text(
                            detailsResult != null &&
                                detailsResult!.openingHours != null
                                ? '영업 시간: ${detailsResult!.openingHours!.periods![0].open!.time!.substring(0,2)}시 ~ ${detailsResult!.openingHours!.periods![0].close!.time!.substring(0,2)}시'
                                : "영업시간 정보없음",
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15, top: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.rate_review),
                          ),
                          title: Text(
                            detailsResult != null &&
                                detailsResult!.rating != null
                                ? '평점: ${detailsResult!.rating.toString()}'
                                : "평점 없음",
                          ),
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(left: 15, top: 10),
                      //   child: ListTile(
                      //     leading: CircleAvatar(
                      //       child: Icon(Icons.attach_money),
                      //     ),
                      //     title: Text(
                      //       detailsResult != null &&
                      //           detailsResult!.priceLevel != null
                      //           ? 'Price level: ${detailsResult!.priceLevel.toString()}'
                      //           : "Price level: null",
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                child: Image.asset("assets/powered_by_google.png"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getDetils(String placeId) async {
    var result = await this.googlePlace.details.get(placeId, language: 'ko_KR');
    if (result != null && result.result != null && mounted) {
      setState(() {
        detailsResult = result.result;
        images = [];
      });

      if (result.result!.photos != null) {
        for (var photo in result.result!.photos!) {
          getPhoto(photo.photoReference!);
        }
      }
    }
  }

  void getPhoto(String photoReference) async {
    var result = await this.googlePlace.photos.get(photoReference, 400, 400);
    if (result != null && mounted) {
      setState(() {
        images.add(result);
      });
    }
  }
}