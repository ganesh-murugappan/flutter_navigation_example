import 'package:flutter/material.dart';
import 'package:todoapp/model/todo.dart';
import 'package:todoapp/screens/tododetail.dart';
import 'package:todoapp/util/dbhelper.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
}

class TodoListState extends State {

  DbHelper dbHelper = DbHelper();
  List<Todo> todoList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if(todoList == null ) {
      todoList = List<Todo>();
      //TODO : Figure how to make db refresh on pop back 
      getData();
    }

    return Scaffold(
      body: todoListItems(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToDetail(Todo("","",3)),
        tooltip: "Add new ToDO",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView todoListItems() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          Todo todo = this.todoList[position];
          return Card(
            color: Colors.white,
            elevation: 5.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(todo.priority),
                child: Text(todo.priority.toString()),
              ),
              title: Text(todo.title),
              subtitle: Text(todo.dueDate),
              onTap: () {
                debugPrint(todo.id.toString());
                navigateToDetail(todo);
              },
            ),
          );
        }
    );
  }

  Color getPriorityColor(int priority) {
    switch(priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.orange;
        break;
      case 3:
        return Colors.green;
        break;
      default:
        return Colors.green;
    }
  }

  void getData() async {
    List<Todo> localTodoList = List<Todo> ();
    var todosFuture = await dbHelper.getTodos();
    count = todosFuture.length;
    for(int i=0 ; i < count; i++) {
      localTodoList.add(Todo.fromObject(todosFuture[i]));
      debugPrint(localTodoList[i].title);
    }
    setState(() {
      todoList = localTodoList;
      count = count;
      debugPrint("todos fetched from db with getData with size [ $count ]");
    });
  }

  void navigateToDetail(Todo todo) async {
    bool result = await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return TodoDetail(todo);
        }
      )
    );

  }
}
