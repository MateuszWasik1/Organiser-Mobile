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
  final http.Response response = await http
      .delete(Uri.parse('https://localhost:44393/api/Categories/Delete/$cgid'));

  if (response.statusCode == 200) {
    fetchCategories();
  } else {
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
  late bool isEditEnabled = false;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              children: [
                const Expanded(
                  flex: 8,
                  child: Text(
                    "Kategorie",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditEnabled = true;
                    });
                  },
                  child: const Text('Dodaj'),
                ),
              ],
            ),
          ),
          if (isEditEnabled) EditDataWidget(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: const <Widget>[
                Expanded(child: Text("Nazwa kategorii")),
                Expanded(child: Text("Data początku")),
                Expanded(child: Text("Data końca")),
                Expanded(child: Text("Budżet")),
              ],
            ),
          ),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                                  EditButton(cgid: snapshot.data![index].cgid),
                                  DeleteButton(
                                      cgid: snapshot.data![index].cgid),
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
      ),
    );
  }
}

//Buttons
class EditButton extends StatelessWidget {
  const EditButton({super.key, required this.cgid});

  final String cgid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edytuj kategorię',
          onPressed: () {
            var state = context.findAncestorStateOfType<_CategoriesPageState>();
            state?.setState(() {
              state.isEditEnabled = true;
            });
          },
        ),
      ],
    );
  }
}

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

//EditWidget
class EditDataWidget extends StatefulWidget {
  @override
  State<EditDataWidget> createState() => _EditDataWidgetState();
}

class _EditDataWidgetState extends State<EditDataWidget> {
  String cName = '';
  DateTime cStartDate = DateTime.now();
  DateTime cEndDate = DateTime.now();
  double cBudget = 0.0;

  // void _showStartDatePicker(BuildContext context) async {
  //   DateTime pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: startDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (pickedDate != null) {
  //     setState(() {
  //       startDate = pickedDate;
  //     });
  //   }
  // }

  // void _showEndDatePicker(BuildContext context) async {
  //   DateTime pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: endDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (pickedDate != null) {
  //     setState(() {
  //       endDate = pickedDate;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Nazwa kategorii'),
                onChanged: (value) {
                  setState(() {
                    cName = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Data początku'),
              subtitle: Text('${cStartDate.toLocal()}'.split(' ')[0]),
              onTap: () {
                //_showStartDatePicker(context);
              },
            ),
            ListTile(
              title: const Text('Data końca'),
              subtitle: Text('${cEndDate.toLocal()}'.split(' ')[0]),
              onTap: () {
                //_showEndDatePicker(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Budżet'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    cBudget = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle saving the data here
                      print('Name: $cName');
                      print('Start Date: $cStartDate');
                      print('End Date: $cEndDate');
                      print('Budget: $cBudget');
                    },
                    child: const Text('Zapisz'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        cName = '';
                        cStartDate = DateTime.now();
                        cEndDate = DateTime.now();
                        cBudget = 0.0;
                      });
                      var state = context
                          .findAncestorStateOfType<_CategoriesPageState>();
                      state?.setState(() {
                        state.isEditEnabled = false;
                      });
                    },
                    child: const Text('Anuluj'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
