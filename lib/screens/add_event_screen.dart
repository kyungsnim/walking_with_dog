import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:get/get.dart';
import 'package:walking_with_dog/constants/constants.dart';
import 'package:walking_with_dog/controller/event_controller.dart';
import 'package:walking_with_dog/controller/image_controller.dart';
import 'package:walking_with_dog/widgets/form_vertical_spacing.dart';
import 'package:walking_with_dog/widgets/primary_button.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  TextStyle style = TextStyle(fontFamily: 'SLEIGothic', fontSize: 20.0);
  EventController noticeController = EventController.to;
  // AuthController authController = AuthController.to;
  String _title = '';
  String _town = '';
  String _description = '';
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool processing = false;

  var _croppedFile;
  DateTime _eventStartDate = DateTime.now();
  DateTime _eventEndDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _title = '';
    _description = '';

    noticeController.titleController.text = '';
    noticeController.descriptionController.text = '';
  }

  @override
  Widget build(BuildContext context) {
      return GetBuilder<EventController>(builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text("새 이벤트 작성", style: TextStyle(color: Colors.black, fontFamily: 'Binggrae', fontSize: Get.width * 0.05, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: _isLoading ? SizedBox() : InkWell(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                )),
          ),
          key: _key,
          body: !_isLoading
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    child: Text('상호명',
                                        style: TextStyle(
                                            fontFamily: 'Binggrae', fontSize: Get.width * 0.05,
                                            fontWeight:
                                            FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 1,
                            height:
                            MediaQuery.of(context).size.height * 0.06,
                            child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(
                                            color: Colors.black54,
                                            width: 0.5))),
                                width:
                                MediaQuery.of(context).size.width * 1,
                                height:
                                MediaQuery.of(context).size.height *
                                    1,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  // expands: true,
                                  controller:
                                  noticeController.titleController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return '상호명을 입력하세요';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '상호명 입력',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Binggrae', fontSize: Get.width * 0.04,),),
                                  onChanged: (val) {
                                    _title = val;
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    child: Text('동',
                                        style: TextStyle(
                                            fontFamily: 'Binggrae', fontSize: Get.width * 0.05,
                                            fontWeight:
                                            FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 1,
                            height:
                            MediaQuery.of(context).size.height * 0.06,
                            child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(
                                            color: Colors.black54,
                                            width: 0.5))),
                                width:
                                MediaQuery.of(context).size.width * 1,
                                height:
                                MediaQuery.of(context).size.height *
                                    1,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: TextFormField(
                                  controller:
                                  noticeController.townController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return '동을 입력하세요';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '동 입력',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Binggrae', fontSize: Get.width * 0.04,),),
                                  onChanged: (val) {
                                    _town = val;
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    child: Text('이벤트 내용',
                                        style: TextStyle(
                                            fontFamily: 'Binggrae',
                                            fontSize: Get.width * 0.05,
                                            fontWeight:
                                            FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 1,
                            height:
                            MediaQuery.of(context).size.height * 0.12,
                            child: Stack(children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(
                                            color: Colors.black54,
                                            width: 0.5))),
                                width:
                                MediaQuery.of(context).size.width * 1,
                                height:
                                MediaQuery.of(context).size.height *
                                    1,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  // expands: true,
                                  controller: noticeController
                                      .descriptionController,
                                  cursorColor: Colors.black,
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return '이벤트 내용을 입력하세요';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '이벤트 내용 입력',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Binggrae', fontSize: Get.width * 0.04,),),
                                  onChanged: (val) {
                                    // noticeController.setDescription();
                                    _description = noticeController
                                        .descriptionController.text;
                                    // setState(() {
                                    //   _content = val;
                                    // });
                                  },
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                    child: Text('이벤트 기간',
                                        style: TextStyle(
                                            fontFamily: 'Binggrae',
                                            fontSize: Get.width * 0.05,
                                            fontWeight:
                                            FontWeight.bold))),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              /// 시작시간
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black38, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                    width: Get.width / 2.2,
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          const Spacer(),
                                          Text(
                                              "${_eventStartDate.year}년 ${_eventStartDate.month}월 ${_eventStartDate.day}일",
                                              style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: Get.width * 0.04)),
                                          const Spacer(),
                                        ],
                                      ),
                                      onTap: () async {
                                        DateTime picked = (await showDatePicker(
                                          context: context,
                                          initialDate: _eventStartDate,
                                          firstDate: DateTime(_eventStartDate.year - 5),
                                          lastDate: DateTime(_eventStartDate.year + 5),
                                          builder: (BuildContext context, Widget? child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                colorScheme: const ColorScheme.light().copyWith(
                                                  primary: kPrimaryFirstColor,
                                                ),
                                                buttonTheme: const ButtonThemeData(
                                                    textTheme: ButtonTextTheme.primary),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        )) ??
                                            _eventStartDate; // cancel 누르면 기존 값 유지
                                        setState(() {
                                          _eventStartDate = picked;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const Text('~'),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black38, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                    width: Get.width / 2.2,
                                    child: ListTile(
                                      title: Row(
                                        children: [
                                          const Spacer(),
                                          Text(
                                              "${_eventEndDate.year}년 ${_eventEndDate.month}월 ${_eventEndDate.day}일",
                                              style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: Get.width * 0.04)),
                                          const Spacer(),
                                        ],
                                      ),
                                      onTap: () async {
                                        DateTime picked = (await showDatePicker(
                                          context: context,
                                          initialDate: _eventEndDate,
                                          firstDate: DateTime(_eventEndDate.year - 5),
                                          lastDate: DateTime(_eventEndDate.year + 5),
                                          builder: (BuildContext context, Widget? child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                colorScheme: const ColorScheme.light().copyWith(
                                                  primary: kPrimaryFirstColor,
                                                ),
                                                buttonTheme: const ButtonThemeData(
                                                    textTheme: ButtonTextTheme.primary),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        )) ??
                                            _eventEndDate; // cancel 누르면 기존 값 유지
                                        setState(() {
                                          _eventEndDate = picked;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    child: Text('사진 등록',
                                        style: TextStyle(
                                            fontFamily: 'Binggrae', fontSize: Get.width * 0.05,
                                            fontWeight:
                                            FontWeight.bold))),
                              ],
                            ),
                          ],
                        )),
                    _croppedFile == null ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey, // background
                        onPrimary: Colors.white, // foreground
                      ),child: Text('사진 선택', style: TextStyle(
                        fontFamily: 'Binggrae', fontSize: 18,
                        fontWeight:
                        FontWeight.bold)), onPressed: () {
                      selectGalleryImage();
                    },) : InkWell(
                      onTap: () {
                        selectGalleryImage();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 1,
                        height:
                        MediaQuery.of(context).size.height * 0.3,
                        child: Image.file(
                          _croppedFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    FormVerticalSpace(),
                    _isLoading ? Center(child: LoadingIndicator(
                      indicatorType: Indicator.ballSpinFadeLoader,
                      colors: [Colors.black],
                    )) : PrimaryButton(
                      labelText: '이벤트 등록',
                      buttonColor: kPrimaryFirstColor,
                      onPressed: () {
                        uploadImageToFirebase(context, _croppedFile);
                      },
                    ),
                    FormVerticalSpace(),
                  ],
                ),
              ),
            ),
          )
              : Center(
              child: Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                  child: CircularProgressIndicator())),
        );
      });
  }

  selectGalleryImage() {
    ImageController.instance.cropImageFromFile().then((croppedFile) {
      if (croppedFile != null) {
        // setState(() { messageType = 'image'; });
        setState(() {
          _croppedFile = croppedFile;
        });
      }else {
        Get.snackbar('사진 선택', '사진 선택을 취소하였습니다.',backgroundColor: Colors.redAccent.withOpacity(0.8), colorText: Colors.white);
      }
    });
  }

  Future uploadImageToFirebase(BuildContext context, croppedFile) async {
    var todayMonth = DateTime.now().month < 10
        ? '0' + DateTime.now().month.toString()
        : DateTime.now().month;
    var todayDay = DateTime.now().day < 10
        ? '0' + DateTime.now().day.toString()
        : DateTime.now().day;
    var todayHour = DateTime.now().hour < 10
        ? '0' + DateTime.now().hour.toString()
        : DateTime.now().hour;
    var todayMinute = DateTime.now().minute < 10
        ? '0' + DateTime.now().minute.toString()
        : DateTime.now().minute;
    var todaySecond = DateTime.now().second < 10
        ? '0' + DateTime.now().second.toString()
        : DateTime.now().second;

    if(croppedFile != null) {
      try {
        // upload file 제목
        String fileName = 'image_${DateTime
            .now()
            .year}$todayMonth$todayDay$todayHour$todayMinute$todaySecond';
        // upload 위치 지정
        Reference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child(
            'events/$fileName');
        // upload 시작
        UploadTask uploadTask = firebaseStorageRef.putFile(croppedFile);

        setState(() {
          _isLoading = true;
        });
        // upload 중 state 체크
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {

        }, onError: (Object e) {
          print(e); // FirebaseException
        });

        // upload 완료된 경우 url 경로 저장해두기
        uploadTask.then((TaskSnapshot taskSnapshot) {
          taskSnapshot.ref.getDownloadURL().then((value) {
            noticeController.imgUrl = value;

            // 게시글 업로드 (url 경로를 얻은 후에 업로드 해야 함)
            uploadNotice();
          });
        });
      } catch (e) {
        print(e);
      }
    } else {
      uploadNotice(addImage: false);
    }
  }

  uploadNotice({addImage: true}) async {
    var id = DateTime.now()
        .millisecondsSinceEpoch
        .toString();

    Map<String, dynamic> eventData = {
      'id': id,
      'title': _title,
      'town': _town,
      'description': _description,
      'writer': 'admin',
      'imgUrl': noticeController.imgUrl,
      'startAt': _eventStartDate,
      'endAt': _eventEndDate,
      'createdAt': DateTime.now()
    };

    setState(() {
      _isLoading = false;
    });

    noticeController.addEvent(id, eventData);

    Get.back();
    Get.snackbar('이벤트 작성', '작성이 완료되었습니다.',backgroundColor: kPrimaryFirstColor.withOpacity(0.8), colorText: Colors.black);
  }
}