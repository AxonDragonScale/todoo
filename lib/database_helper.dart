import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/task.dart';
import 'models/todo.dart';

class DatabaseHelper {
  Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todoo.db'),
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description TEXT)');
        await db.execute('CREATE TABLE todos(id INTEGER PRIMARY KEY, taskId INTEGER, title TEXT, isDone INTEGER)');

        return db;
      },
      version: 1,
    );
  }

  Future<int> insertTask(Task task) async {
    int taskId;

    Database db = await database();
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace).then((value) => {
      taskId = value
    });

    return taskId;
  }

  Future<void> deleteTask(int taskId) async {
    Database db = await database();
    await db.rawDelete("DELETE FROM tasks WHERE id = '$taskId'");
    await db.rawDelete("DELETE FROM todos WHERE taskId = '$taskId'");
  }

  Future<void> updateTaskTitle(int taskId, String newTitle) async {
    Database db = await database();
    await db.rawUpdate("UPDATE tasks SET title = '$newTitle' WHERE id = '$taskId'");
  }

  Future<void> updateTaskDescription(int taskId, String description) async {
    Database db = await database();
    await db.rawUpdate("UPDATE tasks SET description = '$description' WHERE id = '$taskId'");
  }

  Future<void> insertTodo(Todo todo) async {
    Database db = await database();
    await db.insert('todos', todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTodoState(int todoId, int isDone) async {
    Database db = await database();
    await db.rawUpdate("UPDATE todos SET isDone = $isDone WHERE id = '$todoId'");
  }

  Future<List<Task>> getTasks() async {
    Database db = await database();
    List<Map<String, dynamic>> taskMap = await db.query('tasks');
    return List.generate(taskMap.length, (index) {
      return Task(
        id: taskMap[index]['id'],
        title: taskMap[index]['title'],
        description: taskMap[index]['description'],
      );
    });
  }

  Future<List<Todo>> getTodos(int taskId) async {
    Database db = await database();
    List<Map<String, dynamic>> todoMap = await db.rawQuery('SELECT * FROM todos WHERE taskId = $taskId');
    return List.generate(todoMap.length, (index) {
      return Todo(
        id: todoMap[index]['id'],
        taskId: todoMap[index]['taskId'],
        title: todoMap[index]['title'],
        isDone: todoMap[index]['isDone'],
      );
    });
  }
}