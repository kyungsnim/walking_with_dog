import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:walking_with_dog/screens/my_screen.dart';
import 'package:walking_with_dog/screens/place2_screen.dart';
import 'package:walking_with_dog/screens/place3_screen.dart';
import 'package:walking_with_dog/screens/place4_screen.dart';
import 'package:walking_with_dog/screens/place5_screen.dart';
import 'package:walking_with_dog/screens/place_screen.dart';
import 'package:walking_with_dog/screens/walk_screen.dart';

import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  // final int getPageIndex;
  const HomeScreen({Key? key}) : super(key: key); // required this.getPageIndex,

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool isLoading = false;
  int? currentIndex;

  // 페이지 컨트롤
  PageController? pageController;
  int getPageIndex = 0;

  String myToken = '';

  @override
  void initState() {
    super.initState();

    // currentIndex = widget.getPageIndex;
    // setState(() {
    //   getPageIndex = widget.getPageIndex;
    // });
    pageController = PageController(
      // 다른 페이지에서 넘어올 때도 controller를 통해 어떤 페이지 보여줄 것인지 셋팅
        initialPage: 0);

    // WidgetsBinding.instance!.addObserver(this);
    // setStatus('Online');
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController!
        .animateToPage(pageIndex, duration: const Duration(milliseconds: 100), curve: Curves.bounceInOut);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitDialog(),
      child: DefaultTabController(
        length: 4,
        initialIndex: 0, //currentIndex!,
        child: Scaffold(
          body: PageView(
            children: [
              WalkScreen(), //Walk2Screen(),
              HistoryScreen(),
              Place5Screen(),
              MyScreen(),
            ],
            controller: pageController, // controller를 지정해주면 각 페이지별 인덱스로 컨트롤 가능
            onPageChanged:
            whenPageChanges, // page가 바뀔때마다 whenPageChanges 함수가 호출되고 현재 pageIndex 업데이트해줌
          ),
          bottomNavigationBar: SizedBox(
            height: Get.height * 0.15,
            child: BottomNavigationBar(
              // Bar에 텍스트 라벨 안보이게 변경
              // showSelectedLabels: false,
              // showUnselectedLabels: false,
              backgroundColor: Colors.white,
              currentIndex: getPageIndex,
              onTap: onTapChangePage,
              selectedItemColor: Colors.black,
              selectedIconTheme: const IconThemeData(size: 40),
              selectedFontSize: 16,
              selectedLabelStyle:
              const TextStyle(fontFamily: 'Nanum', fontWeight: FontWeight.bold, color: Colors.black),
              unselectedItemColor: Colors.grey,
              unselectedFontSize: 12,
              // iconSize: 20,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/icon/bottom1.png',
                      width: 20,
                    ),
                    activeIcon: Image.asset(
                      'assets/icon/bottom1.png',
                      width: 30,
                    ),
                    label: '산책'),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/icon/bottom2.png',
                      width: 15,
                    ),
                    activeIcon: Image.asset(
                      'assets/icon/bottom2.png',
                      width: 25,
                    ),
                    label: '기록'),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/icon/bottom3.png',
                      width: 20,
                    ),
                    activeIcon: Image.asset(
                      'assets/icon/bottom3.png',
                      width: 30,
                    ),
                    label: '플레이스'),
                BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/icon/bottom4.png',
                      width: 20,
                    ),
                    activeIcon: Image.asset(
                      'assets/icon/bottom4.png',
                      width: 30,
                    ),
                    label: 'MY'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showExitDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('앱 종료',
                style: TextStyle(
                  fontFamily: 'Binggrae',
                )),
            content: const Text(
              '종료하시겠습니까?',
              style: TextStyle(fontFamily: 'Binggrae'),
            ),
            actions: [
              ElevatedButton(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text('확인', style: TextStyle(fontFamily: 'Binggrae', fontSize: 16)),
                ),
                style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
                onPressed: () async {
                  SystemNavigator.pop();
                },
              ),
              ElevatedButton(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text('취소', style: TextStyle(fontFamily: 'Binggrae', fontSize: 16)),
                ),
                style: ElevatedButton.styleFrom(primary: Colors.grey),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
