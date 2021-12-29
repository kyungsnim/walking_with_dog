import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walking_with_dog/models/my_pet_model.dart';
import 'package:walking_with_dog/screens/register_pet_info_screen.dart';

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
  List<List<String>> savedPetData = [];

  @override
  initState() {
    super.initState();
    getImagePath();

    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getInt('petCount') != null) {
        savedPetDataLength = prefs.getInt('petCount')!;

        int i = 0;

        /// 저장된 반려견 정보 불러오기 : 중간중간 삭제한 정보가 있을 수 있으므로 하나 가져올 때마다 count
        while (i < savedPetDataLength) {
          print('savedPetData$i');
          List<String> tmp = prefs.getStringList('savedPetData${i++}')!;
          tmp.add(prefs.getInt('petIndex')!.toString());

          setState(() {
            savedPetData.add(tmp);
          });
        }
      }
    });
  }

  getImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('imagePath') != null) {
      setState(() {
        _imagePath = prefs.getString('imagePath')!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        SizedBox(
          height: Get.height * 0.1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null ? needRegisterProfilePhoto() : myProfilePhoto()
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
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.clear();
          },
          child: Text('DB초기화'),
        ),
      ],
    ));
  }

  needRegisterProfilePhoto() {
    return InkWell(
      onTap: () => getGalleryImage(),
      child: Container(
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
      ),
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
          child: Image.asset(
            _imagePath,
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

                print(prefs.getInt('petCount'));
                print(prefs.getStringList('savePetData0')![0]);
                print(prefs.getStringList('savePetData0')![1]);
                print(prefs.getStringList('savePetData0')![2]);
                print(prefs.getStringList('savePetData0')![3]);
                print(prefs.getStringList('savePetData0')![4]);
                print(prefs.getStringList('savePetData0')![5]);
                print(prefs.getStringList('savePetData0')![6]);

                print(prefs.getStringList('savePetData1')![0]);
                print(prefs.getStringList('savePetData1')![1]);
                print(prefs.getStringList('savePetData1')![2]);
                print(prefs.getStringList('savePetData1')![3]);
                print(prefs.getStringList('savePetData1')![4]);
                print(prefs.getStringList('savePetData1')![5]);
                print(prefs.getStringList('savePetData1')![6]);
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
              onTap: () => Get.to(
                () => EditMyPetInfoScreen(),
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                  flex: 5,
                  child: Text(
                    savedPetData[index][1],
                    style: TextStyle(fontSize: Get.width * 0.06),
                  )),
              Flexible(
                flex: 3,
                child: InkWell(
                  onTap: () => Get.to(
                    () => EditMyPetInfoScreen(
                      index: int.parse(savedPetData[index][0]),
                    ),
                  ),
                  child: Text(
                    '정보 변경하기',
                    style: TextStyle(
                        fontSize: Get.width * 0.05, color: Colors.grey),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () => setState(
                    () => _myPetList.removeAt(index),
                  ),
                  child: Text(
                    '삭제',
                    style: TextStyle(
                        fontSize: Get.width * 0.05, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
