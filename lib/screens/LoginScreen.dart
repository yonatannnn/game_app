import 'package:flutter/material.dart';
import 'package:game_app/screens/registrationScreen.dart';
import 'package:game_app/services/authService.dart';
import 'package:game_app/services/userService.dart';
import 'package:game_app/widgets/myTextField.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final userService = UserService();
  final authService = AuthService();

  bool _isLoading = false;

  Future<bool> checkUser(
      String username, String password, BuildContext context) async {
    try {
      final user = await userService.findUserById(username);
      if (user?.password == password) {
        return true;
      } else {
        _scaffoldKey.currentState?.showSnackBar(
          SnackBar(content: Text('Incorrect password')),
        );
        return false;
      }
    } catch (e) {
      _scaffoldKey.currentState?.showSnackBar(
        SnackBar(content: Text('Username not found!')),
      );
      return false;
    }
  }

  Future<void> saveUserData(String usernam) async {
    final username = usernam.toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
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
                    'Login Page',
                    style: GoogleFonts.aBeeZee(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  MyTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    obscureText: false,
                  ),
                  SizedBox(height: 20),
                  MyTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              bool isValidUser = await checkUser(
                                _usernameController.text,
                                _passwordController.text,
                                context,
                              );

                              if (isValidUser) {
                                try {
                                  await authService.signInAnonymously();
                                  await saveUserData(_usernameController.text);
                                  context.go('/landing');
                                } catch (e) {
                                  print(e.toString());
                                  _scaffoldKey.currentState?.showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error: ${e.toString()}')),
                                  );
                                }
                              }

                              setState(() {
                                _isLoading = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
