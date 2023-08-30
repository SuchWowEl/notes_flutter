import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill; // hide Text;
//import 'package:provider/provider.dart';
//import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'db_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:provider/provider.dart';

final noteListProvider = FutureProvider((ref) async {
  print("noteDbProvider moment");
  //await Future.delayed(const Duration(seconds: 5));
  var temp = NotesDatabase();
  await temp.start();
  return temp.notesList;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.pinkAccent,
          secondaryHeaderColor: const Color.fromARGB(255, 255, 23, 23),
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
        //builder: EasyLoading.init(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  //final String title;

  // NotesDatabase temp() {
  //   var temp = NotesDatabase();
  //   temp.notesList = [const Notes(id: 0, title: title, date: date, content: content)]
  // }

  @override
  Widget build(BuildContext context) {
    print("loaded MyHomePage");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Todo List 📝🔥"),
      ),
      body: AppBody(),
      // body: FutureProvider(
      //     initialData: EasyLoading.show(
      //         status: 'Gathering Notes...',
      //         maskType: EasyLoadingMaskType.custom),
      //     create: (context) async {
      //       print("done loading");
      //       var db = NotesDatabase();
      //       await db.start();
      //       //await Future.delayed(const Duration(seconds: 3));
      //       await EasyLoading.dismiss();
      //       return db;
      //     },
      //     child: const Todos()),
    );
  }
}

class AppBody extends ConsumerWidget {
  AppBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // EasyLoading.instance
    //   ..displayDuration = const Duration(milliseconds: 2000)
    //   ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    //   ..loadingStyle = EasyLoadingStyle.dark
    //   ..indicatorSize = 45.0
    //   ..radius = 10.0
    //   // ..progressColor = Colors.pink[300]
    //   // ..backgroundColor = Colors.green
    //   // ..indicatorColor = Colors.yellow
    //   // ..textColor = Colors.yellow
    //   ..maskColor = Colors.black87.withOpacity(0.4)
    //   ..userInteractions = true
    //   ..dismissOnTap = false;

    final notesListFuture = ref.watch(noteListProvider);
    return notesListFuture.when(data: (data) {
      print("successful?");
      return Todos(notesList: data);
    }, error: (err, stack) {
      print("error?");
      return const Text("Something went wrong with the database :(");
    }, loading: () {
      print("eyo?");
      return Container(
        height: double.infinity,
        width: double.infinity,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.black,
                  height: 150,
                  width: 150,
                  child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitCubeGrid(
                          color: Colors.white,
                          size: 50,
                        ),
                        Text("Retrieving Notes..."),
                      ]),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// class TodoList extends ChangeNotifier(){

// }

class Todos extends StatelessWidget {
  final notesList;

  const Todos({super.key, required this.notesList});

  @override
  Widget build(BuildContext context) {
    print("niabot diris Todosstate");
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // GridView(
          //   shrinkWrap: true,
          //   padding: const EdgeInsets.all(10),
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //       childAspectRatio: 1.5, crossAxisCount: 3),
          //   scrollDirection: Axis.vertical,
          //   //direction: Axis.horizontal,
          //   children: const [
          //     Card2(
          //       notes: 'Eat Healthy ',
          //     ),
          //     Card2(
          //       notes: '',
          //     ),
          //     Card2(
          //       notes:
          //           'Eat Healthy Eat Healthy Eat Healthy Eat Healthy Eat Healthy Eat Healthy Eat Healthy ',
          //     ),
          //     Card2(
          //       notes: 'asdasd dsad dsa',
          //     ),
          //   ],
          // ),
          GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.5, crossAxisCount: 3),
              itemBuilder: (context, index) {
                print("index #$index");
                if (index < notesList.length) {
                  return GridTile(
                      child: Card2(
                    notes: notesList[index],
                  ));
                }
              }),
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

  final Notes notes;

  quill.QuillController createController() {
    var stringtemp = json.decode(notes.content);
    // if (stringtemp is List) {
    // print("noteGiven is JSON");
    print("printing content: $stringtemp");
    return quill.QuillController(
        document: quill.Document.fromJson(stringtemp),
        selection: const TextSelection.collapsed(offset: 0));
    // } else {
    //   print("noteGiven is string");
    //   final Document document = Document();
    //   document.insert(0, "${stringtemp}");
    //   return QuillController(
    //     document: document,
    //     selection: const TextSelection.collapsed(offset: 0),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final quill.QuillController _controller = createController();
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
                // Add some spacing between the title and the subtitle
                Container(height: 5),
                // Add a subtitle widget
                Text(
                  notes.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  // style: MyTextSample.body1(context)!.copyWith(
                  //   color: Colors.grey[500],
                  // ),
                ),
                // Add some spacing between the top of the card and the title
                Container(height: 5),
                // Add a title widget
                Text(
                  notes.date,
                  style: const TextStyle(color: Colors.grey),
                ),
                // Add some spacing between the subtitle and the text
                Container(height: 10),
                quill.QuillEditor.basic(
                  autoFocus: false,
                  keyboardAppearance: Brightness.dark,
                  padding: const EdgeInsets.all(5),
                  controller: _controller,
                  readOnly: true, // true for
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
  final quill.QuillController _controller = quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 15,
        ),
        quill.QuillToolbar.basic(
          color: Colors.blue[900],
          //afterButtonPressed: () => print("toolbar pressed"),
          controller: _controller,
          //key: Key(),
        ),
        Expanded(
          child: quill.QuillEditor.basic(
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
