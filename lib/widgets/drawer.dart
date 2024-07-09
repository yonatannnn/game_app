import 'package:flutter/material.dart';
import 'package:game_app/screens/AboutScreen.dart';
import 'package:game_app/services/authService.dart';
import 'package:game_app/services/userService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Drawer(
            child: Center(
              child: Text('Error loading user data'),
            ),
          );
        } else {
          final String username = snapshot.data ?? 'Unknown';

          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: FutureBuilder<String>(
                    future: _loadUserName(username),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      } else if (snapshot.hasError) {
                        return Text('Error');
                      } else {
                        final String userName = snapshot.data ?? 'Unknown';
                        return Text(userName);
                      }
                    },
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      username.isNotEmpty
                          ? username.substring(0, 2).toUpperCase()
                          : '',
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  accountEmail: null,
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    // Navigate to home screen
                    Navigator.pop(context); // Close the drawer
                    // Add your navigation logic here
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile'),
                  onTap: () {
                    // Navigate to profile screen
                    Navigator.pop(context); // Close the drawer
                    // Add your navigation logic here
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('About'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () {
                    AuthService().signOutWithConfirmation(context);
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<String> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'Unknown';
  }

  Future<String> _loadUserName(String userId) async {
    try {
      final userService = UserService();
      final user = await userService.findUserById(userId);
      return '${user?.firstName} ${user?.lastName}';
    } catch (e) {
      print('Error fetching user: $e');
      return 'Unknown';
    }
  }
}
