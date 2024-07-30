import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text,
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'You will receive the password reset link in your email',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 15),
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
                    borderRadius: BorderRadius.circular(10),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      onPressed: _resetPassword,
                      color: Colors.black,
                      textColor: Colors.white,
                      child: const Text('Submit'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
