import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
//import 'package:to_do/core/utils/custom_imageview.dart';
//import 'package:to_do/core/utils/image_constants.dart';
import 'package:to_do/database/hive_db.dart';
import 'package:to_do/presentation/home_screen/dialog_box.dart';
import 'package:to_do/models/todo_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

enum SelectionMode { all, completed, search, deleted }

class _HomeState extends State<Home> {
  final searchTextController = TextEditingController();
  SelectionMode selectionMode = SelectionMode.all;
  List<TodoItem> toDoList = [];
  dynamic currentKey;
  HiveDb db = HiveDb();
  String taskTitle = 'Task';

  @override
  void initState() {
    super.initState();
    db.openBox();
    populateList();
  }

  void populateList() {
    setState(() {
      switch (selectionMode) {
        case SelectionMode.all:
          toDoList = db.getActiveTodoItems();
          taskTitle = 'Active Task';
          break;
        case SelectionMode.deleted:
          toDoList = db.getDeletedTodoItems();
          taskTitle = 'Deleted Task';
          break;
        case SelectionMode.completed:
          toDoList = db.getCompletedTodoItems();
          taskTitle = 'Completed Task';
          break;
        case SelectionMode.search:
          toDoList = db.getTodoItemsByTextContain(searchTextController.text);
          taskTitle = 'Search Result';
          break;
      }
    });
  }

  void _showTaskDialog(TodoItem? item, int mode) {
    TodoItem todoItem = mode == 0
        ? TodoItem(
            toBeDone: "", isDone: false, dueDate: DateTime.now(), note: "")
        : item!;
    String title = mode == 0 ? "Add Task" : "Edit Task";

    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(title: title, toDoItem: todoItem);
        }).then((obj) {
      if (obj != null) {
        mode == 0
            ? db.addTodoItem(obj)
            : db.updateTodoItemByKey(item!.key, obj);
        populateList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: Visibility(
          visible: selectionMode == SelectionMode.all,
          child: _buildFloatingActionButton()),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(Icons.menu,
            color: Theme.of(context).colorScheme.onPrimary, size: 20),
        Text(
          'To Do',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary),
        ),
        IconButton(
          onPressed: () => {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Programmed by Kiran Modha'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            )
          },
          icon: Icon(Icons.info,
              color: Theme.of(context).colorScheme.onPrimary, size: 20),
        ),
      ]),
    );
  }

  Stack _buildBody(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Image.asset('assets/images/logo.png',
              height: 100,
              width: 150,
              opacity: const AlwaysStoppedAnimation(.4)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Column(
            children: [
              Visibility(
                  visible: selectionMode == SelectionMode.search,
                  child: _buildSearchBox(context)),
              _buildListView(context),
            ],
          ),
        )
      ],
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () => _showTaskDialog(null, 0),
      tooltip: 'Add New Task',
      child: const Icon(Icons.add),
    );
  }

  CurvedNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return CurvedNavigationBar(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      animationDuration: const Duration(milliseconds: 200),
      onTap: (index) {
        setState(() {
          selectionMode = SelectionMode.values[index];
          populateList();
        });
      },
      items: [
        Icon(
          Icons.home,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        Icon(
          Icons.done,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }

  Container _buildSearchBox(BuildContext context) {
    //final TextEditingController controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: searchTextController,
        style: const TextStyle(fontSize: 18),
        onChanged: (value) {
          // setState(() {
          //   toDoList = db.getTodoItemsByTextContain(value);
          // });
          populateList();
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
          // suffixIcon: IconButton(
          //     icon: const Icon(Icons.clear),
          //     onPressed: () {
          //       controller.clear();
          //     }),
          hintText: "Search",
          labelText: "Search",
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Expanded(
      //without this widget, listview will not be visible
      child: toDoList.isEmpty
          ? Center(
              child: Text("No Item Found",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
            )
          : ListView(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(taskTitle,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                ),
                for (TodoItem item in toDoList) _buildToDoItem(context, item)
              ],
            ),
    );
  }

  Padding _buildToDoItem(BuildContext context, TodoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      // ignore: avoid_unnecessary_containers
      child: Container(
        child: ListTile(
          onTap: () {
            _showTaskDialog(item, 1); // 1 - edit
          },
          splashColor: Theme.of(context).colorScheme.primaryContainer,
          tileColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Checkbox(
            value: item.isDone,
            onChanged: (bool? newValue) {
              db.updateTodoItem(item, item.copyWith(isDone: newValue!));
              // db.updateTodoItem(
              //     item,
              //     TodoItem(
              //         toBeDone: item.toBeDone,
              //         isDone: newValue!,
              //         dueDate: item.dueDate,
              //         note: item.note));
              setState(() {
                item.isDone = newValue;
              });
            },
          ),
          trailing: Wrap(
            //  mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              deleteButton(context, item),
              Visibility(
                  visible: item.isDeleted ?? false,
                  child: recycleButton(context, item))
            ],
          ),
          title: Text(item.toBeDone,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 16,
                  decoration: item.isDone ? TextDecoration.lineThrough : null)),
        ),
      ),
    );
  }

  IconButton recycleButton(BuildContext context, TodoItem item) {
    return IconButton(
        icon: Icon(Icons.restore_from_trash,
            color: Theme.of(context).colorScheme.primary, size: 20),
        onPressed: () {
          // TodoItem newItem = TodoItem(
          //     toBeDone: item.toBeDone,
          //     isDone: item.isDone,
          //     dueDate: item.dueDate,
          //     note: item.note,
          //     isDeleted: false);
          //item.isDeleted = true;
          db.updateTodoItem(item, item.copyWith(isDeleted: false));
          populateList();

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Item successfully recalled',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ));
        });
  }

  IconButton deleteButton(BuildContext context, TodoItem item) {
    String text =
        item.isDeleted ?? false ? 'delete forever' : 'send to recylce bin';
    return IconButton(
      icon: Icon(Icons.delete,
          color: Theme.of(context).colorScheme.primary, size: 20),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Are you sure to $text?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    if (item.isDeleted ?? false) {
                      db.deleteTodoItemByKey(item.key);
                    } else {
                      TodoItem newItem = TodoItem(
                          toBeDone: item.toBeDone,
                          isDone: item.isDone,
                          dueDate: item.dueDate,
                          note: item.note,
                          isDeleted: true);
                      db.updateTodoItem(item, newItem);
                    }
                    populateList();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
