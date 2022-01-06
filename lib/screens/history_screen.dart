import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walking_with_dog/constants/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int saveDataLength = 0;
  List<List<String>> saveData = [];
  double accumulatedDistance = 0;
  int accumulatedTime = 0;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      if(prefs.getInt('count') != null) {
        saveDataLength = prefs.getInt('count')!;

        /// 저장된 산책기록 불러오기
        for (int i = 0; i < saveDataLength; i++) {
          print('saveData$i');
          setState(() {
            saveData.add(prefs.getStringList('saveData$i')!);

            accumulatedTime += transStringToSeconds(saveData[i][0]);
            accumulatedDistance += double.parse(saveData[i][1]);
          });
        }
      }

      print('산책거리 : $accumulatedDistance');
      print('산책시간 : $accumulatedTime');
    });
  }

  /// 산책시간 초로 환산
  int transStringToSeconds(String string) {
    // [0] : hours, [1] : minutes, [2] : seconds
    List<String> splitData = string.split(":");

    int hours = int.parse(splitData[0]);
    int minutes = int.parse(splitData[1]);
    int seconds = int.parse(splitData[2]);

    print('hours: $hours, minutes: $minutes, seconds: $seconds');

    print(hours*3600+minutes*60+seconds);
    return hours*3600+minutes*60+seconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
            width: Get.width,
            height: Get.height,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Text('우리 반려견',
                style: TextStyle(
                  fontSize: Get.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryFirstColor,
                  shadows: [
                    Shadow(offset: Offset(0,0), blurRadius: 5, color: Colors.black.withOpacity(0.4)),
                  ]
                )),
                SizedBox(height: 5),
                Text('누적 거리 : ${accumulatedDistance}km | 누적 시간 : ${(accumulatedTime / 60).truncate()}분 ${accumulatedTime % 60}초',
                    style: TextStyle(
                      fontSize: Get.width * 0.045,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero, /// 상단 여백 없애기
                    shrinkWrap: true,
                    itemCount: saveData.length,
                    itemBuilder: (_, index) {
                  return _buildItem(index);
                    },
                  ),
                )
              ],
            )));
  }

  _buildItem(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
          color: Colors.black12,
          width: Get.width,
          height: Get.height * 0.25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            Text(saveData[index][3], style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),),
                            Spacer(),
                            Text('산책시간', style: TextStyle(
                              color: Colors.black54,
                              fontSize: Get.width * 0.05,
                            )),
                            Text(saveData[index][0], style: TextStyle(
                              fontSize: Get.width * 0.06,
                              fontWeight: FontWeight.bold,
                            )),
                            SizedBox(height: Get.height * 0.035),
                            Text('산책거리', style: TextStyle(
                              color: Colors.black54,
                              fontSize: Get.width * 0.05,
                            )),
                            Text('${saveData[index][1]}km', style: TextStyle(
                              fontSize: Get.width * 0.06,
                              fontWeight: FontWeight.bold,
                            )),
                            Spacer(),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          width: Get.width * 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 10),
                              Expanded(
                                child: InkWell(
                                  onTap: () => getCameraImage(index),
                                  /// 하루 사진 없는 경우
                                  child: saveData[index].length == 4 ? Container(
                                    width: Get.width * 0.5,
                                    alignment: Alignment.center,
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('산책한 하루 사진 남기기', style: TextStyle(
                                          color: kPrimaryFirstColor,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(offset: Offset(0,0), blurRadius: 5, color: Colors.black.withOpacity(0.8)),
                                          ]
                                        )),
                                        const SizedBox(height: 5),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            color: Colors.amber,
                                            boxShadow: const [
                                              BoxShadow(
                                                offset: Offset(1, 1),
                                                blurRadius: 5,
                                              )
                                            ]
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(Icons.camera_alt),
                                          ),
                                        )
                                      ],
                                    )
                                  ) : Image.file(File(saveData[index][4]), fit: BoxFit.fitWidth,),
                                ),
                              ),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  viewWalkHistoryPolyLine(context, index);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: Get.width * 0.5,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey, width: 2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(Icons.photo),
                                            SizedBox(width: 5),
                                            Text('산책 코스 다시보기'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      )
                      // Image.file(File(saveData[index][2]), fit: BoxFit.fill,),
                    ],
                  ),
                ),
              ),
              // const SizedBox(height: 10),
            ],
          )),
    );
  }

  // _buildItem(int index) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Container(
  //         color: Colors.black12,
  //         width: Get.width,
  //         height: Get.height * 0.28,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 4),
  //               child: Text(saveData[index][3], style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //               ),),
  //             ),
  //             Expanded(
  //               flex: 3,
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       flex: 3,
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Text('산책시간', style: TextStyle(
  //                             color: Colors.black54,
  //                             fontSize: Get.width * 0.05,
  //                           )),
  //                           Text(saveData[index][0], style: TextStyle(
  //                             fontSize: Get.width * 0.06,
  //                             fontWeight: FontWeight.bold,
  //                           )),
  //                           const SizedBox(height: 10),
  //                           Text('산책거리', style: TextStyle(
  //                             color: Colors.black54,
  //                             fontSize: Get.width * 0.05,
  //                           )),
  //                           Text('${saveData[index][1]}km', style: TextStyle(
  //                             fontSize: Get.width * 0.06,
  //                             fontWeight: FontWeight.bold,
  //                           )),
  //                         ],
  //                       ),
  //                     ),
  //                     Expanded(
  //                       flex: 5,
  //                       child: InkWell(
  //                         onTap: () => getCameraImage(index),
  //                         /// 하루 사진 없는 경우
  //                         child: saveData[index].length == 4 ? Container(
  //                             width: Get.width * 0.4,
  //                             alignment: Alignment.center,
  //                             color: Colors.grey,
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 const Text('산책한 하루 사진 남기기', style: TextStyle(
  //                                   color: Colors.deepPurple,
  //                                   fontWeight: FontWeight.bold,
  //                                 )),
  //                                 const SizedBox(height: 5),
  //                                 Container(
  //                                   decoration: BoxDecoration(
  //                                       borderRadius: BorderRadius.circular(30),
  //                                       color: Colors.amber,
  //                                       boxShadow: const [
  //                                         BoxShadow(
  //                                           offset: Offset(1, 1),
  //                                           blurRadius: 5,
  //                                         )
  //                                       ]
  //                                   ),
  //                                   child: const Padding(
  //                                     padding: EdgeInsets.all(8.0),
  //                                     child: Icon(Icons.camera_alt),
  //                                   ),
  //                                 )
  //                               ],
  //                             )
  //                         ) : Image.file(File(saveData[index][4]), fit: BoxFit.fitWidth,),
  //                       ),
  //                     )
  //                     // Image.file(File(saveData[index][2]), fit: BoxFit.fill,),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             Flexible(
  //               flex: 1,
  //               child: InkWell(
  //                 onTap: () {
  //                   viewWalkHistoryPolyLine(context, index);
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     children: [
  //                       Container(
  //                         width: Get.width * 0.5,
  //                         decoration: BoxDecoration(
  //                           border: Border.all(color: Colors.grey, width: 2),
  //                         ),
  //                         child: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: const [
  //                               Icon(Icons.photo),
  //                               SizedBox(width: 5),
  //                               Text('산책 코스 다시보기'),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             )
  //           ],
  //         )),
  //   );
  // }

  Future getCameraImage(int index) async {
    // List<XFile>? pickedFileList = await ImagePicker().pickMultiImage();
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    String imageId = DateTime.now().millisecondsSinceEpoch.toString();
    final directory = await getApplicationDocumentsDirectory();
    File _image =
    await File('${directory.path}/image_$imageId.png').create();
    /// 임시폴더가 아닌 AppDocument폴더에 저장
    pickedFile!.saveTo(_image.path);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      print('imagePath : ${_image.path}');
      List<String> tmpData = prefs.getStringList('saveData$index')!;

      /// 이미지 저장 처음인 경우
      if(tmpData.length == 4) {
        tmpData.add(_image.path);
        prefs.setStringList('saveData$index', tmpData);
      } else {
        tmpData.removeAt(4);
        saveData[index].removeAt(4);
        tmpData.add(_image.path);
        prefs.setStringList('saveData$index', tmpData);
      }

      setState(() {
        saveData[index].add(_image.path);
      });
      // /// image picker XFile to make file
      // _imageFile = File(pickedFile.path);
    });
  }

  viewWalkHistoryPolyLine(BuildContext context, int index) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('지난 산책경로'),
            content: Image.file(File(saveData[index][2]), fit: BoxFit.fitWidth,),
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
}
