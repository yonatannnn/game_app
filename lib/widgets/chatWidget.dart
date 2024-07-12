import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  final String message;
  final String currentUsername;

  ChatWidget({required this.message, required this.currentUsername});

  @override
  Widget build(BuildContext context) {
    String senderName = message.split('lijalemewithseparator')[0];
    String actualMessage = message.split('lijalemewithseparator')[1];

    bool isCurrentUser = senderName == currentUsername;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue : Colors.brown,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            actualMessage,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
