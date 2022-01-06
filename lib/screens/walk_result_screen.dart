import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walking_with_dog/constants/constants.dart';
import 'package:walking_with_dog/constants/data4.dart';
import 'package:screenshot/screenshot.dart';

import 'history_screen.dart';
import 'home_screen.dart';

class WalkResultScreen extends StatefulWidget {
  int? totalHours;
  int? totalMinutes;
  int? totalSeconds;
  double? totalDistance;

  WalkResultScreen(this.totalHours, this.totalMinutes, this.totalSeconds,
      this.totalDistance);

  @override
  _WalkResultScreenState createState() => _WalkResultScreenState();
}

class _WalkResultScreenState extends State<WalkResultScreen> {
  ElevationPoint? hoverPoint;
  Uint8List? _imageFile;
  String? saveDataTotalHours;
  String? saveDataTotalMinutes;
  String? saveDataTotalSeconds;
  String? saveDataTotalDistance;

  //Create an instance of ScreenshotController
  ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300), () {
      checkMapSize(context);
    });
    return Scaffold(
      body: Screenshot(
        controller: _screenshotController,
        child: Stack(children: [
          /// 산책경로 위젯
          FlutterMap(
            options: MapOptions(
              center: LatLng(startLatPoint, startLngPoint),
              zoom: 16.0,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                retinaMode: true,
              ),
              PolylineLayerOptions(
                // Will only render visible polylines, increasing performance
                polylines: [
                  Polyline(
                    // An optional tag to distinguish polylines in callback
                    points: getPoints(),
                    color: kPrimaryFirstColor,
                    strokeWidth: 10.0,
                  ),
                ],
              ),
              MarkerLayerOptions(markers: [
                if (hoverPoint is LatLng)
                  Marker(
                      point: hoverPoint!,
                      width: 8,
                      height: 8,
                      builder: (BuildContext context) => Container(
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8)),
                          ))
              ]),
            ],
          ),

          /// 하단 산책시간/거리 위젯
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                alignment: Alignment.center,
                width: Get.width * 0.95,
                height: Get.height * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white70,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
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
                                  widget.totalHours! > 0
                                      ? Text(
                                          '${widget.totalHours}:',
                                          style: TextStyle(
                                            fontSize: Get.width * 0.08,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : const SizedBox(),
                                  Text(
                                    widget.totalMinutes! < 10
                                        ? '0${widget.totalMinutes}'
                                        : '${widget.totalMinutes}',
                                    style: TextStyle(
                                      fontSize: Get.width * 0.08,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.totalSeconds! < 10
                                        ? ':0${widget.totalSeconds}'
                                        : ':${widget.totalSeconds}',
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
                                '${widget.totalDistance!.toStringAsFixed(2)}km',
                                style: TextStyle(
                                  fontSize: Get.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () => saveCurrentScreen(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              // border: Border.all(
                              //   color: Colors.blueAccent,
                              // ),
                              color: kPrimaryFirstColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    size: Get.width * 0.08,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '산책기록 남기기',
                                    style: TextStyle(
                                      fontSize: Get.width * 0.05,
                                      // color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// 뒤로가기
          // Positioned(
          //   top: Get.height * 0.1,
          //   left: Get.width * 0.08,
          //   child: InkWell(
          //     onTap: () => Get.back(),
          //     child: Container(
          //       width: Get.width * 0.2,
          //       height: Get.width * 0.2,
          //       alignment: Alignment.center,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(50),
          //         color: Colors.grey,
          //       ),
          //       child: const Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Icon(
          //           Icons.arrow_back_ios,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          /// 뒤로가기
          // Positioned(
          //   top: Get.height * 0.1,
          //   right: Get.width * 0.08,
          //   child: InkWell(
          //     onTap: () async {
          //       SharedPreferences prefs = await SharedPreferences.getInstance();
          //
          //       print(prefs.getInt('count'));
          //
          //       for (int i = 0; i < 2; i++) {
          //         print(prefs.getStringList('saveData2')![0]);
          //         print(prefs.getStringList('saveData2')![1]);
          //         print(prefs.getStringList('saveData2')![2]);
          //       }
          //     },
          //     child: Container(
          //       width: Get.width * 0.2,
          //       height: Get.width * 0.2,
          //       alignment: Alignment.center,
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(50),
          //         color: Colors.grey,
          //       ),
          //       child: const Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Icon(
          //           Icons.arrow_back_ios,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ]),
      ),
    );
  }

  checkMapSize(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('산책경로 확인'),
            content: const Text('산책경로가 지도에 담기도록 사이즈를 조절하신 후 산책기록을 저장하세요.'),
            actions: [
              TextButton(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text('확인',
                      style: TextStyle(color: Colors.grey, fontSize: 20)),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  saveCurrentScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _screenshotController
        .capture(delay: const Duration(milliseconds: 1000))
        .then((Uint8List? image) async {
      if (image != null) {
        String imageId = DateTime.now().millisecondsSinceEpoch.toString();
        final directory = await getApplicationDocumentsDirectory();
        // final directory = Directory('/storage/emulated/0/DCIM');
        File imagePath =
            await File('${directory.path}/image_$imageId.png').create();

        String saveImagePath = '';
        await imagePath.writeAsBytes(image).then((_) {
          int num = 0;

          // /// 갤러리에 이미지 저장
          // GallerySaver.saveImage(imagePath.path).then((value) {
          //   print('>>>> save value= $value');
          //   saveImagePath =
          //       '/storage/emulated/0/DCIM/Recent/image_$imageId.png';
          // }).catchError((err) {
          //   print('error :( $err');
          // });

          if (prefs.getInt('count') == null) {
            prefs.setInt('count', 0);
            num = 0;
          } else {
            num = prefs.getInt('count')!;
          }

          /// 로컬DB에 저장하기
          prefs.setStringList('saveData$num', [
            '${widget.totalHours}:${widget.totalMinutes! < 10 ? '0' + widget.totalMinutes.toString() : widget.totalMinutes}:${widget.totalSeconds! < 10 ? '0' + widget.totalSeconds.toString() : widget.totalSeconds}',
            widget.totalDistance!.toStringAsFixed(2),
            imagePath.path,
            // saveImagePath,
            DateTime.now().toString().substring(0, 16)
          ]);

          prefs.setInt('count', ++num);

          Get.back();
          Get.snackbar('산책기록 저장', '저장이 완료되었습니다.');
        });

        /// Share Plugin
        // await Share.shareFiles([imagePath.path]);
      }
    });
  }
}
