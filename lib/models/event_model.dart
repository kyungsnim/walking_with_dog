import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String id;
  String title;         // 이벤트하는 상호명
  String town;          // 주소 (동)
  String description;   // 이벤트 내용
  String imgUrl;
  DateTime startAt;
  DateTime endAt;
  DateTime createdAt;

  EventModel(
      {required this.id,
      required this.title,
      required this.town,
      required this.description,
      required this.imgUrl,
      required this.startAt,
      required this.endAt,
      required this.createdAt});

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "town": town,
        "description": description,
        "imgUrl": imgUrl,
        "startAt": startAt,
        "endAt": endAt,
    "createdAt": createdAt
      };

  EventModel.fromMap(var data)
      : id = data['id'],
        title = data['title'],
        town = data['town'],
        description = data['description'],
        imgUrl = data['imgUrl'] ?? '',
        startAt = data['startAt'].toDate() ?? DateTime.now(),
        endAt = data['endAt'].toDate() ?? DateTime.now(),
        createdAt = data['createdAt'].toDate();

  EventModel.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data());
}
