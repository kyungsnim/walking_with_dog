import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walking_with_dog/screens/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Place4Screen extends StatelessWidget {
  // String? link;

  Place4Screen({Key? key, }) : super(key: key); // required this.link

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            WebView(
              initialUrl: 'https://map.naver.com/v5/search/%EB%B6%84%EB%8B%B9%20%EC%95%A0%EA%B2%AC%20%EC%8B%9D%EB%8B%B9',
              javascriptMode: JavascriptMode.unrestricted,
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      /// back button
                      InkWell(
                        onTap: () => Get.offAll(() => HomeScreen()),
                        child: renderIcon(context, Icons.clear),
                      ),

                      const Spacer(),

                      /// share button
                      // renderIcon(context, Icons.share),
                      // SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      //
                      // /// book mark button
                      // renderIcon(context, Icons.bookmark_border)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget renderIcon(BuildContext context, IconData icon) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.indigo,
          border: Border.all(color: Colors.white),
        ),
        height: MediaQuery.of(context).size.width * 0.1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Center(
                child: Icon(icon,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.06),
              ),
              SizedBox(width: 5),
              Text('앱으로 돌아가기', style: TextStyle(color: Colors.white),),
            ],
          ),
        ),
      ),
    ]);
  }
}
