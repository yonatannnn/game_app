import 'package:flutter/material.dart';
import 'package:game_app/models/gameModel.dart';
import 'package:game_app/services/gameService.dart';
import 'package:game_app/widgets/chatWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatelessWidget {
  final String gameId;
  final TextEditingController _messageController = TextEditingController();

  ChatScreen({required this.gameId});

  @override
  Widget build(BuildContext context) {
    final _gameService = GameService();

    return FutureBuilder<String>(
      future: _getCurrentUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('Username not found'));
        }

        String currentUsername = snapshot.data!;

        return StreamBuilder<Game>(
          stream: _gameService.streamGameById(gameId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return Center(child: Text('Game not found'));
            }

            Game updatedGame = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: updatedGame.chat.length,
                    itemBuilder: (context, index) {
                      String message =
                          updatedGame.chat[updatedGame.chat.length - 1 - index];

                      return ChatWidget(
                        message: message,
                        currentUsername: currentUsername,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      IconButton(
                          onPressed: () async {
                            if (_messageController.text.trim().isNotEmpty) {
                              List<String> currentChat =
                                  List.from(updatedGame.chat);
                              String formattedMessage = '$currentUsername' +
                                  'lijalemewithseparator' +
                                  _messageController.text;
                              currentChat.add(formattedMessage);

                              try {
                                await _gameService.updateChat(
                                    gameId, currentChat);
                                _messageController.clear();
                              } catch (e) {
                                // Handle error
                                print('Failed to update chat: $e');
                              }
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String> _getCurrentUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }
}
