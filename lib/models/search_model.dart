class SearchModel {
  late final String id; // 장소ID
  late final String placeName; // 장소명
  late final String categoryName; // 카테고리
  late final String phone; // 전화번호
  late final String addressName; // 지번 주소
  late final String roadAddressName; // 도로명 주소
  late final String longitude; // 경도
  late final String latitude; // 위도
  late final String placeUrl; // 장소 상세페이지 url
  late final String distance; // 중심좌표까지의 거리

  SearchModel(
      {required this.id,
      required this.placeName,
      required this.categoryName,
      required this.phone,
      required this.addressName,
      required this.roadAddressName,
      required this.longitude,
      required this.latitude,
      required this.placeUrl,
      required this.distance});

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
        id: json['id'] as String,
        placeName: json['place_name'] as String,
        categoryName: json['category_name'] as String,
        phone: json['phone'] as String,
        addressName: json['address_name'] as String,
        roadAddressName: json['road_address_name'] as String,
        longitude: json['x'] as String,
        latitude: json['y'] as String,
        placeUrl: json['place_url'] as String,
        distance: json['distance'] as String);
  }
}
