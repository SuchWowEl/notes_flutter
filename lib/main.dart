import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill; // hide Text;
//import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
//import 'package:provider/provider.dart';
//import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:provider/provider.dart';

import 'db_functions.dart';
import 'notes_page.dart';

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

  @override
  Widget build(BuildContext context) {
    print("loaded MyHomePage");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Todo List 📝🔥"),
      ),
      body: const AppBody(),
    );
  }
}

class AppBody extends ConsumerWidget {
  const AppBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesListProvider = ref.watch(notesProvider);
    print("WIDGET REBUILD SUCCESSFUL");
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Conditional.single(
              context: context,
              conditionBuilder: (BuildContext context) =>
                  notesListProvider.isNotEmpty,
              widgetBuilder: (BuildContext context) {
                return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.5, crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      print("index #$index");
                      if (index < notesListProvider.length) {
                        return GridTile(
                            child: Card2(
                          notes: notesListProvider[index],
                        ));
                      }
                    });
              },
              fallbackBuilder: (BuildContext context) {
                return const Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(
                        "What's on your mind?",
                        style: TextStyle(color: Colors.white70),
                      )
                    ]));
              }),
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotesPage(
                              noteGiven: Notes(
                                  //id: notesDb.notesList.length,
                                  title: "",
                                  date: DateFormat('yyyy-MM-dd hh:mm:ss')
                                      .format(DateTime.now()),
                                  content: r'[{"insert": "\n"}]'),
                            ))),
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
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NotesPage(
                      noteGiven: notes,
                    ))),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Add padding around the row widget
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
              Expanded(
                child: ShaderMask(
                  shaderCallback: (Rect rect) {
                    return const LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white],
                      //set stops as par your requirement
                      stops: [0.7, 1.0], // 50% transparent, 50% white
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstOut,
                  child: ClipRect(
                    child: quill.QuillEditor(
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                      expands: false,
                      scrollable: false,
                      autoFocus: false,
                      padding: const EdgeInsets.all(5),
                      controller: _controller,
                      readOnly: true, // true for
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
