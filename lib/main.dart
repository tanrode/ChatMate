import 'package:chatMate/screens/chat_home_screen.dart';
import 'package:chatMate/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './screens/chat_screen.dart';
import './screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String username;
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chatMate',
      theme: ThemeData(
        primaryColor: Colors.green,
        primarySwatch: Colors.green,
        backgroundColor: Colors.green,
        accentColor: Colors.blue,
        accentColorBrightness: Brightness.dark,
        buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Colors.black87,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.green),
                borderRadius: BorderRadius.circular(15))),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
          backgroundColor: Colors.green[200],
          body: StreamBuilder(stream: FirebaseAuth.instance.onAuthStateChanged, builder: (ctx, snapshot) {
            if(snapshot.hasData){
              Firestore.instance.collection('users').getDocuments().then((querySnapshot) {
                        querySnapshot.documents.forEach((result) {
                          if(result.documentID==snapshot.data.uid)
                            username=result.data['username'];
                        });
              });
              //print('Username in main: '+username);
              return LoadingScreen(snapshot.data.uid);//ChatHomeScreen(snapshot.data.uid,username);
            }
            return AuthScreen();
          })),
      debugShowCheckedModeBanner: false,
    );
  }
}
