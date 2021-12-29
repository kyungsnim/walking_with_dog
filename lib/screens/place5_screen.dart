import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:walking_with_dog/models/search_model.dart';
import 'package:http/http.dart' as http;
import 'package:walking_with_dog/widgets/loading_indicator.dart';

class Place5Screen extends StatefulWidget {
  const Place5Screen({Key? key}) : super(key: key);

  @override
  _Place5ScreenState createState() => _Place5ScreenState();
}

class _Place5ScreenState extends State<Place5Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<SearchModel>>(
        future: fetchSearchResults(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData ? SearchResultsList(searchResults: snapshot.data!)
              : loadingIndicator();
        }
      )
    );
  }
}

Future<List<SearchModel>> fetchSearchResults(http.Client client) async {
  Map<String, String> headers = {
    'Authorization': 'KakaoAK 0c27f7ad527b346db6b5b68e2371e4bc'
  };

  final response = await client.get(Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=분당 동물병원&x=127.121156122113&y=37.385662912447'), headers: headers);
  return compute(parseSearchResults, response.body);
}

List<SearchModel> parseSearchResults(String responseBody) {
  print(json.decode(responseBody));
  final parsed = json.decode(responseBody);
  final List<dynamic> results = parsed['documents'];

  return results.map<SearchModel>((json) => SearchModel.fromJson(json)).toList();
}

class SearchResultsList extends StatelessWidget {
  final List<SearchModel> searchResults;
  SearchResultsList({Key? key, required this.searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index].placeName),
          subtitle: Text(searchResults[index].roadAddressName),
        );
      }
    );
  }
}
