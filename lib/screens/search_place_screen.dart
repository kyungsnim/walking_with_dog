import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walking_with_dog/models/search_model.dart';
import 'package:http/http.dart' as http;
import 'package:walking_with_dog/widgets/loading_indicator.dart';

class SearchPlaceScreen extends StatefulWidget {
  final String searchText;
  final Position location;

  const SearchPlaceScreen(
      {required this.searchText, required this.location, Key? key})
      : super(key: key);

  @override
  _SearchPlaceScreenState createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  late Position location;

  @override
  void initState() {
    super.initState();
    setState(() {
      _searchController.text = widget.searchText;
      location = widget.location;
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
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text(
          '검색 결과',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            _searchAreaView(),
            FutureBuilder<List<SearchModel>>(
                future: fetchSearchResults(
                    _searchController.text, http.Client(), location),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? SearchResultsList(searchResults: snapshot.data!)
                      : loadingIndicator();
                })
          ],
        ),
      ),
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
            fetchSearchResults(
                _searchController.text, http.Client(), location).then((_) => setState(() {}));            // Get.to(() => Place5Screen(
            //       searchText: _searchController.text,
            //       location: location,
            //     ));
          },
          child: Text('검색'),
          style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}

Future<List<SearchModel>> fetchSearchResults(
    String searchText, http.Client client, Position location) async {
  Map<String, String> headers = {
    'Authorization': 'KakaoAK 0c27f7ad527b346db6b5b68e2371e4bc'
  };

  final response = await client.get(
      Uri.parse(
          'https://dapi.kakao.com/v2/local/search/keyword.json?query=$searchText&x=${location.longitude}&y=${location.latitude}'),
      headers: headers);
  return compute(parseSearchResults, response.body);
}

List<SearchModel> parseSearchResults(String responseBody) {
  final parsed = json.decode(responseBody);
  final List<dynamic> results = parsed['documents'];
  List<SearchModel> resultsList =
      results.map<SearchModel>((json) => SearchModel.fromJson(json)).toList();
  resultsList.sort((a, b) => a.distance.compareTo(b.distance));
  return resultsList;
}

class SearchResultsList extends StatelessWidget {
  final List<SearchModel> searchResults;

  SearchResultsList({Key? key, required this.searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return searchResults.isEmpty
        ? loadingIndicator()
        : Flexible(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async =>
                        await launch(searchResults[index].placeUrl),
                    child: ListTile(
                      // leading: Image.network(searchResults[index].placeUrl + '#photoList?type=all&pidx=0'),
                      title: Text(searchResults[index].placeName),
                      subtitle: Text(searchResults[index].roadAddressName),
                      trailing: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.withOpacity(0.2),
                        ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                  '1.5km'),
                                // '${(double.parse(searchResults[index].distance) / 1000).toStringAsFixed(1)}km'),
                          )),
                    ),
                  );
                }),
          );
  }
}
