//import 'package:flutter/material.dart';
//import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'package:provider/provider.dart';

//var db;

@immutable
class Notes {
  //final int id;
  final String date;
  final String title;
  final content;

  const Notes({
    //required this.id,
    required this.date,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      //'id': id,
      'date': date,
      'title': title,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Notes{title: $title, date: $date, content: $content}';
  }
}

class NotesDatabase {
  late Future<Database> database;
  late List<Notes> notesList;

  NotesDatabase() {
    print("database initialized");
    database = start();
  }

  Future<Notes> loadNote(String index) async {
    notesList = await notes();
    for (final note in notesList) {
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      print(note.toString());
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      if (note.date == index) {
        print("loading a note from database... ${note}");
        return note;
      }
    }
    print("loading a wrong note from database... ${const Notes(
      title: "",
      date: "now?",
      content: r'[{"insert": "Anything in mind\n"}]',
    ).toString()}");
    return const Notes(
      title: "",
      date: "now?",
      content: r'[{"insert": "Anything in mind?\n"}]',
    );
  }

  Future<Database> start() async {
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'notes_flutter.db'),
      // When the database is first created, create a table to store notes.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE "Notes_Table" ("date"	TEXT NOT NULL UNIQUE, "title"	TEXT, "content"	TEXT NOT NULL, PRIMARY KEY("date"))',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    notesList = await notes();
    return database;
  }

  Future<void> callInfo() async {
    getColumnInformation(await database, "Notes_Table");
  }

  Future<void> getColumnInformation(Database db, String tableName) async {
    final List<Map<String, dynamic>> columns =
        await db.rawQuery('PRAGMA table_info($tableName)');

    for (final column in columns) {
      final String columnName = column['name'];
      final String dataType = column['type'];
      final bool isNotNull = column['notnull'] == 1;
      final bool isPrimaryKey = column['pk'] == 1;

      print('Column Name: $columnName');
      print('Data Type: $dataType');
      print('Not Null: $isNotNull');
      print('Primary Key: $isPrimaryKey');
      print('---');
    }
  }

  Future<void> insertNotes(Notes notes) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Note into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same note is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'Notes_Table',
      notes.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Notes>> notes() async {
    print("starting notes() @ functions");
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Notes.
    final List<Map<String, dynamic>> maps =
        await db.query('Notes_Table', orderBy: "date DESC");

    notesList = List.generate(maps.length, (i) {
      print("@notes: [date] = ${maps[i]['date']}");
      print(maps[i].toString());
      return Notes(
        date: maps[i]['date'],
        title: maps[i]['title'],
        content: maps[i]['content'],
      );
    });

    //print("notesList from database: $notesList");

    // Convert the List<Map<String, dynamic> into a List<Notes>.
    return notesList;
  }

  Future<void> loadData() async {
    notesList = await notes();
    for (var note in notesList) {
      print('Date: ${note.date}');
      print('Title: ${note.title}');
      print('Content: ${note.content}');
      print('---');
    }
  }

  Future<void> updateNote(Notes note, String oldDate) async {
    // Get a reference to the database.
    final db = await database;

    print("@functions.updateNote() ${note.toString()}");

    // Remove first the Note from the database.
    await db.delete(
      'Notes_Table',
      // Use a `where` clause to delete a specific note.
      where: 'date = ?',
      // Pass the Note's id as a whereArg to prevent SQL injection.
      whereArgs: [oldDate],
    );

    // Then insert the note with new Date
    await db.insert(
      'Notes_Table',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(date) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Note from the database.
    await db.delete(
      'Notes_Table',
      // Use a `where` clause to delete a specific note.
      where: 'date = ?',
      // Pass the Note's id as a whereArg to prevent SQL injection.
      whereArgs: [date],
    );
  }

  deleteAllEntries() async {
    final db = await database;
    return await db.rawDelete("DELETE FROM Notes_Table");
  }
}

class NotesList extends StateNotifier<List<Notes>> {
  final NotesDatabase database;
  NotesList({required this.database}) : super([]);

  void initDatabase() async {
    await database.start();
    notes();
  }

  void notes() async {
    state = await database.notes();
  }

  void insertNotes(Notes note) async {
    await database.insertNotes(note);
    notes();
  }

  void deleteNotes(String date) async {
    await database.deleteNote(date);
    notes();
  }

  Future<Notes> loadNote(String date) async {
    return await database.loadNote(date);
  }

  void updateNotes(Notes note, String oldDate) async {
    await database.updateNote(note, oldDate);
    notes();
  }
}

final finalNotesDb = NotesDatabase();

final notesProvider = StateNotifierProvider<NotesList, List<Notes>>((ref) {
  var temp = NotesList(database: finalNotesDb);
  temp.initDatabase();
  return temp;
});
