import 'package:flutter/material.dart';
import 'package:todoo/database_helper.dart';
import 'package:todoo/models/task.dart';
import 'package:todoo/models/todo.dart';
import 'package:todoo/views/todo_widget.dart';

class Taskpage extends StatefulWidget {
  final Task task;

  Taskpage({@required this.task});

  @override
  _TaskpageState createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  DatabaseHelper dbHelper = DatabaseHelper();

  int taskId = 0;
  String taskTitle = "";
  String taskDescription = "";

  FocusNode titleFocus;
  FocusNode descriptionFocus;
  FocusNode todoFocus;

  bool contentVisible = false;

  @override
  void initState() {
    if (widget.task != null) {
      contentVisible = true;

      taskId = widget.task.id;
      taskTitle = widget.task.title;
      taskDescription = widget.task.description;
    }

    titleFocus = FocusNode();
    descriptionFocus = FocusNode();
    todoFocus = FocusNode();

    super.initState();
  }


  @override
  void dispose() {
    titleFocus.dispose();
    descriptionFocus.dispose();
    todoFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Image(
                                  image: AssetImage(
                                      'assets/images/back_arrow_icon.png'
                                  )
                              ),
                            ),
                          ),
                          Expanded(
                              child: TextField(
                                focusNode: titleFocus,
                                onSubmitted: (value) async {
                                  if (value.isNotEmpty) {
                                    if (widget.task == null) {
                                      Task newTask = Task(title: value);
                                      taskId = await dbHelper.insertTask(newTask);
                                      setState(() {
                                        contentVisible = true;
                                        taskTitle = value;
                                      });
                                      print('New task created. TaskId: $taskId');
                                    } else {
                                      dbHelper.updateTaskTitle(taskId, value);
                                      print('Update existing task');
                                    }

                                    descriptionFocus.requestFocus();
                                  }
                                },
                                controller: TextEditingController()..text = taskTitle,
                                decoration: InputDecoration(
                                    hintText: 'Enter Task Title...',
                                    border: InputBorder.none),
                                style: TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF211551)),
                              ))
                        ],
                      ),
                    ),
                    Visibility(
                      visible: contentVisible,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          focusNode: descriptionFocus,
                          onSubmitted: (value) {
                            if (value.isNotEmpty && taskId != 0) {
                              dbHelper.updateTaskDescription(taskId, value);
                              setState(() {
                                taskDescription = value;
                              });
                              todoFocus.requestFocus();
                            }
                          },
                          maxLines: null,
                          keyboardType: TextInputType.text,
                          controller: TextEditingController()..text = taskDescription,
                          decoration: InputDecoration(
                              hintText: 'Enter the task description',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 24.0)
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: contentVisible,
                      child: FutureBuilder(
                        initialData: [],
                        future: dbHelper.getTodos(taskId),
                        builder: (context, snapshot) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    await dbHelper.updateTodoState(snapshot.data[index].id, snapshot.data[index].isDone == 0 ? 1 : 0);
                                    setState(() {});
                                  },
                                  child: TodoWidget(
                                    text: snapshot.data[index].title,
                                    isDone: snapshot.data[index].isDone == 1 ? true : false,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: contentVisible,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Container(
                              width: 20.0,
                              height: 20.0,
                              margin: EdgeInsets.only(right: 12.0),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                      color: Color(0xFF86829D), width: 1.5),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Image(
                                  image: AssetImage(
                                      'assets/images/check_icon.png'
                                  )
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                focusNode: todoFocus,
                                onSubmitted: (value) async {
                                  if (value.isNotEmpty && taskId != 0) {
                                    Todo newTodo = Todo(
                                      taskId: taskId,
                                      title: value,
                                      isDone: 0,
                                    );
                                    await dbHelper.insertTodo(newTodo);
                                    setState(() {});
                                    todoFocus.requestFocus();
                                    print('Creating new Todo');
                                  }
                                },
                                controller: TextEditingController()..text = "",
                                decoration: InputDecoration(
                                  hintText: 'Enter Todoo item',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: contentVisible,
                  child: Positioned(
                    bottom: 24.0,
                    right: 24.0,
                    child: GestureDetector(
                      onTap: () {
                        if (taskId != 0) {
                          dbHelper.deleteTask(taskId);
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFFE3577),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Image(
                          image: AssetImage('assets/images/delete_icon.png'),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
