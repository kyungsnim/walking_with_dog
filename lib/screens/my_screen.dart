import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walking_with_dog/models/my_pet_model.dart';
import 'package:walking_with_dog/screens/register_pet_info_screen.dart';
import 'package:walking_with_dog/widgets/loading_indicator.dart';

import 'edit_my_pet_info_screen.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  String _imagePath = '';
  File? _imageFile;
  List<MyPetModel> _myPetList = [
    MyPetModel('뭉치', '20200101', '5', '포메라니안', '남', ''),
    MyPetModel('덤보', '20210205', '5.1', '포메라니안', '여', ''),
    MyPetModel('우동', '20200607', '4.2', '포메라니안', '남', ''),
    MyPetModel('하양', '20201212', '6.2', '포메라니안', '여', '')
  ];
  int savedPetDataLength = 0;
  int petCurrentIndex = 0;
  List<List<String>> savedPetData = [];

  @override
  initState() {
    super.initState();

    getPetInfo();
  }

  getPetInfo() {
    setState(() {
      savedPetData = [];
    });

    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getInt('petCount') != null) {
        savedPetDataLength = prefs.getInt('petCount')!;
        petCurrentIndex = prefs.getInt('petCurrentIndex')!;

        int i = 0;

        /// 저장된 반려견 정보 불러오기 : 중간중간 삭제한 정보가 있을 수 있으므로 하나 가져올 때마다 count
        while (i < savedPetDataLength) {
          /// 모든 DB 정보 넣어주기

          if(prefs.getStringList('savedPetData${i}') != null) {
            List<String> tmp = prefs.getStringList('savedPetData${i++}')!;
            setState(() {
              savedPetData.add(tmp);
            });
          } else {
            i++;
          }

          /// currentIndex 일 때 별도로 넣어주기
        }
        for (int i = 0; i < savedPetDataLength-1; i++) {
          print(savedPetData[i][0]);
          print(savedPetData[i][1]);
          print(savedPetData[i][2]);
          print(savedPetData[i][3]);
          print(savedPetData[i][4]);
          print(savedPetData[i][5]);
          print(savedPetData[i][6]);
          print(savedPetData[i][7]);

        }
        // for(int i = 0; i < 6; i++){
        //   print(savedPetData[1][i]);
        // }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              SizedBox(
                height: Get.height * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  savedPetData.isEmpty || savedPetData[petCurrentIndex][0].isEmpty
                          ? // _imageFile == null ?
                          needRegisterProfilePhoto()
                          : myProfilePhoto()
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  headArea(),
                  Divider(),
                  myPetAreaList(),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.clear();

                  setState(() {
                    savedPetData = [];
                  });
                },
                child: Text('DB초기화'),
              ),
            ],
          ),
        ));
  }

  needRegisterProfilePhoto() {
    return Container(
      alignment: Alignment.center,
      height: 150,
      width: 150,
      child: const Text(
        'No Image',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200), color: Colors.grey),
    );
  }

  myProfilePhoto() {
    return InkWell(
      onTap: () => getGalleryImage(),
      child: SizedBox(
        height: 150.0,
        width: 150.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: savedPetData[petCurrentIndex][0] == '' ? Container(
            alignment: Alignment.center,
            height: 150,
            width: 150,
            child: const Text(
              'No Image',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200), color: Colors.grey),
          ) : Image.file(
            File(savedPetData[petCurrentIndex][1]),

            /// savedPetData[index][1] => index 를 currentIndex 등으로 저장해둬야 함
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Future getGalleryImage() async {
    // List<XFile>? pickedFileList = await ImagePicker().pickMultiImage();
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    String imageId = DateTime.now().millisecondsSinceEpoch.toString();
    final directory = await getApplicationDocumentsDirectory();
    File _image = await File('${directory.path}/image_$imageId.png').create();

    /// 임시폴더가 아닌 AppDocument폴더에 저장
    pickedFile!.saveTo(_image.path);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('imagePath', _image.path);

      /// image picker XFile to make file
      _imageFile = File(_image.path);
    });
  }

  headArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.asset(
                'assets/icon/foot.png',
                width: 25,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('반려견',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Get.width * 0.06,
                  )),
            ),
            Spacer(),
            InkWell(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                int petCount = prefs.getInt('petCount')!;
                print('petCount : $petCount');

                int i = 0;
                int cnt = 0;
                while(cnt < petCount) {
                  if(prefs.getStringList('savedPetData$i') != null) {
                    List<String> tmp = prefs.getStringList('savedPetData$i')!;

                    print('index : ${tmp[0]}');
                    print('image : ${tmp[1]}');
                    print('name : ${tmp[2]}');
                    cnt++;
                  }
                  i++;
                }


                // for (int i = 0; i < petCount; i++) {
                //   print(prefs.getStringList('savedPetData$i')![0]);
                //
                //   /// 프로필 이미지
                //   print(prefs.getStringList('savedPetData$i')![1]);
                //
                //   /// 이름
                //   print(prefs.getStringList('savedPetData$i')![2]);
                //
                //   /// 생년월
                //   print(prefs.getStringList('savedPetData$i')![3]);
                //
                //   /// 몸무게
                //   print(prefs.getStringList('savedPetData$i')![4]);
                //
                //   /// 품종
                //   print(prefs.getStringList('savedPetData$i')![5]);
                //
                //   /// 성별
                //   print(prefs.getStringList('savedPetData$i')![6]);
                //
                //   /// 중성화 여부
                // }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'DB확인',
                  style: TextStyle(
                      fontSize: Get.width * 0.05, color: Colors.blueAccent),
                ),
              ),
            ),
            InkWell(
              onTap: () => Get.to(() => EditMyPetInfoScreen())!.then(
                (_) {
                  getPetInfo();
                },
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '추가',
                  style: TextStyle(
                      fontSize: Get.width * 0.05, color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  myPetAreaList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: savedPetData.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            setState(() {
              petCurrentIndex = index;
              prefs.setInt('petCurrentIndex', petCurrentIndex);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Text(
                          savedPetData[index][2],
                          style: TextStyle(fontSize: Get.width * 0.06),
                        ),
                        petCurrentIndex == index ? const SizedBox(width: 10) : const SizedBox(),
                        petCurrentIndex == index
                            ? Icon(
                          Icons.check,
                          color: Colors.blueAccent,
                          size: Get.width * 0.05,
                        )
                            : const SizedBox(),
                      ],
                    )),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () => Get.to(
                      () => EditMyPetInfoScreen(
                        index: int.parse(savedPetData[index][0]),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '정보 변경하기',
                        style: TextStyle(
                            fontSize: Get.width * 0.035, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: index == 0 ? SizedBox() : InkWell(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        prefs.remove('savedPetData$petCurrentIndex');
                        savedPetData.removeAt(index);
                        petCurrentIndex = 0;
                        prefs.setInt('petCurrentIndex', 0);
                        prefs.setInt('petCount', prefs.getInt('petCount')! - 1);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '삭제',
                        style: TextStyle(
                            fontSize: Get.width * 0.035, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
