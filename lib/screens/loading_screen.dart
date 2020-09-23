import 'package:chatMate/screens/chat_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen(this.userId);
  final String userId;
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String username;
  String imageUrl;
  void initState() {
    /*Firestore.instance.collection('users').getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        if (result.documentID == widget.userId)
          username = result.data['username'];
      });
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: FutureBuilder(
          future: Firestore.instance
              .collection('users')
              .getDocuments()
              .then((querySnapshot) {
            querySnapshot.documents.forEach((result) {
              if (result.documentID == widget.userId){
                username = result.data['username'];
                imageUrl = result.data['picUrl'];
              }
            });
          }),
          builder: (ctx, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            return ChatHomeScreen(widget.userId, username,imageUrl);
          }),
    );
  }
}
