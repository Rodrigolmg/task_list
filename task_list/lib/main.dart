import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main(){
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.blueAccent,
        primaryColor: Colors.blueAccent
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _toDoList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  @override
  void initState(){
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  final newTaskController = TextEditingController();

  void _addToDo(){
    setState(() {
      Map<String, dynamic> newTask = Map();
      newTask["title"] = newTaskController.text;
      newTask["ok"] = false;
      _toDoList.add(newTask);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Lista de Tarefas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: newTaskController,
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(
                            color: Colors.blueAccent
                        )
                    ),
                  ),
                ),
                RaisedButton(
                  onPressed: _addToDo,
                  color: Colors.blueAccent,
                  child: Text("Add"),
                  textColor: Colors.white,
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder: buildItem),
          )
        ],
      ),
    );
  }

  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try{
      final file = await _getFile();
      return file.readAsStringSync();
    }catch(e){
      return null;
    }
  }

  Widget buildItem(context, index) {
    return Dismissible(
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved["title"]} removida!"),
            action: SnackBarAction(label: "Desfazer",
                onPressed: (){
                  setState(() {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }
            ),
            duration: Duration(seconds: 5),
          );

          Scaffold.of(context).showSnackBar(snack);
        });
      },
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        onChanged: (check){
          setState(() {
            _toDoList[index]["ok"] = check;
            _saveData();
          });
        },
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(
              _toDoList[index]["ok"] ? Icons.check : Icons.error
          ),
        ),
      ),
    );
  }
}



//path_provider: ^1.1.0
