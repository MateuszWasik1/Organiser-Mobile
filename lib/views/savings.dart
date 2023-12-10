import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//GET
Future<List<Savings>> fetchSavings() async {
  final response =
      await http.get(Uri.parse('https://localhost:44393/api/Savings'));

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    List<Savings> savings = [];

    for (var i in jsonResponse) {
      savings.add(Savings(
          sid: i['sid'],
          sgid: i['sgid'],
          sAmount: i['sAmount'],
          sTime: i['sTime'],
          sOnWhat: i['sOnWhat'],
          sWhere: i['sWhere']));
    }
    return savings;
  } else {
    throw Exception('Ładowanie oszczędności się nie powiodło');
  }
}

//Add / Edit

Future<http.Response> editSaving(Savings saving) async {
  final http.Response response = await http.post(
      Uri.parse('https://localhost:44393/api/Savings/Save'),
      body: saving);

  if (response.statusCode == 200) {
  } else {
    Exception('Edycja oszczędności zakończyło się niepowodzeniem');
  }
  return response;
}

//DELETE

Future<http.Response> deleteSaving(String sgid) async {
  final http.Response response = await http
      .delete(Uri.parse('https://localhost:44393/api/Savings/Delete/$sgid'));

  if (response.statusCode == 200) {
    fetchSavings();
  } else {
    Exception('Usunięcie oszczędności zakończyło się niepowodzeniem');
  }
  return response;
}

class Savings {
  final int sid;
  final String sgid;
  final double sAmount;
  final String sTime;
  final String sOnWhat;
  final String sWhere;

  const Savings({
    required this.sid,
    required this.sgid,
    required this.sAmount,
    required this.sTime,
    required this.sOnWhat,
    required this.sWhere,
  });

  factory Savings.fromJson(Map<String, dynamic> json) {
    return Savings(
      sid: json['sid'],
      sgid: json['sgid'],
      sAmount: json['sAmount'],
      sTime: json['sTime'],
      sOnWhat: json['sOnWhat'],
      sWhere: json['sWhere'],
    );
  }
}

class SavingsPage extends StatefulWidget {
  const SavingsPage({Key? key}) : super(key: key);

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  late Future<List<Savings>> futureSavings;
  late bool isEditEnabled = false;
  late Savings saving = Savings(
      sid: 0,
      sgid: "",
      sAmount: 0,
      sTime: DateTime.now().toString(),
      sOnWhat: "",
      sWhere: "");

  @override
  void initState() {
    super.initState();
    futureSavings = fetchSavings();
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
                    "Oszczędności",
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
          if (isEditEnabled) EditDataWidget(saving: saving),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: const <Widget>[
                Expanded(child: Text("Kwota")),
                Expanded(child: Text("Data")),
                Expanded(child: Text("Na czym")),
                Expanded(child: Text("Gdzie")),
                Expanded(child: Text("")),
              ],
            ),
          ),
          Center(
            child: FutureBuilder<List<Savings>>(
              future: futureSavings,
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
                                      snapshot.data![index].sAmount.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      snapshot.data![index].sTime,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      snapshot.data![index].sOnWhat,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      snapshot.data![index].sWhere.toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  EditButton(
                                    saving: snapshot.data![index],
                                  ),
                                  DeleteButton(
                                    sgid: snapshot.data![index].sgid,
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
  const EditButton({super.key, required this.saving});

  final Savings saving;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edytuj Oszczędność',
          onPressed: () {
            var savingsState =
                context.findAncestorStateOfType<_SavingsPageState>();
            savingsState?.setState(() {
              savingsState.isEditEnabled = true;
              savingsState.saving = saving;
            });
          },
        ),
      ],
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.sgid});

  final String sgid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Usuń Oszczędność',
            onPressed: () => deleteSaving(sgid)),
      ],
    );
  }
}

//EditWidget
// ignore: must_be_immutable
class EditDataWidget extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var saving;

  EditDataWidget({Key? key, this.saving}) : super(key: key);

  @override
  State<EditDataWidget> createState() => _EditDataWidgetState();
}

class _EditDataWidgetState extends State<EditDataWidget> {
  var sAmount = 0.0;
  var sTime = DateTime.now();
  var sOnWhat = "";
  var sWhere = "";

  void _showDatePicker(BuildContext context) async {
    DateTime pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(widget.saving.sTime),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        ) ??
        DateTime.now();

    sTime = pickedDate;
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
                initialValue: widget.saving.sAmount.toString(),
                decoration: const InputDecoration(labelText: 'Kwota'),
                keyboardType: TextInputType.number,
                onChanged: (value)
                {
                  sAmount = double.tryParse(value) ?? 0.0;
                }
              ),
            ),
            ListTile(
              title: const Text('Data'),
              subtitle: Text(
                '${DateTime.parse(widget.saving.sTime).toLocal()}'
                    .split(' ')[0],
              ),
              onTap: () {
                _showDatePicker(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                initialValue: widget.saving.sOnWhat,
                decoration: const InputDecoration(labelText: 'Na czym'),
                onChanged: (value) => sOnWhat = value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                  initialValue: widget.saving.sWhere,
                  decoration: const InputDecoration(labelText: 'Gdzie'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => sWhere = value
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
                      var savingToSave = Savings(
                          sid: widget.saving.sid,
                          sgid: widget.saving.sgid,
                          sAmount: sAmount,
                          sTime: sTime.toString(),
                          sOnWhat: sOnWhat,
                          sWhere: sWhere);

                      editSaving(savingToSave);
                    },
                    child: const Text('Zapisz'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      var state = context
                          .findAncestorStateOfType<_SavingsPageState>();
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
