import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/streaming_screen.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  title: "Main Page",
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget{
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const StreamView(),
    );
  }
}