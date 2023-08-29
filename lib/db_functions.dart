//import 'package:flutter/material.dart';
//import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'package:provider/provider.dart';

//var db;

class Notes {
  final int id;
  final String title;
  final String date;
  final content;

  const Notes({
    required this.id,
    required this.title,
    required this.date,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Notes{id: $id, title: $title, date: $date, content: $content}';
  }
}

class NotesDatabase {
  late Future<Database> database;
  late List<Notes> notesList;

  NotesDatabase() {
    database = start();
  }

  Future<Notes> loadNote(int index) async {
    notesList = await notes();
    for (final note in notesList) {
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      print(note.toString());
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      if (note.id == index) {
        print("loading a note from database... ${note}");
        return note;
      }
    }
    print("loading a wrong note from database... ${const Notes(
      id: 696969,
      title: "wrong",
      date: "wrong",
      content: "wrong",
    ).toString()}");
    return const Notes(
      id: 696969,
      title: "wrong",
      date: "wrong",
      content: "wrong",
    );
  }

  Future<Database> start() async {
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'todo_flutter999.db'),
      // When the database is first created, create a table to store notes.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE "Notes_Table" ( "id"	INTEGER NOT NULL UNIQUE, "title"	TEXT, "date"	TEXT, "content"	JSON, PRIMARY KEY("id" AUTOINCREMENT))',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 2,
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
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Notes.
    final List<Map<String, dynamic>> maps = await db.query('Notes_Table');

    notesList = List.generate(maps.length, (i) {
      print("@notes: [id] = ${maps[i]['id']}");
      print(maps[i].toString());
      return Notes(
        id: maps[i]['id'],
        title: maps[i]['title'],
        date: maps[i]['date'],
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
      print('ID: ${note.id}');
      print('Title: ${note.title}');
      print('Date: ${note.date}');
      print('Content: ${note.content}');
      print('---');
    }
  }

  Future<void> updateNote(Notes note) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Note.
    await db.update(
      'Notes_Table',
      note.toMap(),
      // Ensure that the Note has a matching id.
      where: 'id = ?',
      // Pass the Note's id as a whereArg to prevent SQL injection.
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Note from the database.
    await db.delete(
      'Notes_Table',
      // Use a `where` clause to delete a specific note.
      where: 'id = ?',
      // Pass the Note's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
