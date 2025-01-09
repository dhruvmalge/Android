import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plant Health Detection',
          style: TextStyle(
            fontSize: 15,
            decoration: TextDecoration.none,
            color: Theme.of(context).colorScheme.onPrimary,
            decorationThickness: 5.0,
            wordSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(199, 76, 177, 22),
        bottom: const PreferredSize(preferredSize: Size.square(BorderSide.strokeAlignCenter), child: Text("data"),),
        shadowColor: Colors.grey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(),
            const TextField(),
            ElevatedButton(onPressed: (){}, child: const Text("Button"))
          ],
        ),
      ),
    );
  }
}