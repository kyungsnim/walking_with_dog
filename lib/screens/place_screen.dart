import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:walking_with_dog/constants/constants.dart';
import 'package:walking_with_dog/constants/data4.dart';
import 'package:walking_with_dog/controller/event_controller.dart';
import 'package:walking_with_dog/models/event_model.dart';
import 'package:walking_with_dog/screens/search_place_screen.dart';
import 'package:walking_with_dog/utils/launch_url.dart';
import 'package:walking_with_dog/widgets/loading_indicator.dart';
import 'package:walking_with_dog/widgets/show_create_dialog.dart';
import 'package:walking_with_dog/widgets/show_wait_dialog.dart';

class PlaceScreen extends StatefulWidget {
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen>
    with AutomaticKeepAliveClientMixin {
  // Position? _location;
  final TextEditingController _searchController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  var imageList = [
    InkWell(
      onTap: () => launchUrl('https://place.map.kakao.com/2025194108'),
      child: ClipRRect(
        child: Image.asset('assets/ads/004.png'),
      ),
    ),
    InkWell(
      onTap: () => launchUrl('https://place.map.kakao.com/909687194'),
      child: ClipRRect(
        child: Image.asset('assets/ads/003.png'),
      ),
    ),
    InkWell(
      onTap: () => launchUrl('https://place.map.kakao.com/14733794'),
      child: ClipRRect(
        child: Image.asset('assets/ads/002.png'),
      ),
    ),
  ];

  var _lastRow = 0;
  final FETCH_ROW = 10;
  var stream;
  ScrollController _scrollController = new ScrollController();
  var eventRef = FirebaseFirestore.instance.collection('Event');
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  Stream<QuerySnapshot> newStream() {
    return eventRef.limit(FETCH_ROW * (_lastRow + 1)).snapshots();
  }

  @override
  void initState() {
    super.initState();

    stream = newStream();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          mounted) {
        setState(() {
          stream = newStream();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventController>(builder: (_) {
      return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Container(
          margin: EdgeInsets.only(right: 20, left: 20, top: 20),
          child: ListView(
            children: <Widget>[
              _headerView(),
              SizedBox(
                height: Get.height * 0.02,
              ),
              _searchAreaView(),
              _advertiseAreaView(),
              SizedBox(
                height: Get.height * 0.02,
              ),
              _categoryIconView(),
              SizedBox(
                height: Get.height * 0.03,
              ),
              _recommentView(),
              SizedBox(
                height: Get.height * 0.03,
              ),
              Text(
                '이벤트 소식',
                style: TextStyle(
                  fontSize: Get.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _eventView(context),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: kPrimaryFirstColor,
          onPressed: () {
            showCreateDialog(context, _pwdController);
          },
        ),
      );
    });
  }

  _headerView() {
    return Row(
      children: [
        Image.asset(
          'assets/icon/icon_5.png',
          width: Get.width * 0.1,
          height: Get.width * 0.05,
        ),
        Text(
          '플레이스',
          style: TextStyle(
            fontSize: Get.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        myLocation == null ? loadingIndicator() :
        Icon(Icons.location_on_outlined),
        myLocation == null ? const Text('현재위치를 가져오는 중입니다.', style: TextStyle(fontSize: 10,)) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('위도: ${myLocation!.latitude.toString().substring(0, 10)}', style: const TextStyle(fontSize: 10,),),
            Text('경도: ${myLocation!.longitude.toString().substring(0, 10)}', style: const TextStyle(fontSize: 10,),),
          ],
        ),

      ],
    );
  }

  _searchAreaView() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                border: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: kPrimaryFirstColor,
                ),
                hintText: '검색어를 입력해주세요.'),
          ),
        ),
        SizedBox(width: Get.width * 0.02),
        ElevatedButton(
          onPressed: () {
            if(myLocation == null) {
              showWaitDialog(context);
            } else {
              Get.to(() =>
                  SearchPlaceScreen(
                      searchText: _searchController.text,
                      location: myLocation!));
            }
          },
          child: const Text('검색',
              style: TextStyle(
                color: Colors.black,
              )),
          style: ElevatedButton.styleFrom(
            fixedSize: Size.fromHeight(Get.height * 0.053),
            primary: kPrimaryFirstColor,
          ),
        ),
      ],
    );
  }

  Widget _advertiseAreaView() {
    return CarouselSlider(
      options: CarouselOptions(
        height: Get.height * 0.41,
        autoPlay: true,
        aspectRatio: 1 / 1,
        viewportFraction: 1,
      ),
      items: imageList.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              // color: Colors.green,
              width: Get.width,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: image,
            );
          },
        );
      }).toList(),
    );
  }

  _getCurrentLocation() async {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      setState(() {
        myLocation = position;
      });

      // await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  _categoryIconView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            if(myLocation == null) {
              showWaitDialog(context);
            } else {
              Get.to(() => SearchPlaceScreen(
                    searchText: '애견 카페',
                    location: myLocation!,
                  ));
            }
          },
          child: _renderItem('assets/icon/icon_2.png', '카페'),
        ),
        InkWell(
          onTap: () {
            if(myLocation == null) {
              showWaitDialog(context);
            } else {
              Get.to(() => SearchPlaceScreen(
                    searchText: '동물 병원',
                    location: myLocation!,
                  ));
            }
          },
          child: _renderItem('assets/icon/icon_4.png', '병원'),
        ),
        InkWell(
          onTap: () {
            if(myLocation == null) {
              showWaitDialog(context);
            } else {
              Get.to(() => SearchPlaceScreen(
                    searchText: '애견 용품',
                    location: myLocation!,
                  ));
            }
          },
          child: _renderItem('assets/icon/icon_5.png', '용품점'),
        ),
        InkWell(
          onTap: () {
            if(myLocation == null) {
              showWaitDialog(context);
            } else {
              Get.to(() => SearchPlaceScreen(
                    searchText: '애견 미용',
                    location: myLocation!,
                  ));
            }
          },
          child: _renderItem('assets/icon/icon_6.png', '미용'),
        ),
      ],
    );
  }

  _recommentView() {
    return InkWell(
      onTap: () => launchUrl('https://c59mrhltv3l.typeform.com/to/khdXl2GW'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.black,
        ),
        child: Row(
          children: [
            SizedBox(
              width: Get.width * 0.02,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                'assets/marker2.png',
                width: Get.width * 0.18,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '좋은 플레이스 정보는 다같이~',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Get.width * 0.035,
                  ),
                ),
                Text(
                  '나만의 단골 플레이스 추천하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Get.width * 0.042,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            Expanded(
              child: Text(
                '클릭',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: Get.width * 0.042,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 5),
          ],
        ),
      ),
    );
  }

  _renderItem(String path, String name) {
    return Column(
      children: [
        Image.asset(
          path,
          width: Get.width * 0.2,
          height: Get.width * 0.1,
        ),
        SizedBox(height: 3),
        Text(name),
      ],
    );
  }

  _eventView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return _buildList(context, snapshot.data!.docs);
        });
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 6 / 7,
          crossAxisCount: 2,
        ),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: snapshot.length,
        itemBuilder: (context, i) {
          // print("i : " + i.toString());
          final currentRow = (i + 1) ~/ FETCH_ROW;
          if (_lastRow != currentRow) {
            _lastRow = currentRow;
          }
          print("lastrow : " + _lastRow.toString());
          return _buildListItem(context, snapshot[i]);
        });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    EventModel event = EventModel.fromSnapshot(data);
    return Padding(
      key: ValueKey(event.id),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 0), blurRadius: 5, color: Colors.white10)
          ],
        ),
        child: GestureDetector(
          onTap: () {
            if (event.placeUrl != '') {
              launchUrl(event.placeUrl);
            }
          },
          child: _listItem(event),
        ),
      ),
    );
  }

  _listItem(EventModel event) {
    return Container(
      width: Get.width,
      height: Get.height * 0.3,
      margin: EdgeInsets.symmetric(vertical: 5),
      // height: 200,
      child: event.title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: Get.height * 0.13,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(blurRadius: 5, color: Colors.black54)
                  ]),
                  child: event.imgUrl == ''
                      ? Placeholder()
                      : ClipRRect(
                          child: CachedNetworkImage(
                              width: Get.width * 0.5,
                              imageUrl: event.imgUrl,
                              fit: BoxFit.fitWidth),
                        ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: Get.height * 0.15,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 2),
                          child: Row(
                            children: [
                              Text(
                                event.title.length > 20
                                    ? event.title.toString().substring(0, 18) +
                                        '...'
                                    : event.title,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Binggrae',
                                  fontSize: Get.width * 0.04,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                event.town.length > 20
                                    ? event.town.toString().substring(0, 18) +
                                        '...'
                                    : event.town,
                                softWrap: true,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Binggrae',
                                    fontSize: Get.width * 0.03,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\'${event.startAt.toString().substring(2, 10).replaceAll('-', '.')} ~ \'${event.endAt.toString().substring(2, 10).replaceAll('-', '.')}',
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: 'Binggrae',
                              fontSize: Get.width * 0.03),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            event.description.length > 20
                                ? event.description
                                        .toString()
                                        .substring(0, 18) +
                                    '...'
                                : event.description,
                            softWrap: true,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Binggrae',
                              fontSize: Get.width * 0.03,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
