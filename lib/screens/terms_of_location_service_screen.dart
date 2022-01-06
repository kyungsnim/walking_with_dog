import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsOfLocationServiceScreen extends StatefulWidget {
  const TermsOfLocationServiceScreen({Key? key}) : super(key: key);

  @override
  _TermsOfLocationServiceScreenState createState() => _TermsOfLocationServiceScreenState();
}

class _TermsOfLocationServiceScreenState extends State<TermsOfLocationServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            ListView(children: [
              Text(
                '위치기반 서비스 이용약관',
                style: TextStyle(
                  fontSize: Get.width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('''
제 1 조 (목적)
이 약관은 오아자(이하 '회사')가 제공하는 위치기반서비스(이하 '서비스')에 관하여 회사와 이용계약을 체결한 고객이 서비스를 이용하는 데 필요한 회사와 고객의 권리 및 의무, 기타 제반 사항을 정함을 목적으로 합니다.

제 2 조 (약관의 효력 및 변경)
본 약관은 본 서비스를 이용하고자 하는 모든 고객을 대상으로 합니다.
본 약관의 내용은 서비스 화면에 게시하거나 기타의 방법으로 고객에게 공시하고, 이에 동의한 고객이 본 서비스에 가입함으로써 효력이 발생합니다.
회사는 필요하다고 인정되면 본 약관을 변경할 수 있으며, 회사가 약관을 변경할 때에는 적용일자와 변경사유를 구체적으로 기재하여 제2항과 같은 방법으로 그 적용일자 7일 전부터 공지합니다.

제 3 조 (약관 외 준칙)
이 약관에 명시되지 않은 사항은 위치정보의 보호 및 이용 등에 관한 법률(이하 "위치정보법"), 전기통신사업법, 정보통신망 이용촉진 및 보호 등에 관한 법률(이하 "정보통신망법"), 개인정보보호법 등 관계 법령 및 회사가 정한 서비스의 세부이용지침 등의 규정을 따릅니다.

제 4 조 (가입자격)
서비스에 가입할 수 있는 자는 위치기반서비스를 이용할 수 있는 이동전화 단말기, 기타 서비스를 이용할 수 있는 단말기(이하 "단말기")의 소유자 본인이어야 합니다.
 회사가 정한 본 약관에 이용자가 동의하고, 회사가 승낙함으로써 서비스 가입의 효력이 발생합니다.

제 5 조 (서비스의 내용)
서비스의 내용은 위치 기반의 산책경로 기록 및 공유 입니다.

제 6 조 (서비스의 수준)
서비스의 이용은 연중무휴 1일 24시간을 원칙으로 합니다. 단, 회사의 업무 또는 기술상의 이유로 서비스가 일시 중지될 수 있으며, 운영상의 목적으로 회사가 정한 기간에도 서비스는 일시 중지될 수 있습니다. 이때 회사는 사전 또는 사후에 이를 공지합니다. 
위치정보는 관련 기술의 발전에 따라 오차가 발생할 수 있습니다.

제 7 조 (위치정보의 정의 등)
본 약관에서 사용하는 "위치정보"란 이동성이 있는 물건 또는 개인이 특정한 시간에 존재하거나 존재했던 장소에 관한 정보(현 위치 및 방문기록 등 포함)로서 전기통신설비 및 전기통신회선설비를 이용하여 수집된 것을 말합니다.
회사는 본 약관에 동의하여 위치정보의 이용을 승낙한 고객에 한하여 위치정보법 등 관련 법률에서 정한 바에 따라 위치정보를 취득하며 서비스의 목적범위 내에서 위치정보를 이용합니다.

제 8 조 (고객의 개인위치정보보호)
회사는 관련 법령이 정하는 바에 따라 고객의 개인위치정보를 보호하기 위해 노력합니다.

제 9 조 (개인위치정보의 이용 또는 제공)
회사는 서비스 제공을 위하여 회사가 수집한 고객의 위치정보를 이용할 수 있으며, 고객이 본 약관에 동의하면 위치정보 이용에 동의한 것으로 간주됩니다.
회사는 고객이 제공한 개인위치정보를 해당 고객의 동의 없이 서비스 제공 이외의 목적으로 이용하지 않습니다.

제 10조 (양도금지)
고객과 회사는 고객의 서비스 가입에 따른 본 약관상의 지위 또는 권리, 의무의 전부 또는 일부를 제3자에게 양도하거나 위임할 수 없으며 담보 제공 등의 목적으로 처분할 수 없습니다.

제 11 조 (손해배상)
회사가 위치정보의 보호 및 이용 등에 관한 법률 제15조 내지 제26조의 규정을 위반한 행위로 이용자에게 손해가 발생한 경우 이용자는 회사에 대하여 손해배상 청구를 할 수 있습니다. 이 경우 회사는 고의, 과실이 없음을 입증하지 못하는 경우 책임을 면할 수 없습니다.
회원이 본 약관의 규정을 위반하여 회사에 손해가 발생한 경우 회사는 이용자에 대하여 손해배상을 청구할 수 있습니다. 이 경우 이용자는 고의, 과실이 없음을 입증하지 못하는 경우 책임을 면할 수 없습니다.

제 12 조 (면책)
회사는 다음 각 호의 경우로 서비스를 제공할 수 없는 경우 이로 인하여 이용자에게 발생한 손해에 대해서는 책임을 부담하지 않습니다.
천재지변 또는 이에 준하는 불가항력의 상태가 있는 경우 서비스 제공을 위하여 회사와 서비스 제휴계약을 체결한 제3자의 고의적인 서비스 방해가 있는 경우 회원의 귀책사유로 서비스 이용에 장애가 있는 경우 제1호 내지 제3호를 제외한 기타 회사의 고의∙과실이 없는 사유로 인한 경우 회사는 서비스 및 서비스에 게재된 정보, 자료, 사실의 신뢰도, 정확성 등에 대해서는 보증을 하지 않으며 이로 인해 발생한 이용자의 손해에 대하여는 책임을 부담하지 아니합니다.
            '''),
            ]),
            Align(
                alignment: Alignment.bottomCenter,
                // left: Get.width * 0.4,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    alignment: Alignment.center,
                    height: Get.height * 0.06,
                    width: Get.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blueAccent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 16),
                        child: Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
                      )
                  ),
                ))
          ]
        ),
      ),
    );
  }
}
