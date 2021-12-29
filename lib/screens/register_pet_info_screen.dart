import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPetInfoScreen extends StatefulWidget {
  const RegisterPetInfoScreen({Key? key}) : super(key: key);

  @override
  _RegisterPetInfoScreenState createState() => _RegisterPetInfoScreenState();
}

class _RegisterPetInfoScreenState extends State<RegisterPetInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  SizedBox(height: Get.height * 0.1,),
                  Text('')
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
