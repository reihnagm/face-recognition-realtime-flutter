// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:image/image.dart' as img;

// class NavigateToPresence extends StatefulWidget {

//   final img.Image? image;
//   final String username;
//   final String createdAt;

//   const NavigateToPresence({
//     required this.image,
//     required this.username,
//     required this.createdAt,
//     super.key
//   });

//   @override
//   State<NavigateToPresence> createState() => MyWidgetState();
// }

// class MyWidgetState extends State<NavigateToPresence> {

//   bool canPop = false;

//   void exitApp(bool didPop) {
//     if (!canPop) {
//       canPop = true;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Press back again to exit'),
//         ),
//       );
//     } else {
//       SystemNavigator.pop();
//     }
//   }

//   @override 
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {

//     return PopScope(
//       onPopInvoked: exitApp,
//       canPop: false,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Presence",
//             style: TextStyle(
//               fontSize: 22.0
//             ),
//           ),
//           automaticallyImplyLeading: false,
//         ),
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
      
//               Center(
//                 child: Image.memory(
//                   Uint8List.fromList(
//                     img.encodeBmp(widget.image!)
//                   ),
//                   width: 200.0,
//                   height: 200.0
//                 ),
//               ),
      
//               const SizedBox(height: 10.0),
      
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
      
//                   const Text("Name",
//                     style: TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.bold
//                     ),
//                   ),
//                   const SizedBox(width: 10.0),
//                   Text(widget.username,
//                     style: const TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.bold
//                     ),
//                   )
      
//                 ],
//               ),
      
//               const SizedBox(height: 6.0),
      
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.max,
//                 children: [
      
//                   const Text("Presence At",
//                     style: TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.bold
//                     ),
//                   ),
                  
//                   const SizedBox(width: 10.0),
      
//                   Text(widget.createdAt,
//                     style: const TextStyle(
//                       fontSize: 16.0,
//                       fontWeight: FontWeight.bold
//                     ),
//                   )
      
//                 ],
//               ),
      
//             ],
//           ) 
//         )
//       ),
//     );

//   }

// }