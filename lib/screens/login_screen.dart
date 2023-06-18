import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  bool _isLoggedIn = true;
  bool _togglePwd = true;
  String? email;
  String? password;
  String? confirmPwd;
  File? userImage;
  bool isAuthenticating = false;
  String? userName;
  void saveState() async {
    bool validate = formKey.currentState!.validate();
    if (validate) {
      formKey.currentState!.save();
      if (!_isLoggedIn && password != confirmPwd) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Your passwords do not match',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ));
        return;
      }
      if (!_isLoggedIn && userImage == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Pick an Image',
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 2),
        ));
        return;
      }
      setState(() {
        isAuthenticating = true;
      });
      try {
        if (_isLoggedIn) {
          final userCredentials = await firebase.signInWithEmailAndPassword(
              email: email!, password: password!);
        } else {
          final userCredentials = await firebase.createUserWithEmailAndPassword(
              email: email!, password: password!);
          final path = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${userCredentials.user!.uid}.jpg');
          await path.putFile(userImage!);
          final imagePathUrl = await path.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('user')
              .doc(userCredentials.user!.uid)
              .set({
            'user_name': userName,
            'user_id': email,
            'user_image': imagePathUrl
          });
        }
      } on FirebaseAuthException catch (error) {
        setState(() {
          isAuthenticating = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            error.message!,
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 4),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 300,
                height: 300,
                margin: const EdgeInsets.only(top: 100),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Image.asset('assets/images/chat.png')),
            Card(
              color: Theme.of(context).cardColor,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              elevation: 2.0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      if (!_isLoggedIn)
                        UserImagePicker(onpickImage: (image) {
                          userImage = image;
                        }),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Email'),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Enter a valid email';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (newValue) {
                          email = newValue;
                        },
                      ),
                      if (!_isLoggedIn)
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null || value.trim().length < 4) {
                              return 'Username must contain atleast 4 characters.';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (newValue) {
                            userName = newValue;
                          },
                        ),
                      TextFormField(
                        decoration: InputDecoration(
                            label: const Text('Password'),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _togglePwd = !_togglePwd;
                                  });
                                },
                                icon: const Icon(Icons.remove_red_eye))),
                        obscureText: _togglePwd,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password should be atleast 6 characters long';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (newValue) {
                          password = newValue;
                        },
                      ),
                      if (!_isLoggedIn)
                        TextFormField(
                          decoration: const InputDecoration(
                            label: Text('Confirm Password'),
                          ),
                          obscureText: _togglePwd,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be atleast 6 characters long';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (newValue) {
                            confirmPwd = newValue;
                          },
                        ),
                      const SizedBox(
                        height: 14,
                      ),
                      if (isAuthenticating) const CircularProgressIndicator(),
                      if (!isAuthenticating)
                        ElevatedButton(
                          onPressed: saveState,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer),
                          child: Text(_isLoggedIn ? 'Login' : 'Sign Up'),
                        ),
                      if (!isAuthenticating)
                        TextButton(
                            onPressed: () {
                              setState(() {
                                formKey.currentState!.reset();
                                _isLoggedIn = !_isLoggedIn;
                              });
                            },
                            child: Text(_isLoggedIn
                                ? 'Not a user Yet?'
                                : 'Have an account?')),
                      const SizedBox(
                        height: 8,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
