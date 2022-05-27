import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/app/database/database_helper.dart';
import 'package:notes/app/model/note.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:notes/rps.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descripController = TextEditingController();

  final _db = DatabaseHelper();

  List<Note> _notes = <Note>[];

  _noteSaveUpdate({Note? noteS}) async {
    String title = _titleController.text;
    String description = _descripController.text;

    if (noteS == null) {
      //Saving ...
      Note note = Note(title, description, DateTime.now().toString());
      int result = await _db.saveNote(note);
    } else {
      //Updating ...
      noteS.title = title;
      noteS.description = description;
      noteS.data = DateTime.now().toString();

      int result = await _db.updateNote(noteS);
    }

    _titleController.clear();
    _descripController.clear();

    _recoverNotes();
  }

  _removeNote(int id) async {
    await _db.removeNote(id);
    _recoverNotes();
  }

  _recoverNotes() async {
    List notesRecovered = await _db.recoverNote();
    List<Note>? tempList = <Note>[];

    for (var item in notesRecovered) {
      Note note = Note.fromMap(item);
      tempList.add(note);
    }

    setState(() {
      _notes = tempList!;
    });
    tempList = null;
  }

  _showNoteScreen({Note? note}) {
    String textUpdate = '';
    String titleUpdate = '';

    if (note == null) {
      //saving ...
      _titleController.text = '';
      _descripController.text = '';
      textUpdate = 'Save';
      titleUpdate = 'Add';
    } else {
      //updating ...
      _titleController.text = note.title!;
      _descripController.text = note.description!;
      textUpdate = 'Update';
      titleUpdate = 'Update';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$titleUpdate Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Title', hintText: 'Type a title ...'),
              ),
              TextField(
                controller: _descripController,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Type a description...'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _noteSaveUpdate(noteS: note);
              },
              child: Text(textUpdate),
            ),
          ],
        );
      },
    );
  }

  _dateFormat(String date) {
    initializeDateFormatting('en_US');
    var formatter = DateFormat('MMM/d/y');

    DateTime dateConverted = DateTime.parse(date);
    String dateFormated = formatter.format(dateConverted);

    return dateFormated;
  }

  @override
  void initState() {
    _recoverNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder:
              (context) => rps()
              ));
            },
            child: const Text('Quick Local Notes')),
        backgroundColor: Colors.red.shade900,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final note = _notes[index];

                return Card(
                  child: ListTile(
                    title: Text(note.title!),
                    subtitle: Text(
                        '${_dateFormat(note.data!)} - ${note.description}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      //Edit
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child:
                              Icon(Icons.edit, color: Colors.red.shade900),
                        ),
                        onTap: () {
                          _showNoteScreen(note: note);
                        },
                      ),
                      //Remove
                      GestureDetector(
                        child:
                            const Icon(Icons.remove_circle, color: Colors.red),
                        onTap: () {
                          _removeNote(note.id!);
                        },
                      ),
                    ]),
                  ),
                );
              },
              itemCount: _notes.length,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red.shade900,
        child: const Icon(Icons.add),
        onPressed: () {
          _showNoteScreen();
        },
      ),
    );
  }
}
