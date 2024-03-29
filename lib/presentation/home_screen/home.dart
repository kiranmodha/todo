import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final user = FirebaseAuth.instance.currentUser;

  SelectionMode selectionMode = SelectionMode.all;
  List<TodoItem> toDoList = [];
  dynamic currentKey;
  HiveDb db = HiveDb();
  String taskTitle = 'Task';

  @override
  void initState() {
    super.initState();
    db.openBox();
    db.syncDataFromFirebase().then((value) => populateList());
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

  void _showTaskDialog(TodoItem? originalTodoItem, int mode) {
    TodoItem todoItem = mode == 0
        ? TodoItem(
            toBeDone: "", isDone: false, dueDate: DateTime.now(), note: "")
        : originalTodoItem!;
    String title = mode == 0 ? "Add Task" : "Edit Task";

    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(title: title, toDoItem: todoItem);
        }).then((returnedTodoItem) {
      if (returnedTodoItem != null) {
        mode == 0
            ? db.addTodoItem(returnedTodoItem)
            : db.updateTodoItemByKey(originalTodoItem!.key, returnedTodoItem);
        populateList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      drawer: NavigationDrawer(user: user!),
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
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      elevation: 0,
      title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
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
              icon: const Icon(
                Icons.info,
                size: 20,
              ),
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

  ConvexAppBar _buildBottomNavigationBar(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.react,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      activeColor: Theme.of(context).colorScheme.primary,
      // animationDuration: const Duration(milliseconds: 200),
      onTap: (index) {
        setState(() {
          selectionMode = SelectionMode.values[index];
          populateList();
        });
      },
      items: [
        TabItem(
            icon: Icon(
          Icons.home,
          color: Theme.of(context).colorScheme.onPrimary,
        )),
        TabItem(
            icon: Icon(
          Icons.done,
          color: Theme.of(context).colorScheme.onPrimary,
        )),
        TabItem(
            icon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onPrimary,
        )),
        TabItem(
            icon: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onPrimary,
        )),
      ],
    );
  }


  CurvedNavigationBar _buildBottomNavigationBar1(BuildContext context) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: searchTextController,
        style: const TextStyle(fontSize: 18),
        onChanged: (value) {
          populateList();
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
          hintText: "Search",
          labelText: "Search",
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Expanded(
      //without Expanded widget, listview will not be visible
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
                for (TodoItem todoItem in toDoList)
                  _buildToDoItem(context, todoItem)
              ],
            ),
    );
  }

  Padding _buildToDoItem(BuildContext context, TodoItem todoItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      // ignore: avoid_unnecessary_containers
      child: Container(
        child: ListTile(
          onTap: () {
            _showTaskDialog(todoItem, 1); // 1 - edit
          },
          splashColor: Theme.of(context).colorScheme.primaryContainer,
          tileColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Checkbox(
            value: todoItem.isDone,
            onChanged: (bool? newValue) {
              db.updateTodoItemByKey(
                  todoItem.key, todoItem.copyWith(isDone: newValue!));
              populateList();
            },
          ),
          trailing: Wrap(
            spacing: 12,
            children: [
              deleteButton(context, todoItem),
              Visibility(
                visible: todoItem.isDeleted ?? false,
                child: recycleButton(context, todoItem),
              )
            ],
          ),
          title: Text(
            todoItem.toBeDone,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 16,
                decoration:
                    todoItem.isDone ? TextDecoration.lineThrough : null),
          ),
        ),
      ),
    );
  }

  IconButton recycleButton(BuildContext context, TodoItem todoItem) {
    return IconButton(
        icon: Icon(Icons.restore_from_trash,
            color: Theme.of(context).colorScheme.primary, size: 20),
        onPressed: () {
          db.updateTodoItemByKey(
              todoItem.key, todoItem.copyWith(isDeleted: false));
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

  IconButton deleteButton(BuildContext context, TodoItem todoItem) {
    String text =
        todoItem.isDeleted ?? false ? 'delete forever' : 'send to recylce bin';
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
                    if (todoItem.isDeleted ?? false) {
                      db.deleteTodoItemByKey(todoItem.key);
                    } else {
                      db.updateTodoItemByKey(
                          todoItem.key, todoItem.copyWith(isDeleted: true));
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

class NavigationDrawer extends StatelessWidget {
  final User user;

  const NavigationDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user.displayName ?? ""),
            accountEmail: Text(user.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ""),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout_sharp),
            title: const Text('Sign Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
