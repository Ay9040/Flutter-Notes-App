import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final database = Firestore.instance;
var userId;

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return currentUser.uid;
}

void signOutGoogle(BuildContext context) async {
  await _auth.signOut();
  await googleSignIn.signOut();
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return LoginPage();
  }));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  signInWithGoogle().then((userid) {
    userId = userid;
    runApp(MyApp());
  });
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(title: Text('Notes')),
          body: Center(
            child: MaterialButton(
                onPressed: () => {
                      signInWithGoogle().then((userid) {
                        userId = userid;
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return HomePage();
                        }));
                      })
                    },
                color: Colors.white,
                textColor: Colors.black,
                child: Text("Sign in with Google")),
          )),
    );
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var colors = [
    Colors.red[200],
    Colors.blue[200],
    Colors.green[200],
    Colors.orange[200],
    Colors.indigo[200]
  ];
  var borderColors = [
    Colors.red[400],
    Colors.blue[400],
    Colors.green[400],
    Colors.orange[400],
    Colors.indigo[400]
  ];

  editNote(var index, var note) async {
    try {
      await database
          .collection('users')
          .document(userId)
          .collection('notes')
          .document(index.toString())
          .updateData({'note': note});
    } catch (e) {
      print(e.toString());
    }
  }

  newNote(var note, var index) async {
    await database
        .collection('users')
        .document(userId)
        .collection("notes")
        .add({'note': note});
    setState(() {});
  }

  deleteNote(var index) {
    database
        .collection('users')
        .document(userId)
        .collection('notes')
        .document(index.toString())
        .delete();
  }

  createDeleteDialog(BuildContext context, var index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Delete this note?'),
            actions: <Widget>[
              MaterialButton(
                child: Text('Yes'),
                color: Colors.blue,
                onPressed: () {
                  deleteNote(index);
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                child: Text('No'),
                color: Colors.red,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            backgroundColor: colors[Random().nextInt(colors.length)],
          );
        });
  }

  createNotesDialog(BuildContext context, {var index: -1, var original: ""}) {
    TextEditingController notesController =
        TextEditingController(text: original);

    return showDialog(
        context: context,
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
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text('Save'),
                color: Colors.green,
                height: 60,
                minWidth: 80,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                onPressed: () {
                  index == -1
                      ? newNote(notesController.value.text, index)
                      : editNote(index, notesController.value.text);
                  setState(() {});
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                child: Text('Cancel'),
                color: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                height: 60,
                minWidth: 80,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            backgroundColor: colors[Random().nextInt(colors.length)],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes'), actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: MaterialButton(
                color: Colors.red,
                onPressed: () {
                  signOutGoogle(context);
                },
                child: Text("Logout"),
              ),
            ))
      ]),
      body: StreamBuilder(
          stream: database
              .collection('users')
              .document(userId)
              .collection('notes')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                var colorIndex = Random().nextInt(colors.length);
                return Container(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: borderColors[colorIndex], width: 10),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      color: colors[colorIndex],
                      child: ListTile(
                        title: Text(
                          snapshot.data.documents[index]['note'],
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          createNotesDialog(context,
                              index: snapshot.data.documents[index].documentID,
                              original: snapshot.data.documents[index]['note']);
                        },
                        onLongPress: () {
                          createDeleteDialog(context,
                              snapshot.data.documents[index].documentID);
                        },
                      ),
                    ),
                  ),
                  margin: const EdgeInsets.all(8),
                );
              },
              itemCount: snapshot.data.documents.length,
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNotesDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
