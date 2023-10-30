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

//Add / Edit

Future<http.Response> editCategory(Categories category) async {
  final http.Response response = await http
      .delete(Uri.parse('https://localhost:44393/api/Categories/Save'), 
      body: category);

  if (response.statusCode == 200) {
  } else {
    Exception('Usunięcie kategorii zakończyło się niepowodzeniem');
  }
  return response;
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
  late Categories category = Categories(
      cid: 0,
      cgid: "",
      cName: "",
      cStartDate: DateTime.now().toString(),
      cEndDate: DateTime.now().toString(),
      cBudget: 0);

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
          if (isEditEnabled) EditDataWidget(category: category),
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
                                  EditButton(category: snapshot.data![index]),
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
  const EditButton({super.key, required this.category});

  final Categories category;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edytuj kategorię',
          onPressed: () {
            var categoriesState =
                context.findAncestorStateOfType<_CategoriesPageState>();
            categoriesState?.setState(() {
              categoriesState.isEditEnabled = true;
              categoriesState.category = category;
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
// ignore: must_be_immutable
class EditDataWidget extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var category;

  EditDataWidget({Key? key, this.category}) : super(key: key);

  @override
  State<EditDataWidget> createState() => _EditDataWidgetState();
}

class _EditDataWidgetState extends State<EditDataWidget> {
  var cName = "";
  var cStartDate = DateTime.now();
  var cEndDate = DateTime.now();
  var cBudget = 0.0;

  void _showStartDatePicker(BuildContext context) async {
    DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(widget.category.cStartDate),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        DateTime.now();

    cStartDate = pickedDate;
  }

  void _showEndDatePicker(BuildContext context) async {
    DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(widget.category.cEndDate),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        DateTime.now();

    cEndDate = pickedDate;
  }

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
                  initialValue: widget.category.cName,
                  decoration:
                      const InputDecoration(labelText: 'Nazwa kategorii'),
                  onChanged: (value) => cName = value),
            ),
            ListTile(
              title: const Text('Data początku'),
              subtitle: Text(
                  '${DateTime.parse(widget.category.cStartDate).toLocal()}'
                      .split(' ')[0]),
              onTap: () {
                _showStartDatePicker(context);
              },
            ),
            ListTile(
              title: const Text('Data końca'),
              subtitle: Text(
                  '${DateTime.parse(widget.category.cEndDate).toLocal()}'
                      .split(' ')[0]),
              onTap: () {
                _showEndDatePicker(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                  initialValue: widget.category.cBudget.toString(),
                  decoration: const InputDecoration(labelText: 'Budżet'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    cBudget = double.tryParse(value) ?? 0.0;
                  }),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      var categoryToSave = Categories(
                          cid: widget.category.cid,
                          cgid: widget.category.cgid,
                          cName: cName,
                          cStartDate: cStartDate.toString(),
                          cEndDate: cEndDate.toString(),
                          cBudget: cBudget);

                          print(categoryToSave.cName);
                          print(categoryToSave.cStartDate);
                          print(categoryToSave.cEndDate);
                          print(categoryToSave.cBudget);

                      editCategory(categoryToSave);    
                    },
                    child: const Text('Zapisz'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () {
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
