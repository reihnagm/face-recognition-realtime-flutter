import 'package:face_recognition_realtime/login_page.dart';
import 'package:face_recognition_realtime/register_page.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthmenuPage extends StatefulWidget {
  const AuthmenuPage({super.key});

  @override
  State<AuthmenuPage> createState() => AuthmenuPageState();
}

class AuthmenuPageState extends State<AuthmenuPage> {

  @override
  void initState() {
    super.initState();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffFE1717),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Auth menu",
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
        mainAxisSize: MainAxisSize.max,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const LoginPage();
                      }));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:const Color(0xffFE1717),
                      textStyle: const TextStyle(
                        color: Color(0xffFFFFFF)
                      ),
                      minimumSize: const Size(200, 40)
                    ),
                    child: const Text("Login",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    )
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                        return const RegisterPage(
                          username: "Reihan Agam"
                        );
                      }));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:const Color(0xffFE1717),
                      textStyle: const TextStyle(
                        color: Color(0xffFFFFFF)
                      ),
                      minimumSize: const Size(200, 40)
                    ),
                    child: const Text("Register",
                      style: TextStyle(
                        color: Colors.white
                      ),
                    )
                  ),

                ],
              )

            ],
          )

       

        ],
      )
    );
  }
}