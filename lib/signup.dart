import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Create a new collection for the user
          String uid = userCredential.user!.uid;
          await FirebaseFirestore.instance.collection('users').doc(uid).set({});
          await FirebaseFirestore.instance.collection('users').doc(uid).collection('notes').add({
            'note': 'Welcome Note!',
            'timestamp': Timestamp.now(),
          });

          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/home');
        } catch (e) {
          setState(() {
            _errorMessage = e.toString();
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Passwords do not match';
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 110),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter Email',
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Please Enter your Email' : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter Password',
                          prefixIcon: Icon(
                            Icons.key,
                            color: Colors.black,
                          ),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Please Enter your Password' : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Enter Password to Confirm',
                          prefixIcon: Icon(
                            Icons.key,
                            color: Colors.black,
                          ),
                          border: UnderlineInputBorder(),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Please Enter your Password' : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 120),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          onPressed: _signUp,
                          color: Colors.black,
                          textColor: Colors.white,
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 70, bottom: 20),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already a Member? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            InkWell(
                              onTap: _navigateToLogin,
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.normal,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
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
