import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//GET
Future<List<Categories>> fetchCategories() async {
  final response =
      await http.get(Uri.parse('https://localhost:44393/api/Categories'));

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    List<Categories> photos = [];

    for (var i in jsonResponse) {
      photos.add(Categories(
          cid: i['cid'],
          cgid: i['cgid'],
          cName: i['cName'],
          cStartDate: i['cStartDate'],
          cEndDate: i['cEndDate'],
          cBudget: i['cBudget']));
    }
    return photos;
  } else {
    throw Exception('Failed to load photos');
  }
}

//DELETE

Future<http.Response> deleteCategory(String cgid) async {
  final http.Response response = await http.delete(Uri.parse('https://localhost:44393/api/Categories/Delete/$cgid'));

  if(response.statusCode == 200){
    fetchCategories();
  }
  else {
    Exception('Usunięcie kategorii zakończyło się niepowodzeniem');
  }
  return response;
}

class Categories {
  final int cid;
  final String cgid;
  final String cName;
  final String cStartDate;
  final String cEndDate;
  final double cBudget;

  const Categories({
    required this.cid,
    required this.cgid,
    required this.cName,
    required this.cStartDate,
    required this.cEndDate,
    required this.cBudget,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      cid: json['cid'],
      cgid: json['cgid'],
      cName: json['cName'],
      cStartDate: json['cStartDate'],
      cEndDate: json['cEndDate'],
      cBudget: json['cBudget'],
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
        child: Column(
      children: [
        Row(children: const <Widget>[
          Expanded(child: Text("Nazwa kategorii")),
          Expanded(child: Text("Data początku")),
          Expanded(child: Text("Data końca")),
          Expanded(child: Text("Budżet")),
        ]),
        Center(
          child: FutureBuilder<List<Categories>>(
            future: futurePhotos,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color.fromRGBO(225, 225, 225, 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    snapshot.data![index].cName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    snapshot.data![index].cStartDate,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    snapshot.data![index].cEndDate,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    snapshot.data![index].cBudget.toString(),
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.edit),
                                DeleteButton(cgid: snapshot.data![index].cgid),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ],
    ));
  }
}

//Buttons
class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.cgid});

  final String cgid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Usuń kategorię',
          onPressed: () {
            deleteCategory(cgid);
          },
        ),
      ],
    );
  }
}
