import 'package:flutter/material.dart';
import 'package:game_app/screens/LoginScreen.dart';
import 'package:game_app/widgets/myTextField.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegistrationScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ConfirmPasswordController =
      TextEditingController();
  final TextEditingController _FirstNameController = TextEditingController();
  final TextEditingController _LastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SignUp Page',
                  style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: _FirstNameController,
                  labelText: 'First Name',
                  obscureText: false,
                ),
                SizedBox(height: 30),
                MyTextField(
                  controller: _LastNameController,
                  labelText: 'Last Name',
                  obscureText: false,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: _usernameController,
                  labelText: 'User Name',
                  obscureText: false,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: _passwordController,
                  labelText: 'password',
                  obscureText: true,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: _ConfirmPasswordController,
                  labelText: 'Confirm Password',
                  obscureText: true,
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Have an account?',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
