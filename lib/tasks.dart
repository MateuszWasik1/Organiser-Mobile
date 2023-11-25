import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//GET
Future<List<Tasks>> fetchTasks() async {
  final response =
      await http.get(Uri.parse('https://localhost:44393/api/Tasks'));

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    List<Tasks> tasks = [];

    for (var json in jsonResponse) {
      tasks.add(Tasks(
      tid: json['tid'],
      tgid: json['tgid'],
      tuid: json['tuid'],
      tcgid: json['tcgid'],
      tName: json['tName'],
      tLocalization: json['tLocalization'],
      tTime: json['tTime'],
      tBudget: json['tBudget'],
      tStatus: json['tStatus']));
    }
    return tasks;
  } else {
    throw Exception('Failed to load tasks');
  }
}

Future<List<Categories>> fetchCategories() async {
  final response =
      await http.get(Uri.parse('https://localhost:44393/api/Categories'));

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    List<Categories> categories = [];

    for (var i in jsonResponse) {
      categories.add(Categories(
          cid: i['cid'],
          cgid: i['cgid'],
          cName: i['cName'],
          cStartDate: i['cStartDate'],
          cEndDate: i['cEndDate'],
          cBudget: i['cBudget']));
    }
    return categories;
  } else {
    throw Exception('Failed to load categories');
  }
}

class Tasks {
  final int tid;
  final String tgid;
  final int tuid;
  final String tcgid;
  final String tName;
  final String tLocalization;
  final String tTime;
  final int tBudget;
  final int tStatus;

  const Tasks({
    required this.tid,
    required this.tgid,
    required this.tuid,
    required this.tcgid,
    required this.tName,
    required this.tLocalization,
    required this.tTime,
    required this.tBudget,
    required this.tStatus,
  });

  factory Tasks.fromJson(Map<String, dynamic> json) {
    return Tasks(
      tid: json['tid'],
      tgid: json['tgid'],
      tuid: json['tuid'],
      tcgid: json['tcgid'],
      tName: json['tName'],
      tLocalization: json['tLocalization'],
      tTime: json['tTime'],
      tBudget: json['tBudget'],
      tStatus: json['tStatus'],
    );
  }
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

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late Future<List<Tasks>> futureTasks;
  late Future<List<Categories>> futureCategories;
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
    futureTasks = fetchTasks();
    futureCategories = fetchCategories();
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
                    "Taski",
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
          //if (isEditEnabled) EditDataWidget(category: category),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: const <Widget>[
                Expanded(child: Text("Nazwa")),
                Expanded(child: Text("Data")),
                Expanded(child: Text("Lokalizacja")),
                Expanded(child: Text("Budżet")),
                Expanded(child: Text("Status")),
              ],
            ),
          ),
          Center(
            child: FutureBuilder<List<Tasks>>(
              future: futureTasks,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: 100,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 8.0,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Color.fromRGBO(225, 225, 225, 1),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      snapshot.data![index].tName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      snapshot.data![index].tTime,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      snapshot.data![index].tLocalization,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      snapshot.data![index].tBudget.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      snapshot.data![index].tStatus.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  // EditButton(
                                  //   category: snapshot.data![index],
                                  // ),
                                  // DeleteButton(
                                  //   cgid: snapshot.data![index].cgid,
                                  // ),
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
