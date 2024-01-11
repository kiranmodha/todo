import 'package:flutter/material.dart';
import '../../models/todo_item.dart';

class DialogBox extends StatelessWidget {
  final String title;
  final TextEditingController controllerToBeDone = TextEditingController();
  final TextEditingController controllerNote = TextEditingController();
  final TodoItem toDoItem;

  // VoidCallback saveTask;
  // VoidCallback cancelTask;

  DialogBox({
    super.key,
    required this.toDoItem,
    required this.title,
    // required this.controller,
    // required this.saveTask,
    // required this.cancelTask
  });

  @override
  Widget build(BuildContext context) {
    controllerToBeDone.text = toDoItem.toBeDone;
    controllerNote.text = toDoItem.note;

    return AlertDialog(
      shape: const BeveledRectangleBorder(),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      title: Text(title),
      titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24),
      scrollable: true, //to make auto size to content
      content: Column(
        //mainAxisSize: MainAxisSize.min,  //to make auto size to content
        children: [
          TextField(
            autofocus: true,
            controller: controllerToBeDone,
            decoration: const InputDecoration(
                labelText: "Task",
                hintText: "Enter new task",
                border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 12,
          ),
          TextField(
            autofocus: true,
            controller: controllerNote,
            decoration: const InputDecoration(
                labelText: "Note",
                hintText: "Note",
                border: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyButton(
                  text: "Save",
                  onPressed: () {
                    toDoItem.toBeDone = controllerToBeDone.text;
                    toDoItem.note = controllerNote.text;
                    Navigator.pop(context, toDoItem);
                  }),
              const SizedBox(width: 4),
              MyButton(
                  text: "Cancel",
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        ],
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MyButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
    );
  }
}
