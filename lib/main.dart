import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: Colors.grey[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}



class HomePage extends StatefulWidget{

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var notes = ['Hello World', 'Second Note'];
  var colors = [Colors.red[200], Colors.blue[200], Colors.green[200], Colors.orange[200], Colors.indigo[200]];
  var borderColors = [Colors.red[400], Colors.blue[400], Colors.green[400], Colors.orange[400], Colors.indigo[400]];

  editNote(int index, var note){
    notes[index] = note.toString();
  }

  newNote(var note){
    notes.add(note.toString());
  }

  deleteNote(var index){
    notes.removeAt(index);
    setState(() {});
  }

  createDeleteDialog(BuildContext context, var index){
    return showDialog(context: context,
                      builder: (context) {
                        return AlertDialog(
                        content: Text('Delete this note?'),
                        actions: <Widget>[
                          MaterialButton(
                            child: Text('Yes'),
                            color: Colors.blue,
                            onPressed: () {
                              deleteNote(index);
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          ),
                          MaterialButton(
                            child: Text('No'),
                            color: Colors.red,
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                        backgroundColor: colors[Random().nextInt(colors.length)],
                      );
      }
    );
  }

  createNotesDialog(BuildContext context, {var index:-1}){

    TextEditingController notesController = TextEditingController(text: index == -1? "": notes[index].toString());

    return showDialog(context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: EditableText(
                                    minLines: 4,
                                    maxLines: 20,
                                    autofocus: true,
                                    controller: notesController,
                                    cursorColor: Colors.black,
                                    focusNode: FocusNode(),
                                    keyboardType: TextInputType.multiline,
                                    backgroundCursorColor: Colors.black,
                                    style: TextStyle(fontSize: 14, 
                                                    color: Colors.black),
                                    ),
                          actions: <Widget>[
                            MaterialButton(
                              child: Text('Save'),
                              color: Colors.green,
                              height: 60,
                              minWidth: 80,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                              onPressed: () {
                                index == -1 ? newNote(notesController.value.text): editNote(index, notesController.value.text);
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                            ),
                            MaterialButton(
                              child: Text('Cancel'),
                              color: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                              height: 60,
                              minWidth: 80,
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                          backgroundColor: colors[Random().nextInt(colors.length)],
                        );
      }
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
        
        itemBuilder: (context, index) {
        var colorIndex = Random().nextInt(colors.length);
        return Container(child: DecoratedBox(
                                  decoration: BoxDecoration(border: Border.all(color: borderColors[colorIndex], width: 10), borderRadius: BorderRadius.all(Radius.circular(8))),
                                  child: Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                    color: colors[colorIndex],
                                    child: ListTile(title: Text(notes[index]), 
                                                                      onTap: (){createNotesDialog(context, index:index);}, 
                                                                      onLongPress: () {createDeleteDialog(context, index);},
                                                                    ),
                                  ),
        ),
                        margin: const EdgeInsets.all(8),);
      },
      itemCount: notes.length,
      ),
      floatingActionButton: FloatingActionButton(
                              onPressed: (){
                                createNotesDialog(context);
                              },
                              child: Icon(Icons.add),
      ),
      
    );
  }
}
