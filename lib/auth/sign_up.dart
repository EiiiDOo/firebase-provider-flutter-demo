import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registration_with_firebase_demo/constants/routes.dart';
import 'package:registration_with_firebase_demo/widget/custom_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<FormState> formState = GlobalKey();
  String? confirmPass, password, email, username;
  Future<UserCredential?> signUp() async {
    FormState? formData = formState.currentState;
    formData?.save();
    if (formData!.validate()) {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email!, password: password!);
        return credential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          customDialog(context, "Error", "The password provided is too weak");
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          customDialog(
            context,
            "Error",
            "The account already exists for that email.",
          );
          print('The account already exists for that email.');
        }
      } on Exception catch (e) {
        customDialog(context, "Error", e.toString());
        print(e);
      }
    } else {
      print("Not Valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: ListView(
        children: [
          Center(
            child: Image.asset("images/cover.jpg", width: 300, height: 400),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: formState,
              child: Column(
                spacing: 18,
                children: [
                  TextFormField(
                    onSaved: (newValue) => email = newValue,
                    validator: (value) {
                      if (value != null) {
                        if (value.isEmpty) {
                          return 'Fill email filed';
                        }
                        return null;
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  TextFormField(
                    onSaved: (newValue) => username = newValue,
                    validator: (value) {
                      if (value != null) {
                        if (value.isEmpty) {
                          return 'Fill username filed';
                        }
                        if (value.length < 3) {
                          return 'Must be more than teo char';
                        }
                        return null;
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Username",
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  TextFormField(
                    obscureText: true,
                    onSaved: (newValue) => password = newValue,
                    validator: (value) {
                      if (value != null) {
                        if (value.length > 10) {
                          return "Mustn't be more than 10";
                        }
                        if (value.length < 4) {
                          return "Mustn't be less than 4";
                        }
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  TextFormField(
                    onSaved: (newValue) => confirmPass = newValue,
                    obscureText: true,
                    validator: (value) {
                      if (value != null) {
                        if (value.length < 4) {
                          return "Mustn't be less than 4";
                        }
                        if (value != password) {
                          return "Not match with pass";
                        }
                        if (value.length > 10) {
                          return "Mustn't be more than 10";
                        }
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  MaterialButton(
                    minWidth: 300,
                    splashColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    onPressed: () async {
                      showLoading(context);
                      UserCredential? userCredential = await signUp();
                      if (!mounted) return;
                      if (userCredential != null) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(userCredential.user?.uid)
                            .set({'username': username, 'email': email});
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.home.toString(),
                          (route) => false,
                        );
                      }
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,

                    child: Text("Sign Up", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.signIn.toString(),
                (route) => false,
              );
            },
            child: Text("Already have an account!"),
          ),
        ],
      ),
    );
  }
}
