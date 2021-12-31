import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walking_with_dog/constants/constants.dart';
import 'package:walking_with_dog/screens/search_place_screen.dart';
import 'package:walking_with_dog/widgets/loading_indicator.dart';
import 'package:walking_with_dog/widgets/show_create_dialog.dart';

class PlaceScreen extends StatefulWidget {
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen> {
  Position? _location;
  final TextEditingController _searchController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      if(mounted) {
        setState(() {
          _location = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: _location == null ?
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
      ) : Container(
        margin: EdgeInsets.only(right: 20, left: 20, top: 20),
        child: ListView(
          children: <Widget>[
            _headerView(),
            SizedBox(
              height: Get.height * 0.02,
            ),
            _searchAreaView(),
            SizedBox(
              height: Get.height * 0.02,
            ),
            _advertiseAreaView(),
            SizedBox(
              height: Get.height * 0.02,
            ),
            _categoryIconView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          showCreateDialog(context, _pwdController);
        },
      ),
    );
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
                  color: Colors.blueAccent,
                ),
                hintText: '검색어를 입력해주세요.'),
          ),
        ),
        SizedBox(width: Get.width * 0.02),
        ElevatedButton(
          onPressed: () {
            Get.to(() => SearchPlaceScreen(searchText: _searchController.text, location: _location!));
          },
          child: Text('검색'),
          style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  _advertiseAreaView() {
    return Container(
      height: Get.height * 0.4,
      color: Colors.blueGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              '업체 광고 영역',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Get.width * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _categoryIconView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () {
            Get.to(() => SearchPlaceScreen(searchText: '애견 카페', location: _location!,));
          },
          child: _renderItem('assets/icon/icon_2.png', '카페'),
        ),
        InkWell(
          onTap: () {
            Get.to(() => SearchPlaceScreen(searchText: '동물 병원', location: _location!,));
          },
          child: _renderItem('assets/icon/icon_4.png', '병원'),
        ),
        InkWell(
          onTap: () {
            Get.to(() => SearchPlaceScreen(searchText: '애견 용품', location: _location!,));
          },
          child: _renderItem('assets/icon/icon_5.png', '용품점'),
        ),
        InkWell(
          onTap: () {
            Get.to(() => SearchPlaceScreen(searchText: '애견 미용', location: _location!,));
          },
          child: _renderItem('assets/icon/icon_6.png', '미용'),
        ),
      ],
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
}