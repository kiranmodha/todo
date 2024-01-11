import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do/presentation/home_screen/home.dart';
import 'package:to_do/models/todo_item.dart';

const defaultFirebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyAS1kE5gnalfAUVSF13YtZ7o_UxgM3qYRw",
  authDomain: "todo-789.firebaseapp.com",
  projectId: "todo-789",
  storageBucket: "todo-789.appspot.com",
  messagingSenderId: "234960648188",
  appId: "1:234960648188:web:4298086e3844be8a9ce479",
);

// Hello

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoItemAdapter());

  await Firebase.initializeApp(options: defaultFirebaseOptions);

  // ignore: unused_local_variable
  var box = await Hive.openBox<TodoItem>('todos');

  if (kIsWeb) {
    runApp(
      DevicePreview(
        enabled: true,
        builder: (context) => const MyApp(), // Wrap your app
      ),
    );
  } else {
    runApp(const MyApp());
  }
}
// void main() {
//  runApps(cont MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // debugShowMaterialGrid: true,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
