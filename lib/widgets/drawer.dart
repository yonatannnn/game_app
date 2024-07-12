import 'package:flutter/material.dart';
import 'package:game_app/screens/AboutScreen.dart';
import 'package:game_app/screens/GlobalRankScreen.dart';
import 'package:game_app/screens/LandingScreen.dart';
import 'package:game_app/screens/descriptionPage.dart';
import 'package:game_app/screens/gamesScreen.dart';
import 'package:game_app/screens/usersScreen.dart';
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
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                      image: AssetImage('assets/secretNumbers.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Expanded(child: Container()),
                      FutureBuilder<String>(
                        future: _loadUserName(username),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              'Loading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            );
                          } else {
                            final String userName = snapshot.data ?? 'Unknown';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                userName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Landingscreen()));
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.arrow_back),
                  title: Text('Global Rank'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GlobalRankScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Description'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DescriptionPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.album_sharp),
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
                if (username == 'yonatan')
                  ListTile(
                    leading: Icon(Icons.man),
                    title: Text('Users'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UsersScreen()));
                    },
                  ),
                if (username == 'yonatan')
                  ListTile(
                    leading: Icon(Icons.games),
                    title: Text('Games'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GamesScreen()));
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
