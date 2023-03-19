import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MaterialApp(home: Notebook()));
}

class Notebook extends StatefulWidget {
  const Notebook({Key? key}) : super(key: key);

  @override
  State<Notebook> createState() => _NotebookState();
}

class _NotebookState extends State<Notebook> {
  Database? database;
  List<Map>? _notes;

  Future<void> creatDatabase() async {
// open the database
    database = await openDatabase("notes.db", version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Note (id INTEGER PRIMARY KEY, content TEXT)');
        }, onOpen: (Database) async {
          _notes = await database?.rawQuery('SELECT * FROM Note');
          setState(() {});
        });
  }


  Future<void> getNotes() async {
    _notes = await database?.rawQuery('SELECT * FROM Note');
    setState(() {});
  }

  Future<void> deletenote(int id) async {
    await database?.rawDelete('DELETE FROM Note WHERE id = $id');
    getNotes();
  }

  @override
  void initState() {
    creatDatabase();
    super.initState();
  }

  @override
  void dispose() {
    database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(actions: [IconButton(onPressed: () {
      getNotes();
    }, icon: Icon(Icons.refresh))
    ],),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Addnote()));
      }),
      body: _notes == null ? Text("data") : ListView.separated(
          itemBuilder: (context, index) =>
              Dismissible(direction: DismissDirection.endToStart,
                  onDismissed: (DismissDirection direction) {
                    int id = _notes?[index]['id'];
                    deletenote(id);
                  },
                  background: Container(
                    padding: EdgeInsets.only(left: 30),
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: Icon(Icons.delete),
                  ),
                  key: Key(_notes?[index]['content']),
                  child: GestureDetector(onTap: (){
                    int id = _notes?[index]['id'];
                    String content = _notes?[index]['content'];

                    Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateNote(id,content)));
                  },
                    child: Card(
                      shape: const RoundedRectangleBorder(),
                      child: Text(
                        _notes?[index]['content'],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ))

          , separatorBuilder: (context, index) => const SizedBox(height: 22),
          itemCount: _notes!.length),
    );
  }
}

class Addnote extends StatefulWidget {
  const Addnote({Key? key}) : super(key: key);

  @override
  State<Addnote> createState() => _AddnoteState();
}

class _AddnoteState extends State<Addnote> {
  var notecontroller = TextEditingController();
  Database? database;

  Future<void> createDatabase() async {
    // open the database
    database = await openDatabase("notes.db", version: 1,
        onCreate: (Database db, int version) async {
          print("database created!");
          // When creating the db, create the table
          await db
              .execute(
              'CREATE TABLE Note (id INTEGER PRIMARY KEY, content TEXT)');
          print("table created!");
        }, onOpen: (database) {
          print("database opened!");
        });
  }

  Future<void> insertToDatabase(String note) async {
    await database?.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Note(content) VALUES("$note")');
      print('inserted2: $id1');
    });
  }


  @override
  void initState() {
    createDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: TextFormField(decoration: const InputDecoration(
                label: Text("Note"),
                icon: Icon(Icons.note),
                border: UnderlineInputBorder(),

              ),
                keyboardType: TextInputType.multiline,
                controller: notecontroller,
                style: const TextStyle(fontSize: 24),
              )),
          MaterialButton(
              child: Text("add"),
              color: Colors.deepOrange,
              onPressed: () {
                Navigator.pop(context);
                insertToDatabase(notecontroller.text);
              })
        ],
      ),
    );
  }
}

class UpdateNote extends StatefulWidget {
   UpdateNote(this.id,this.cont,{Key? key}) : super(key: key);
  int id ;
  String cont;
  @override
  State<UpdateNote> createState() => _UpdateNoteState(id,cont);
}

class _UpdateNoteState extends State<UpdateNote> {
  _UpdateNoteState(this.id,this.cont);
  int id ;
  String cont;
  var notecontroller = TextEditingController();
  Database? database;


  Future<void> createDatabase() async {
    // open the database
    database = await openDatabase("notes.db", version: 1,
        onCreate: (Database db, int version) async {
          print("database created!");
          // When creating the db, create the table
          await db
              .execute(
              'CREATE TABLE Note (id INTEGER PRIMARY KEY, content TEXT)');
          print("table created!");
        }, onOpen: (database) {
          print("database opened!");
        });
  }

  @override
  void initState() {
    createDatabase();
    notecontroller.text=cont;
    super.initState();
  }

  Future<void> updatenote(int id, String newtext) async {
    await database?.rawUpdate(
        "UPDATE Note SET content='$newtext' WHERE id = '$id'");
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: TextFormField(decoration: const InputDecoration(
                label: Text("update Note"),
                icon: Icon(Icons.system_update_tv),
                border: UnderlineInputBorder(),

              ),
                keyboardType: TextInputType.multiline,
                controller: notecontroller,
                style: const TextStyle(fontSize: 24),
              )),
          MaterialButton(
              child: Text("update"),
              color: Colors.deepOrange,
              onPressed: () {
                updatenote(id, notecontroller.text);
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
}

