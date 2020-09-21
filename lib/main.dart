import 'package:chatMate/screens/chat_home_screen.dart';
import 'package:chatMate/screens/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './screens/chat_screen.dart';
import './screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splashscreen/splashscreen.dart';

void main(){ 
  runApp(new MaterialApp(
    home: new MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        home: Center(
        child: new SplashScreen(
          seconds: 4,
          navigateAfterSeconds: new HomeScreen(),
          image: new Image.asset('images/ChatMate_splash_screen.png'),
          gradientBackground: new LinearGradient(colors: [Colors.green[200], Colors.green], begin: Alignment.topLeft, end: Alignment.bottomRight),
          backgroundColor: Colors.white,
          styleTextUnderTheLoader: new TextStyle(),
          photoSize: MediaQuery.of(context).size.width*0.4,
          //onClick: ()=>print("Flutter Egypt"),
          loaderColor: Colors.black,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
