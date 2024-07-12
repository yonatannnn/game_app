import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_app/models/userModel.dart';
import 'package:game_app/services/userService.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
            icon: Icon(
              Icons.do_not_touch,
              color: Colors.blue,
            ),
          )
        ],
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<List<User>>(
        stream: UserService().fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: GoogleFonts.aBeeZee(color: Colors.white)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('Game not found',
                    style: GoogleFonts.aBeeZee(color: Colors.white)));
          }

          List<User> users = snapshot.data!;

          return ListView.separated(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${users[index].firstName} ${users[index].lastName}',
                      style: GoogleFonts.aBeeZee(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text('${users[index].userName}',
                        style: GoogleFonts.aBeeZee(
                            fontSize: 13, color: Colors.white)),
                    if (showPassword)
                      Text('${users[index].password}',
                          style: GoogleFonts.aBeeZee(
                              fontSize: 13, color: Colors.white))
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(color: Colors.white),
            itemCount: users.length,
          );
        },
      ),
    );
  }
}
