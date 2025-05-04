import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:registration_with_firebase_demo/constants/routes.dart';
import 'package:registration_with_firebase_demo/widget/custom_dialog.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GlobalKey<FormState> formState = GlobalKey();
  String? password, email;
  Future<UserCredential?> signIn() async {
    FormState? formData = formState.currentState;
    formData?.save();
    if (formData!.validate()) {
      try {
        showLoading(context);
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email!, password: password!);
        Navigator.pop(context);
        return credential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Navigator.pop(context);
          customDialog(context, "Error", "No user found for that email.");
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          Navigator.pop(context);
          customDialog(
            context,
            "Error",
            'Wrong password provided for that user.',
          );
          print('Wrong password provided for that user.');
        } else {
          Navigator.pop(context);
          customDialog(context, "Error", e.code);
        }
      }
    } else {
      print("Not Valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),

      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      MaterialButton(
                        minWidth: 300,
                        splashColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 10,
                        ),
                        onPressed: () async {
                          UserCredential? userCredential = await signIn();
                          if (!mounted) return;
                          //
                          if (userCredential != null) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.home.toString(),
                              (route) => false,
                            );
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,

                        child: Text("Sign In", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.signUp.toString());
                },
                child: Text("Not have an account!"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
