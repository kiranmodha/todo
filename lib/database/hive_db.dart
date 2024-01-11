//import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do/models/todo_item.dart';

class HiveDb {
  //late Box<TodoItem> _todoBox;
  Box<TodoItem> _todoBox = Hive.box<TodoItem>('todos');

  Future<void> openBox() async {
    _todoBox = await Hive.openBox<TodoItem>('todos');
  }

  // void addTodoItem(TodoItem item) {
  //   _todoBox.add(item);
  //    FirebaseFirestore.instance
  //                         .collection('todo')
  //                         .add(item.toJson());
  // }

  void addTodoItem(TodoItem item) {
    _todoBox.add(item);
    FirebaseFirestore.instance
        .collection('todo')
        .add(item.toJsonForCloud())
        .then((DocumentReference document) {
      item.documentID = document.id;
      item.isSyncedWithCloud = true;
      _todoBox.putAt(_todoBox.values.toList().indexOf(item), item);
    });
  }

  // void updateTodoItem(TodoItem oldItem, TodoItem newItem) {
  //   final int index = _todoBox.values.toList().indexOf(oldItem);
  //   if (index != -1) {
  //     _todoBox.putAt(index, newItem);
  //   }
  // }

  void updateTodoItem(TodoItem oldItem, TodoItem newItem) {
    final int index = _todoBox.values.toList().indexOf(oldItem);
    if (index != -1) {
      newItem.isSyncedWithCloud = false;
      _todoBox.putAt(index, newItem);

      // update firebase database
      if (oldItem.documentID != null && oldItem.documentID!.isNotEmpty) {
        FirebaseFirestore.instance
            .collection('todo')
            .doc(oldItem.documentID)
            .update(newItem.toJsonForCloud())
            .then((value) {
          newItem.isSyncedWithCloud = true;
          _todoBox.putAt(index, newItem);
        });
      }
    }
  }

  void updateTodoItemByKey(int key, TodoItem newItem) {
    if (_todoBox.containsKey(key)) {
      newItem.isSyncedWithCloud = false;
      _todoBox.put(key, newItem);

      // update firebase database
      if (newItem.documentID != null && newItem.documentID!.isNotEmpty) {
        FirebaseFirestore.instance
            .collection('todo')
            .doc(newItem.documentID)
            .update(newItem.toJsonForCloud())
            .then((value) {
          newItem.isSyncedWithCloud = true;
          _todoBox.put(key, newItem);
        });
      }
    }
  }

  void deleteTodoItem(TodoItem item) {
    final int index = _todoBox.values.toList().indexOf(item);
    if (index != -1) {
      _todoBox.deleteAt(index);
    }
  }

  void deleteTodoItemByKey(int key) {
    _todoBox.delete(key);
  }

  List<TodoItem> getAllTodoItems() {
    return _todoBox.values.toList();
  }

  List<TodoItem> getActiveTodoItems() {
    return _todoBox.values
        // .where((todoItem) => todoItem.isDeleted == true )
        // .where((todoItem) =>
        //     todoItem.isDeleted == false || todoItem.isDeleted == null)

        .where((todoItem) =>
            todoItem.isDone == false &&
            (todoItem.isDeleted == false || todoItem.isDeleted == null))
        .toList();
  }

  List<TodoItem> getDeletedTodoItems() {
    return _todoBox.values
        .where((todoItem) => todoItem.isDeleted == true)
        .toList();
  }

  List<TodoItem> getCompletedTodoItems() {
    return _todoBox.values
        .where((todoItem) => todoItem.isDone == true)
        .toList();
  }

  TodoItem? getTodoItemByKey(int key) {
    return _todoBox.get(key);
  }

  TodoItem? getTodoItemAt(int index) {
    return _todoBox.getAt(index);
  }

  Future<void> close() async {
    await _todoBox.close();
  }

  // List<TodoItem> getTodoItemsByTextContain(String text) {
  //   var filteredItems = _todoBox.values
  //       .where((todoItem)
  //            => todoItem.toBeDone.contains(text))
  //       .toList();
  //   return filteredItems;
  // }

  List<TodoItem> getTodoItemsByTextContain(String text) {
    var filteredItems = _todoBox.values
        .where((todoItem) =>
            todoItem.toBeDone.contains(text) &&
            (todoItem.isDeleted == false || todoItem.isDeleted == null))
        .toList();
    return filteredItems;
  }
}
