import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:project_test_asia_quest_indonesia/models/de_helper.dart';

import '../constans/constan.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = false;

//Get All data from Databbase
  void _refreshData() async {
    final data = await SqlHelper.getAllData();
    setState(
      () {
        _isLoading = true;
        _allData = data;
        _isLoading = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

//Create Data
  void inputData(int? id) async {
    if (id != null) {
      final existingData =
          _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Title"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Description"),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  }
                  if (id != null) {
                    await _updateData(id);
                  }

                  _titleController.text = '';
                  _descController.text = '';

                  //Hide botton sheet
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(19),
                  child: Text(
                    id == null ? "Add Data" : "Update",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

//Add Data
  Future<void> _addData() async {
    await SqlHelper.createData(_titleController.text, _descController.text);
    _refreshData();
  }

//Update Data
  Future<void> _updateData(int id) async {
    await SqlHelper.updateData(id, _titleController.text, _descController.text);
    _refreshData();
  }

//Delete Data
  void _deleteData(int id) async {
    await SqlHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Data Deleted"),
      ),
    );
    _refreshData();
  }

//View
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        title: const Text(
          'Book List',
          style: TextStyle(color: white),
        ),
      ),
      body: Container(
        color: green,
        child: Container(
          padding: const EdgeInsets.only(top: 15),
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                    25) //                 <--- border radius here
                ),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                      itemCount: _allData.length,
                      itemBuilder: (contex, index) => InkWell(
                            onTap: () async {},
                            child: Card(
                              // color: green,
                              child: ListTile(
                                title: ListTile(
                                  title: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Text(
                                      _allData[index]['title'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        // color: white
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    _allData[index]['desc'],
                                    // style: const TextStyle(color: white),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          inputData(_allData[index]['id']);
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _deleteData(_allData[index]['id']);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => inputData(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
