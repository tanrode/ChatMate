import 'package:chatMate/widgets/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(this.docId,this.chatOtherPerson,this.chatOwner,this.currUser);
  final String docId;
  final String chatOtherPerson;
  final String chatOwner;
  final String currUser;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String msg = '';
  final control = TextEditingController();

  void initState()
  {
    final fbm = FirebaseMessaging();
    fbm.configure(onMessage: (msg){
      print(msg);
      return;
    },
    onLaunch: (msg) {
      print(msg);
      return;
    },
    onResume: (msg) {
      print(msg);
      return;
    },
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Do you want to Logout from the app?'),
                ],
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                  child: Text('Yes'),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop();
                  }),
              RaisedButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text(
          widget.currUser==widget.chatOwner ? widget.chatOtherPerson : widget.chatOwner,
          style: TextStyle(
              color: Colors.green, fontSize: 28, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: FutureBuilder(
                future: FirebaseAuth.instance.currentUser(),
                builder: (ctx, futureSnaphot) {
                  if (futureSnaphot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  return StreamBuilder(
                      stream: Firestore.instance
                          .collection('/chats/${widget.docId}/messages')
                          .orderBy('timeStamp', descending: true)
                          .snapshots(),
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final documents = snapshot.data.documents;
                        return FutureBuilder(
                            future: FirebaseAuth.instance.currentUser(),
                            builder: (ctx, futureSnaphot) {
                              if (futureSnaphot.connectionState ==
                                  ConnectionState.waiting)
                                return Center(
                                    child: CircularProgressIndicator());
                              return ListView.builder(
                                  reverse: true,
                                  itemCount: documents.length,
                                  itemBuilder: (ctx, ind) {
                                    return Container(
                                      padding: EdgeInsets.all(4),
                                      child: Message(
                                          documents[ind]['text'],
                                          documents[ind]['userId'] ==
                                              futureSnaphot.data.uid,
                                          documents[ind]['timeStamp']),
                                    );
                                  });
                            });
                      });
                }),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 45,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Container(
                        padding: EdgeInsets.only(left: 8),
                        color: Colors.white,
                        child: TextField(
                          controller: control,
                          onChanged: (e) => msg = e,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            fillColor: Colors.white,
                            enabledBorder: InputBorder.none,
                          ),
                        ))),
                IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      if (msg != '') {
                        final user = await FirebaseAuth.instance.currentUser();
                        Firestore.instance
                            .collection('/chats/${widget.docId}/messages')
                            .add({
                          'text': msg,
                          'timeStamp': Timestamp.now(),
                          'userId': user.uid,
                        });
                        //print(user.uid);
                        control.clear();
                      }
                    }),
                IconButton(icon: Icon(Icons.camera_alt), onPressed: null)
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
          padding: EdgeInsets.all(3),
          color: Colors.black87,
          child: Text('\u00A9 Created by TanLabs',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center)),
    );
  }
}
