import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.pinkAccent,
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  //final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Todo List 📝🔥"),
      ),
      body: const Todos(),
    );
  }
}

// class TodoList extends ChangeNotifier(){

// }

class Todos extends StatefulWidget {
  const Todos({super.key});

  @override
  State<Todos> createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  List<String> todoList = [];
  //todoList.add();

  void justprint() {
    print("eyoooo");
    setState(() {
      todoList.add("woaaa");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(todoList[index]));
              }),
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
                onPressed: justprint,
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.orange,
                  size: 100.0,
                )),
          ),
        ],
      ),
    );
  }
}
