import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:registration_with_firebase_demo/widget/custom_dialog.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({super.key});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  GlobalKey<FormState> formKey = GlobalKey();
  File? file;
  String? title, note, imageUrl;
  Future<bool> addNote() async {
    FormState? formData = formKey.currentState;
    if (formData != null && formData.validate() && file != null) {
      formData.save();
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('specific-notes')
          .add({'imagePath': file?.path, 'title': title, 'note': note});
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Note")),
      body: ListView(
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 25,
                  onSaved: (newValue) => title = newValue,
                  validator: (value) {
                    if (value != null) {
                      if (value.isEmpty || value.length < 4) {
                        return 'Must be more than 3 char';
                      }
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Note Title",
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                TextFormField(
                  maxLength: 200,
                  minLines: 1,
                  maxLines: 6,
                  onSaved: (newValue) => note = newValue,
                  validator: (value) {
                    if (value != null) {
                      if (value.isEmpty || value.length < 10) {
                        return 'Must be more than 9 char';
                      }
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "desc",
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                MaterialButton(
                  onPressed:
                      file != null
                          ? null
                          : () {
                            showBottomSheet(context);
                          },
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  child: Text("Add Image"),
                ),
                if (file != null) Image.file(file!),
                MaterialButton(
                  onPressed: () async {
                    showLoading(context);
                    bool result = await addNote();
                    Navigator.pop(context);
                    if (result) Navigator.pop(context);
                  },
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 4),
                  child: Text(
                    "Add Note",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showBottomSheet(context) {
    return showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            height: 250,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose Image",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                InkWell(
                  onTap: () async {
                    XFile? pick = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pick != null) {
                      file = File(pick.path);
                      setState(() {});
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      spacing: 20,
                      children: [
                        Icon(Icons.photo_album, size: 30),
                        Text(
                          "From Gallery",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    XFile? pick = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (pick != null) {
                      file = File(pick.path);
                      setState(() {});
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      spacing: 20,
                      children: [
                        Icon(Icons.camera_alt_sharp, size: 30),
                        Text(
                          "From Camera",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
