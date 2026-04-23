import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Тестовий додаток'),
        ),
        body: const Center(
          // Якщо ти бачиш цей текст на екрані телефону/емулятора, 
          // значить усе працює ідеально!
          child: Text('Firebase успішно підключено!🎉'), 
        ),
      ),
    );
  }
}

  // runApp(const MyApp());
  // runApp(
  //   const Center(
  //     child: Text(
  //       'Hello, World!',
  //       textDirection: TextDirection.ltr,
  //       style: TextStyle(color: Colors.blue),
  //     ),
  //   ),
  // );
