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

  void addTodoItem(TodoItem todoItem) {
    _todoBox.add(todoItem);
    FirebaseFirestore.instance
        .collection('todo')
        .add(todoItem.toJsonForCloud())
        .then((DocumentReference document) {
      todoItem.documentID = document.id;
      todoItem.isSyncedWithCloud = true;
      _todoBox.putAt(_todoBox.values.toList().indexOf(todoItem), todoItem);
    });
  }

  void updateTodoItem(TodoItem oldTodoItem, TodoItem newTodoItem) {
    final int index = _todoBox.values.toList().indexOf(oldTodoItem);
    if (index != -1) {
      newTodoItem.isSyncedWithCloud = false;
      _todoBox.putAt(index, newTodoItem);

      // update firebase database
      if (oldTodoItem.documentID != null &&
          oldTodoItem.documentID!.isNotEmpty) {
        FirebaseFirestore.instance
            .collection('todo')
            .doc(oldTodoItem.documentID)
            .update(newTodoItem.toJsonForCloud())
            .then((value) {
          newTodoItem.isSyncedWithCloud = true;
          _todoBox.putAt(index, newTodoItem);
        });
      }
    }
  }

  void updateTodoItemByKey(int key, TodoItem todoItem) {
    if (_todoBox.containsKey(key)) {
      todoItem.isSyncedWithCloud = false;
      _todoBox.put(key, todoItem);

      // update firebase database
      if (todoItem.documentID != null && todoItem.documentID!.isNotEmpty) {
        FirebaseFirestore.instance
            .collection('todo')
            .doc(todoItem.documentID)
            .update(todoItem.toJsonForCloud())
            .then((value) {
          todoItem.isSyncedWithCloud = true;
          _todoBox.put(key, todoItem);
        });
      }
    }
  }

  void deleteTodoItem(TodoItem todoItem) {
    final int index = _todoBox.values.toList().indexOf(todoItem);
    if (index != -1) {
      _todoBox.deleteAt(index);
    }
  }

  bool deleteTodoItemByKey(int key) {
    final TodoItem? todoItem = _todoBox.get(key);
    if (todoItem != null &&
        todoItem.documentID != null &&
        todoItem.documentID!.isNotEmpty) {
      try {
        FirebaseFirestore.instance
            .collection('todo')
            .doc(todoItem.documentID)
            .delete();
        _todoBox.delete(key);
      } catch (e) {
        print("Error in deleting cloud record: $e");
        return false;
      }
    } else {
      //_todoBox.delete(key);
      return false;
    }
    return true;
  }

// Future<bool> deleteTodoItemByKey(int key) async {
//   final TodoItem? item = _todoBox.get(key);
//   if (item != null && item.documentID != null && item.documentID!.isNotEmpty) {
//     try {
//       await FirebaseFirestore.instance
//           .collection('todo')
//           .doc(item.documentID)
//           .delete();
//       _todoBox.delete(key);
//     } catch (e) {
//       print("Error in deleting cloud record: $e");
//       return false;
//     }
//   } else {
//     //_todoBox.delete(key);
//     return false;
//   }
//   return true;
// }

  // Future<void> syncDataFromFirebase() async {
  //   // Check if local database is empty
  //   if (_todoBox.isEmpty) {
  //     try {
  //       // Fetch data from Firebase
  //       QuerySnapshot querySnapshot =
  //           await FirebaseFirestore.instance.collection('todo').get();

  //       // If data found on the cloud
  //       if (querySnapshot.docs.isNotEmpty) {
  //         // Populate local database
  //         for (var doc in querySnapshot.docs) {
  //           TodoItem item = TodoItem.fromJson(doc.data());

  //           _todoBox.put(item.key, item);
  //         }
  //       }
  //     } catch (e) {
  //       print('Error in fetching data from Firebase: $e');
  //     }
  //   }
  // }

  Future<void> syncDataFromFirebase() async {
    // Check if local database is empty
    if (_todoBox.isEmpty) {
      try {
        // Fetch data from Firebase
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('todo').get();

        // If data found on the cloud
        if (querySnapshot.docs.isNotEmpty) {
          // Populate local database
          for (var doc in querySnapshot.docs) {
            try {
              // Ensure that all required fields are present in the Firestore document
              var data = doc.data() as Map<String, dynamic>?;

              if (data != null && data.isNotEmpty) {
                TodoItem item = TodoItem.fromJson(data);
                item.documentID = doc.reference.id;
                _todoBox.add(item);
              }
            } catch (e) {
              print('Error converting Firestore data to TodoItem: $e');
            }
          }
        }
      } catch (e) {
        print('Error in fetching data from Firebase: $e');
      }
    }
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

  List<TodoItem> getTodoItemsByTextContain(String text) {
    var filteredItems = _todoBox.values
        .where((todoItem) =>
            todoItem.toBeDone.contains(text) &&
            (todoItem.isDeleted == false || todoItem.isDeleted == null))
        .toList();
    return filteredItems;
  }
}
