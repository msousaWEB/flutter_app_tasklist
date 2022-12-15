import 'package:flutter/material.dart';
import 'package:task_list/repositories/task_repository.dart';
import 'package:task_list/widgets/task_list_item.dart';
import '../models/task.dart';

class TaskListPage extends StatefulWidget {
  TaskListPage({Key? key}) : super(key: key);

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TextEditingController taskController = TextEditingController();
  final TaskRepository taskRepository = TaskRepository();

  List<Task> tasks = [];

  Task? deletedTask;
  int? deletedPosition;

  String? errorText;

  @override
  void initState() {
    super.initState();
    taskRepository.getTaskList().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taskController,
                        decoration: InputDecoration(
                            labelText: 'Nova Tarefa',
                            labelStyle: TextStyle(
                                fontSize: 16, color: Color(0xff7954A1)),
                            hintText: 'Descreva a tarefa...',
                            errorText: errorText,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3, color: Color(0xff7954A1))),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3, color: Color(0xff7954A1))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 3, color: Color(0xff7954A1)))),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          addNewTask();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff7954A1),
                          padding: EdgeInsets.all(12),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 35,
                        )),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Task task in tasks)
                        TaskListItem(
                          task: task,
                          deleteTask: deleteTask,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      'Você possui ${tasks.length} tarefas pendentes.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )),
                    SizedBox(
                      width: 1,
                    ),
                    ElevatedButton(
                      onPressed: confirmDeleteAll,
                      style:
                          ElevatedButton.styleFrom(primary: Color(0xff7954A1)),
                      child: Text('Limpar Tudo'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void deleteTask(Task task) {
    deletedTask = task;
    deletedPosition = tasks.indexOf(task);

    setState(() {
      tasks.remove(task);
    });
    taskRepository.saveTaskList(tasks);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Tarefa "${task.title}" removida com sucesso!',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      backgroundColor: Color(0xff7954A1),
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: Colors.white,
        onPressed: () {
          setState(() {
            tasks.insert(deletedPosition!, deletedTask!);
          });
          taskRepository.saveTaskList(tasks);
        },
      ),
      duration: const Duration(seconds: 3),
    ));
  }

  void addNewTask() {
    String text = taskController.text;

    if(text.isEmpty) {
      setState(() {
        errorText = 'Escreva uma tarefa!';
      });
      return;
    }

    setState(() {
      Task newTask =
      Task(title: text, dateTime: DateTime.now());
      tasks.add(newTask);
      errorText = null;
    });

    taskController.clear();
    taskRepository.saveTaskList(tasks);
    FocusScope.of(context).unfocus();
  }

  void confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Tudo', style: TextStyle(color: Color(0xff7954A1),),),
        content: Text('Tem certeza que deseja remover todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(primary: Colors.grey),
            child: Text('Cancelar', style: TextStyle(color: Color(0xff7954A1),),)
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAllTasks();
              },
              style: TextButton.styleFrom(primary: Colors.red[400]),
              child: Text('Limpar')
          )
        ],
      ),
    );
  }

  void deleteAllTasks() {
    setState(() {
      tasks.clear();
    });
    taskRepository.saveTaskList(tasks);
  }
}
