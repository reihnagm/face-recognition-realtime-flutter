import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoggedInPage extends StatefulWidget {
  final String username;

  const LoggedInPage({
    required this.username,
    super.key
  });

  @override
  State<LoggedInPage> createState() => LoggedInPageState();
}

class LoggedInPageState extends State<LoggedInPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFE1717),
        centerTitle: true,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Home Page",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.bold
          ),
        )
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
      
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
      
                  const Text("Already logged In",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
              
                  const SizedBox(height: 10.0),
              
                  Text(widget.username,
                    style: const TextStyle(
                      color: Colors.black
                    ),
                  )
      
                ],
              ),
      
            ],
          ),
      
      
        ],
      ),
    );
  }
  
}