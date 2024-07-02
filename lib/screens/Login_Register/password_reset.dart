import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants.dart';
import '../../screens/Login_Register/login_page.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  fillColor: Color(0xFFE5E5E5),
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: keventbuttonstyle(
                    backgroundColor: Colors.lightGreen,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.green),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _resetPassword();
                  }
                },
                child: Text(
                  'Reset Password',
                  style: kDateTextStyle.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: MediaQuery.sizeOf(context).width * 0.8,
                child: ElevatedButton(
                  style: keventbuttonstyle(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.blue),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Back to Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
      _showSnackBar('Password reset email sent');
    } catch (error) {
      String errorMessage = 'Error sending reset email: $error';
      _showSnackBar(errorMessage);
      print(errorMessage);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
