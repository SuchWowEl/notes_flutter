import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
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
        secondaryHeaderColor: const Color.fromARGB(255, 255, 23, 23),
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
  int counter = 0;
  //Should include: Title, Date, and Content
  Map todoList = <String, String>{};
  //List<String> todoList = [][];
  //todoList.add();

  void justprint() {
    print("eyoooo");
    setState(() {
      todoList["Title no. $counter"] = "EYOOOOO $counter";
    });
    counter++;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // ListView(
          //   children: const [
          //     Card2(),
          //     Card2(),
          //     Card2(),
          //   ],
          // ),
          GridView(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            scrollDirection: Axis.vertical,
            //direction: Axis.horizontal,
            children: const [
              Card2(
                notes: 'Eat Healthy ',
              ),
              Card2(
                notes: '',
              ),
              Card2(
                notes:
                    'Eat Healthy Eat Healthy Eat Healthy Eat Healthy Eat Healthy Eat Healthy Eat Healthy ',
              ),
              Card2(
                notes: 'asdasd dsad dsa',
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const NotesPage())),
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

class List extends StatelessWidget {
  const List({
    super.key,
    required this.todoList,
  });

  final Map todoList;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...todoList.keys.map((key) {
          return ListTile(
            tileColor: Theme.of(context).secondaryHeaderColor,
            title: Text(key),
            subtitle: Text(todoList[key]),
          );
        })
      ],
    );
  }
}

class Card2 extends StatelessWidget {
  const Card2({Key? key, required this.notes}) : super(key: key);

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: const EdgeInsets.all(20),
      // Define the shape of the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      // Define how the card's content should be clipped
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Add padding around the row widget
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Add some spacing between the top of the card and the title
                Container(height: 5),
                // Add a title widget
                const Text(
                  "Jan 1, 1999",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  // style: MyTextSample.title(context)!.copyWith(
                  //   color: MyColorsSample.grey_80,
                  // ),
                ),
                // Add some spacing between the title and the subtitle
                Container(height: 5),
                // Add a subtitle widget
                const Text(
                  "New Year's Resolution",
                  style: TextStyle(color: Colors.grey),
                  // style: MyTextSample.body1(context)!.copyWith(
                  //   color: Colors.grey[500],
                  // ),
                ),
                // Add some spacing between the subtitle and the text
                Container(height: 10),
                // Add a text widget to display some text
                Text(notes
                    // MyStringsSample.card_text,
                    // maxLines: 2,
                    // style: MyTextSample.subhead(context)!.copyWith(
                    //   color: Colors.grey[700],
                    // ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new)),
            //header should be sticky and has an editable textfield(?)
            backgroundColor: Colors.black54,
            title: const SizedBox(
              width: 300, //(MediaQuery.sizeOf(context).width / 3),
              child: TextField(
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    fillColor: Colors.lightGreen,
                    hintStyle: TextStyle(color: Colors.white70),
                    hintText: "Title"),
              ),
            )),
        body: const NotesContent(),
      ),
    );
  }
}

class NotesContent extends StatefulWidget {
  const NotesContent({super.key});

  @override
  State<NotesContent> createState() => _NotesContentState();
}

class _NotesContentState extends State<NotesContent> {
  final QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 15,
        ),
        QuillToolbar.basic(
          color: Colors.blue[900],
          //afterButtonPressed: () => print("toolbar pressed"),
          controller: _controller,
          //key: Key(),
        ),
        Expanded(
          child: QuillEditor.basic(
            keyboardAppearance: Brightness.dark,
            padding: const EdgeInsets.all(50),
            controller: _controller,
            readOnly: false, // true for
          ),
        ),
      ],
    );
  }
}
