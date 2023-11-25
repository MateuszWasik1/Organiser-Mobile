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

//Add / Edit

Future<http.Response> editTask(Tasks task) async {
  final http.Response response = await http.post(
      Uri.parse('https://localhost:44393/api/Tasks/Save'),
      body: task);

  if (response.statusCode == 200) {
  } else {
    Exception('Dodanie taska zakończyło się niepowodzeniem');
  }
  return response;
}

//DELETE
Future<http.Response> deleteTask(String tgid) async {
  final http.Response response = await http
      .delete(Uri.parse('https://localhost:44393/api/Tasks/Delete/$tgid'));

  if (response.statusCode == 200) {
    fetchCategories();
  } else {
    Exception('Usunięcie tasku zakończyło się niepowodzeniem');
  }
  return response;
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
  // late Categories category = Categories(
  //     cid: 0,
  //     cgid: "",
  //     cName: "",
  //     cStartDate: DateTime.now().toString(),
  //     cEndDate: DateTime.now().toString(),
  //     cBudget: 0);
  late Tasks task = Tasks(
    tid: 0, 
    tgid: "", 
    tuid: 0, 
    tcgid: "", 
    tName: "", 
    tLocalization: "", 
    tTime: DateTime.now().toString(), 
    tBudget: 0, 
    tStatus: 0
  );

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
          if (isEditEnabled) EditDataWidget(task: task),
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
                                  DeleteButton(
                                    tgid: snapshot.data![index].tgid,
                                  ),
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
  const EditButton({super.key, required this.task});

  final Tasks task;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edytuj taska',
          onPressed: () {
            var tasksState =
                context.findAncestorStateOfType<_TasksPageState>();
            tasksState?.setState(() {
              tasksState.isEditEnabled = true;
              tasksState.task = task;
            });
          },
        ),
      ],
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.tgid});

  final String tgid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Usuń Task',
            onPressed: () => deleteTask(tgid)),
      ],
    );
  }
}

//EditWidget
// ignore: must_be_immutable
class EditDataWidget extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var task;

  EditDataWidget({Key? key, this.task}) : super(key: key);

  @override
  State<EditDataWidget> createState() => _EditDataWidgetState();
}

class _EditDataWidgetState extends State<EditDataWidget> {
  var tName = "";
  var tTime = DateTime.now();
  var tLocalization = "";
  var tBudget = 0;

  void _datePicker(BuildContext context) async {
    DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(widget.task.tTime),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        DateTime.now();

    tTime = pickedDate;
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
                initialValue: widget.task.tName,
                decoration: const InputDecoration(labelText: 'Nazwa'),
                onChanged: (value) => tName = value,
              ),
            ),
            ListTile(
              title: const Text('Data'),
              subtitle: Text(
                '${DateTime.parse(widget.task.tTime).toLocal()}'
                    .split(' ')[0],
              ),
              onTap: () {
                _datePicker(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                  initialValue: widget.task.tLocalization.toString(),
                  decoration: const InputDecoration(labelText: 'Lokalizacja'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    tLocalization = value;
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                  initialValue: widget.task.tBudget.toString(),
                  decoration: const InputDecoration(labelText: 'Budżet'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    tBudget = int.tryParse(value) ?? 0;
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
                      var taskToSave = Tasks(
                          tid: widget.task.tid,
                          tgid: widget.task.tgid,
                          tuid: widget.task.tuid,
                          tcgid: widget.task.tcgid,
                          tName: tName,
                          tLocalization: tLocalization,
                          tTime: tTime.toString(),
                          tBudget: tBudget,
                          tStatus: 0,
                        );

                      editTask(taskToSave);
                    },
                    child: const Text('Zapisz'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      var state = context
                          .findAncestorStateOfType<_TasksPageState>();
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