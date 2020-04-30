import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:todoapp/model/todo.dart';

class DbHelper {

  String tblTodo = "todo";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  static final DbHelper _dbHelper = DbHelper._internal();

  DbHelper._internal() ;

  factory DbHelper() {
    return _dbHelper;
  }

  static Database _db;

  Future<Database> get db async {
    if(_db == null) {
      _db = await initDb();
    }
    return _db;
  }

  // on another thread as async method
  Future<Database> initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "todo.db";
    var dbTodoDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbTodoDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute("CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY, $colTitle TEXT,"
        " $colDescription TEXT, $colPriority INTEGER, $colDate TEXT) ");
  }

  // on another thread - async method
  Future<int> insertTodo(Todo todo) async {
    // can't move without db - await
    Database db = await this.db;
    // can't move without result - await
    var result = await db.insert(tblTodo, todo.toMap());
    return result;
  }

  Future<List> getTodos() async {
    Database database = await this.db;
    var result = await database.rawQuery("SELECT * FROM $tblTodo order by $colPriority ASC");
    return result;
  }

  Future<int> countTodos() async {
    Database database = await this.db;
    var count = Sqflite.firstIntValue(await database.rawQuery("SELECT COUNT(*) FROM $tblTodo"));
    return count;
  }
  
  Future<int> updateTodo(Todo todo) async {
    Database database = await this.db;
    var result = await database.update(tblTodo, todo.toMap(), where: "$colId = ? ", whereArgs: [todo.id]);
    return result;
  }

  Future<int> deleteTodo(int todoId) async {
    Database database = await this.db;
    var result = await database.rawDelete("DELETE FROM $tblTodo WHERE $colId = $todoId");
    return result;
  }

}