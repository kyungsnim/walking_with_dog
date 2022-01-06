import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walking_with_dog/constants/constants.dart';
import 'package:walking_with_dog/screens/add_event_screen.dart';

import '../main.dart';

showCreateDialog(
    BuildContext context,
    TextEditingController pwdController,
    ) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이벤트 등록하기', // '게시글 수정/삭제하기'
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: Get.width * 0.04,
              )),
          content: Container(
            width: Get.width * 0.3,
            height: Get.height * 0.2,
            child: Column(children: [
              Text(
                '이벤트를 등록하시려면 비밀번호 입력 후 버튼을 눌러주세요.',
                // '해당 게시글을 수정/삭제하시려면 비밀번호 입력 후 버튼을 눌러주세요.'
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: Get.width * 0.04,
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Text(
                    '비밀번호',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: Get.width * 0.04,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력하세요.',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: Get.width * 0.03,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: kPrimaryFirstColor,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: kPrimaryFirstColor,
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: kPrimaryFirstColor,
                          ),
                        ),
                      ),
                      controller: pwdController,
                      cursorColor: kPrimaryFirstColor,
                    ),
                  ),
                ],
              ),
              Spacer(),
            ]),
          ),
          actions: [
            ElevatedButton(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text('이동',
                    style: TextStyle(
                        fontFamily: 'Pretendard', fontSize: Get.width * 0.04)),
              ),
              style: ElevatedButton.styleFrom(primary: kPrimaryFirstColor),
              onPressed: () async {
                if (pwdController.text != globalPwd) {
                  Get.snackbar(
                    '비밀번호 오류',
                    '비밀번호가 맞지 않습니다.',
                  );
                } else {
                  pwdController.text = '';
                  Navigator.pop(context);

                  Get.to(() => AddEventScreen());
                }
              },
            ),
            ElevatedButton(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text('취소',
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