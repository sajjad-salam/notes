import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const NotesPage(),
    );
  }
}

class Note {
  final String title;
  final String content;

  Note({required this.title, required this.content});
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];

  TextEditingController noteController = TextEditingController();
  void addNote() async {
    String newNoteTitle = noteController.text;
    String newNoteContent = ''; // Add content here if needed
    if (newNoteTitle.isNotEmpty) {
      setState(() {
        notes.add(Note(title: newNoteTitle, content: newNoteContent));
        noteController.clear();
      });
      await saveNotes(notes.cast<Note>());
    }
  }

  MaterialStateProperty<Color?> amberColor =
      MaterialStateProperty.all<Color?>(const Color.fromARGB(255, 105, 63, 0));
  Future<List<Note>> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList('notes');
    return notesJson != null
        ? notesJson.map((noteJson) => noteFromJson(noteJson)).toList()
        : [];
  }

  void deleteNote(int index) {
    setState(() {
      Note deletedNote = notes.removeAt(index);
      deleteNoteFromStorage(
          deletedNote); // Call a function to delete the note from storage
    });
  }
  Future<void> _sendEmail(recipientEmail) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: recipientEmail,
      queryParameters: {
        'subject': 'Subject here',
        'body': 'Type your message here',
      },
    );

    final String url = emailLaunchUri.toString();

    try {
      // ignore: deprecated_member_use
      await launch("https://t.me/S_J_O_D");
    } catch (e) {
      Get.snackbar("خطأ", "لايمكن فتح الرابط بسبب $e");
    }
  }

  void deleteNoteFromStorage(Note note) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedNotes = prefs.getStringList('notes');

    if (storedNotes != null) {
      String noteJson = noteToJson(note);
      storedNotes.remove(noteJson);
      await prefs.setStringList('notes', storedNotes);
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson = notes.map((note) => noteToJson(note)).toList();
    await prefs.setStringList('notes', notesJson);
  }

  String noteToJson(Note note) {
    return jsonEncode({'title': note.title, 'content': note.content});
  }

  Note noteFromJson(String noteJson) {
    Map<String, dynamic> json = jsonDecode(noteJson);
    return Note(
      title: json['title'],
      content: json['content'],
    );
  }

  @override
  void initState() {
    super.initState();
    loadNotes().then((loadedNotes) {
      setState(() {
        notes = loadedNotes;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar:  CupertinoNavigationBar(
        backgroundColor:Colors.amberAccent,
        leading: TextButton(

        onPressed: () {
          Get.snackbar!(
      
      'المطور',
      'المهندس سجاد سلام\nاضغط لأرسال رسالة ',
      snackStyle : SnackStyle.GROUNDED ,
      onTap: (snake) {
        _sendEmail('sajjad.salam.teama@gmail.com');
      },
      // messageText: Text("data"),
      colorText: Colors.white,
      
      
      snackPosition: SnackPosition.BOTTOM,
      
      duration: const Duration(seconds: 3),

    );
        },
       
        child: const Icon(Icons.info_outline,color: Colors.white,),
      ),
        previousPageTitle: "رجوع",
        middle: const Text(
          "ملاحضاتي",
          style: TextStyle(fontFamily: "myfont", fontSize: 25),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  Note note = notes[index];
                  return ListTile(
                    title: Text(
                      textAlign: TextAlign.end,
                      note.title,
                      style: const TextStyle(fontFamily: "myfont"),
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          deleteNote(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: noteController,
              autocorrect: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                addNote();
              },
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: "myfont",
                color: Colors.white, // Set the color to white
              ),
              decoration: const InputDecoration.collapsed(
    hintText:  ".... كتابة ملاحظة "
  ),
            ),
            const SizedBox(height: 10),
         
          ],
        ),
      ),
    );
  }
}
