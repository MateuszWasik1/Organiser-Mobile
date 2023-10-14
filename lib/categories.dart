import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Categories>> fetchCategories() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    List<Categories> photos = [];

    for (var i in jsonResponse) {
      photos.add(Categories(
          CID: i['CID'],
          CGID: i['CGID'],
          CName: i['CName'],
          CStartDate: i['CStartDate'],
          CEndDate: i['CEndDate'],
          CBudget: i['CBudget']));
    }
    return photos;
  } else {
    throw Exception('Failed to load photos');
  }
}

class Categories {
  final int CID;
  final String CGID;
  final String CName;
  final DateTime CStartDate;
  final DateTime CEndDate;
  final double CBudget;

  const Categories({
    required this.CID,
    required this.CGID,
    required this.CName,
    required this.CStartDate,
    required this.CEndDate,
    required this.CBudget,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      CID: json['CID'],
      CGID: json['CGID'],
      CName: json['CName'],
      CStartDate: json['CStartDate'],
      CEndDate: json['CEndDate'],
      CBudget: json['CBudget'],
    );
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Categories>> futurePhotos;

  @override
  void initState() {
    super.initState();
    futurePhotos = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Categories>>(
        future: futurePhotos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //print('run command flutter run --web-renderer html');
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 50,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    // child: Image.network(
                    //   snapshot.data![index].url,
                    // ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}