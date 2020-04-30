import 'package:flutter/material.dart';
import 'package:todoapp/model/todo.dart';
import 'package:todoapp/util/dbhelper.dart';
import 'package:intl/intl.dart';

final List<String> choices = const <String> [
  "Save and return",
  "Discard and return",
  "Delete and return"
];

const menuSave = "Save and return";
const menuDiscard = "Discard and return";
const menuDelete = "Delete and return";

DbHelper dbHelper = DbHelper();

class TodoDetail extends StatefulWidget {
  final Todo _todo;

  TodoDetail(this._todo);

  @override
  State<StatefulWidget> createState() => TodoDetailState(this._todo);
}

class TodoDetailState extends State {
  Todo _todo;

  TodoDetailState(this._todo);

  final _priorities = ['High', 'Medium', 'Low'];
  String _priority = 'Low';
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = _todo.title;
    descriptionController.text = _todo.description;
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
      appBar: AppBar(
        title: Text(_todo.title),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: select,
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 10, right: 10),
        child: ListView(children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController,
                  //onChanged: (value) => updateTitle(),
                  decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: descriptionController,
                  //onChanged: (value) => updateDescription(),
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                ),
              ),
              ListTile(
                title: DropdownButton<String>(
                  items: _priorities.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (String val) {
                    updatePriority(val);
                  },
                  value: retrievePriority(_todo.priority),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }


  void select(String value) async {

    switch(value) {
      case menuSave:
        save();
        break;
      case menuDiscard:
        Navigator.pop(context,true);
        break;
      case menuDelete:
        delete();
        break;
    }
  }

  void save() async {
    _todo.date = new DateFormat.yMd().format(DateTime.now());
    updateTitle();
    updateDescription();
    if(_todo.id != null) {
      await dbHelper.updateTodo(_todo);
    }
    else {
      await dbHelper.insertTodo(_todo);
    }
    Navigator.pop(context,true);
  }

  void delete() async {
    int result;
    if(_todo.id != null) {
      result = await dbHelper.deleteTodo(_todo.id);
    }
    if(result != 0) {
      AlertDialog alertDialog = AlertDialog(
        title: Text("Delete to do"),
        content: Text("The todo has been deleted"),
      );
      showDialog(
          context: context,
          builder: (_) => alertDialog
      );
    }
    Navigator.pop(context,true);
  }

  void updatePriority(String value) {
    switch(value) {
      case "High" :
        _todo.priority =1;
        break;
      case "Medium":
        _todo.priority =2;
        break;
      case "Low":
        _todo.priority =3;
        break;
    }
    setState(() {
      _priority=value;
    });
  }

  String retrievePriority(int priority) {
    switch(priority) {
      case 1 :
        return "High";
        break;
      case 2:
        return "Medium";
        break;
      case 3:
        return "Low";
        break;
      default:
        return "Low";
        break;
    }
  }

  void updateTitle() {
    _todo.title = titleController.text;
  }
  void updateDescription() {
    _todo.description = descriptionController.text;
  }

}
