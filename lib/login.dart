import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot_password');
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/signup');
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
              padding: EdgeInsets.only(top: 150),
              child: Text(
                'Login',
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 20, bottom: 50),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: _navigateToForgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 130),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          onPressed: _login,
                          color: Colors.black,
                          textColor: Colors.white,
                          child: const Text('Login'),
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
                              'Not a member? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            InkWell(
                              onTap: _navigateToSignUp,
                              child: const Text(
                                'Sign Up',
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
