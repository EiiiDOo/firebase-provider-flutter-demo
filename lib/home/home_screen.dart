import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:registration_with_firebase_demo/constants/routes.dart';
import 'package:registration_with_firebase_demo/widget/custom_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isUser = false;
  String? username;
  User? getUser() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      if (user != null) {
        isUser = true;
      } else {
        isUser = false;
      }
    });
    return user;
  }

  void getDisplayName() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        (await FirebaseFirestore.instance
            .collection('users')
            .doc(getUser()?.uid)
            .get());
    setState(() {
      username = userDoc.data()?['username'];
    });
  }

  void getNotes() async {
    NotificationSettings settings = await fbm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    User? user = getUser();
    FirebaseFirestore.instance
        .collection("notes")
        .doc(user?.uid)
        .collection('specific-notes')
        .snapshots()
        .listen((event) {
          notes.clear();
          for (var data in event.docs) {
            Map finalData = data.data();
            notes.add({...finalData, 'id': data.id});
          }
          setState(() {});
        });
  }

  List<Map<String, dynamic>> notes = [];
  var fbm = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
    fbm.getToken().then((value) => print('<<<<<<<<<<$value>>>>>>>>>>'));

    getUser();
    getDisplayName();
    getNotes();
    FirebaseMessaging.onMessage.listen((event) {
      print('<<<<<<<<<<${event.notification?.title}>>>>>>>>>>');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: '${event.notification?.title}',
        desc: '${event.notification?.body}',
      ).show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addNotes.toString());
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Title'),
        leadingWidth: 150,
        leading:
            (isUser && username != null)
                ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Center(
                    child: Text(
                      'Welcome, $username!',
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
                : null,
        actions: [
          if (isUser)
            IconButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.signIn.toString(),
                    (route) => false,
                  );
                } catch (e) {
                  customDialog(context, "Error", "Can't Sign out!");
                }
              },
              icon: Icon(Icons.logout, color: Colors.red[700]),
            ),
        ],
      ),
      body:
          notes.isNotEmpty
              ? ListView(
                children: List.generate(notes.length, (index) {
                  print('<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>');
                  print(notes);
                  return Dismissible(
                    key: Key("$index"),
                    child: ListNotes(notes: notes[index]),
                  );
                }),
              )
              : Center(child: Text("Empty notes, Add one")),
    );
  }
}

class ListNotes extends StatelessWidget {
  const ListNotes({super.key, required this.notes});
  final Map<String, dynamic> notes;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(flex: 1, child: Image.file(File(notes["imagePath"]))),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notes["title"],
                          textAlign: TextAlign.start,
                          style: TextStyle(),
                        ),
                        Text("${notes["note"]}"),
                        Text("${notes["id"]}"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('notes')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('specific-notes')
                              .doc(notes['id'])
                              .delete();
                        },
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
