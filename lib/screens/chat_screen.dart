import 'package:chatMate/widgets/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  ChatScreen(this.docId, this.chatOtherPerson, this.chatOwner, this.currUser);
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
  File _image;

  void initState() {
    final fbm = FirebaseMessaging();
    fbm.configure(
      onMessage: (msg) {
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

  void _pickImageCamera(String userId) async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.getImage(source: ImageSource.camera, imageQuality: 100);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _image = pickedImageFile;
    });
    final timeSent = Timestamp.now().toString();
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_pics')
        .child(userId + timeSent + '.jpg');
    await ref.putFile(_image).onComplete;
    final url = await ref.getDownloadURL();
    await Firestore.instance.collection('/chats/${widget.docId}/messages').add({
      'text': url,
      'timeStamp': Timestamp.now(),
      'userId': userId,
      'isPic': 'yes',
    });
  }

  void _pickImageDevice(String userId) async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _image = pickedImageFile;
    });
    final timeSent = Timestamp.now().toString();
    final ref = FirebaseStorage.instance
        .ref()
        .child('chat_pics')
        .child(userId + timeSent + '.jpg');
    await ref.putFile(_image).onComplete;
    final url = await ref.getDownloadURL();
    await Firestore.instance.collection('/chats/${widget.docId}/messages').add({
      'text': url,
      'timeStamp': Timestamp.now(),
      'userId': userId,
      'isPic': 'yes',
    });
  }

  @override
  Widget build(BuildContext context) {
    
    Future<dynamic> _showImageOptions(String userId) {
      return showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 4)),
              height: 120,
              child: Column(
                children: [
                  FlatButton.icon(
                      onPressed: () {
                        _pickImageCamera(userId);
                        Navigator.of(context).pop();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text('Click a picture')),
                  FlatButton.icon(
                      onPressed: () {
                        _pickImageDevice(userId);
                        Navigator.of(context).pop();
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(Icons.image),
                      label: Text('Upload from device'))
                ],
              ),
            );
          });
    }

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text(
          widget.currUser == widget.chatOwner
              ? widget.chatOtherPerson
              : widget.chatOwner,
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
                                          documents[ind]['timeStamp'],
                                          documents[ind]['isPic']),
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
                          'isPic': 'no',
                        });
                        //print(user.uid);
                        control.clear();
                      }
                    }),
                IconButton(
                    icon: Icon(Icons.camera_alt,color: Colors.blue,),
                    onPressed: () async {
                      final user = await FirebaseAuth.instance.currentUser();
                      _showImageOptions(user.uid);
                    }),
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
