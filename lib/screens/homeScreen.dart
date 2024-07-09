import 'package:flutter/material.dart';
import 'package:game_app/models/requestModel.dart';
import 'package:game_app/services/authService.dart';
import 'package:game_app/services/requestService.dart';
import 'package:game_app/widgets/myTextField.dart';
import 'package:game_app/widgets/receivedRequestList.dart';
import 'package:game_app/widgets/requestLists.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final AuthService _authService = AuthService();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _receiverController = TextEditingController();
  final RequestService _requestService = RequestService();
  late String _username;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game Requests',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              _showSignOutConfirmationDialog(context);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Container(
        padding: EdgeInsets.all(15),
        child: _selectedIndex == 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRequestForm(),
                  SizedBox(height: 20),
                  Text(
                    'Received Requests',
                    style:
                        GoogleFonts.aBeeZee(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Expanded(child: ReceivedRequestsLists()),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRequestForm(),
                  SizedBox(height: 20),
                  Text(
                    'Sent Requests',
                    style:
                        GoogleFonts.aBeeZee(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Expanded(child: RequestsLists()),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Received',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Sent',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _receiverController,
          decoration: InputDecoration(
            labelText: 'Receiver Username',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            _sendRequest();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: Text(
            'Send Request',
            style: GoogleFonts.aBeeZee(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Future<void> _sendRequest() async {
    String receiverUsername = _receiverController.text.trim();
    if (receiverUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a receiver username')),
      );
      return;
    }

    if (_username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username not found in SharedPreferences')),
      );
      return;
    }

    try {
      List<String> UserName = [_username, receiverUsername];
      UserName.sort();
      String ID = UserName.join("-");
      RequestModel request = RequestModel(
        date: DateTime.now(),
        id: '$ID',
        senderId: _username,
        receiverId: receiverUsername,
        requestNumber: 1,
        status: '-',
      );

      // Send the request
      await _requestService.sendRequest(request);

      // Clear the text field
      _receiverController.clear();
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  Future<void> _showSignOutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign Out'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to sign out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () async {
                try {
                  await widget._authService.signOut();
                  context.go('/login');
                } catch (e) {
                  print('Error signing out: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
