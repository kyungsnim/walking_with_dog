import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walking_with_dog/constants/constants.dart';
import 'package:walking_with_dog/screens/add_event_screen.dart';

import '../main.dart';

showWaitDialog(
    BuildContext context,
    ) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('현재위치 파악 중', // '게시글 수정/삭제하기'
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: Get.width * 0.04,
              )),
          content: Container(
            width: Get.width * 0.3,
            height: Get.height * 0.1,
            child: Column(children: [
              Text(
                '현재위치를 가져온 후 검색해주세요.',
                // '해당 게시글을 수정/삭제하시려면 비밀번호 입력 후 버튼을 눌러주세요.'
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: Get.width * 0.04,
                ),
              ),
              Spacer(),
            ]),
          ),
          actions: [
            ElevatedButton(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text('닫기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: Get.width * 0.04,
                    )),
              ),
              style: ElevatedButton.styleFrom(primary: Colors.grey),
              onPressed: () async {
                Get.back();
              },
            ),
          ],
        );
      });
}