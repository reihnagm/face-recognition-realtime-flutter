import 'package:flutter/material.dart';

class NavigateToPresence extends StatefulWidget {

  final String username;
  const NavigateToPresence({
    required this.username,
    super.key
  });

  @override
  State<NavigateToPresence> createState() => MyWidgetState();
}

class MyWidgetState extends State<NavigateToPresence> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Presence",
          style: TextStyle(
            fontSize: 22.0
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Hello ${widget.username}")
      )
    );
  }

}