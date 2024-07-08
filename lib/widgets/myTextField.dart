import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  MyTextField({
    required this.controller,
    required this.labelText,
    required this.obscureText,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    showPassword = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(fontSize: 18, color: Colors.black),
        border: UnderlineInputBorder(),
        fillColor: Colors.white.withOpacity(0.8),
        filled: true,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              )
            : null,
      ),
      obscureText: widget.obscureText ? showPassword : false,
    );
  }
}
