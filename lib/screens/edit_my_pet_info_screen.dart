import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walking_with_dog/models/my_pet_model.dart';

class EditMyPetInfoScreen extends StatefulWidget {
  int? index;

  EditMyPetInfoScreen({this.index, Key? key}) : super(key: key);

  @override
  _EditMyPetInfoScreenState createState() => _EditMyPetInfoScreenState();
}

class _EditMyPetInfoScreenState extends State<EditMyPetInfoScreen> {
  String _imagePath = '';
  File? _imageFile;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _birthController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _kindController = TextEditingController();
  TextEditingController _sexController = TextEditingController();
  final _sexList = [
    '남아',
    '여아',
  ];
  bool _completeReutering = false;

  @override
  void initState() {
    super.initState();
    // _nameController
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            _myPetInfo(),
            // test(),
          ],
        ));
  }

  _myPetInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: ListView(
        children: [
          SizedBox(height: Get.height * 0.08),
          Text(
            '나의 반려견을 등록해주세요',
            style: TextStyle(
              fontSize: Get.width * 0.065,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _imagePath.isEmpty ? needRegisterProfilePhoto() : myProfilePhoto()
            ],
          ),
          SizedBox(
            height: Get.height * 0.05,
          ),
          textField('반려동물 이름 (예정)', '한글이름 최대 8자 이내', _nameController),
          SizedBox(
            height: Get.height * 0.02,
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: textField(
                    '반려동물 생년월 (MMMMDD)', 'ex) 201911', _birthController),
              ),
              SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: textField('반려동물 몸무게', 'ex) 0.0', _weightController),
              ),
              Text(
                'kg',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: Get.height * 0.02,
          ),
          textField('반려동물 품종', '품종을 작성해주세요', _kindController),
          SizedBox(
            height: Get.height * 0.02,
          ),
          dropField('성별을 클릭해주세요'),
          checkReutering(),
          SizedBox(
            height: Get.height * 0.04,
          ),
          confirmButton(),
          SizedBox(
            height: Get.height * 0.2,
          ),
        ],
      ),
    );
  }

  textField(String label, String hint, TextEditingController controller) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12,
        ),
        hintText: hint,
      ),
      controller: controller,
    );
  }

  dropField(String label) {
    return TextField(
      readOnly: true,
      controller: _sexController,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 12,
        ),
        suffixIcon: PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: (String value) {
            _sexController.text = value;
          },
          itemBuilder: (BuildContext context) {
            return _sexList
                .map<PopupMenuItem<String>>((String value) {
              return PopupMenuItem(
                  child: Text(value), value: value);
            }).toList();
          },
        ),
      ),
    );
  }

  confirmButton() {
    return InkWell(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int num = 0;
        int petIndex = 0;

        if (prefs.getInt('petCount') == null) {
          prefs.setInt('petCount', 0);
          prefs.setInt('petIndex', 0);
          num = 0;
        } else {
          num = prefs.getInt('petCount')!;
          petIndex = prefs.getInt('petIndex')!;
        }

        /// 로컬DB에 저장하기
        prefs.setStringList('savedPetData$num', [
          _imagePath,
          _nameController.text,
          _birthController.text,
          _weightController.text,
          _kindController.text,
          _sexController.text,
          _completeReutering.toString(),
          ]);

        prefs.setInt('petCount', ++num);
        prefs.setInt('petIndex', ++petIndex);

        Get.back();
        Get.snackbar('반려견 등록', '등록이 완료되었습니다.');
      },
      child: Container(
        alignment: Alignment.center,
        height: Get.height * 0.06,
        width: Get.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.blueAccent,
        ),
        child: Text(
          '완료',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: Get.width * 0.05,
          ),
        ),
      ),
    );
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
          child: Image.file(
            File(_imagePath),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Future getGalleryImage() async {
    // List<XFile>? pickedFileList = await ImagePicker().pickMultiImage();
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    // final tempDir = await getTemporaryDirectory();
    // final path = tempDir.path;
    // int rand = new Math.Random().nextInt(10000);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String imageId = DateTime.now().millisecondsSinceEpoch.toString();
    final directory = await getApplicationDocumentsDirectory();
    // File _image =
    // await File('${directory.path}/image_$imageId.png').create();
    File('${directory.path}/image_$imageId.png').create().then((_image) {
      /// 임시폴더가 아닌 AppDocument폴더에 저장
      pickedFile!.saveTo(_image.path);

      setState(() {
        _imagePath = _image.path;
        // prefs.setString('imagePath}', _imagePath);
      });
    });
  }

  checkReutering() {
    return Row(
      children: <Widget>[
        Checkbox(
          activeColor: Colors.blueAccent,
          value: _completeReutering,
          onChanged: (newValue) {
            setState(() {
              _completeReutering = newValue!;
            });
          },
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
          child: Text(
            '중성화 했어요!',
          ),
        ),
      ],
    );
  }
}
