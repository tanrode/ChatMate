import 'package:chatMate/screens/add_new_chat.dart';
import 'package:chatMate/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatHomeScreen extends StatefulWidget {
  ChatHomeScreen(this.userId,this.username,this.imageUrl);
  final String userId;
  final String username;
  final String imageUrl;
  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  
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
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text('Yes'),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pop();
                  }),
              RaisedButton(
                color: Colors.black87,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(15)),
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

    Future<void> _confirmDeleteDialog(String id) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Do you want to Delete this chat? This is permanant and cannot be undone.'),
                ],
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text('Yes'),
                  onPressed: ()async{
                    Firestore.instance.collection('/chats').getDocuments().then((snapshot){
                      for (DocumentSnapshot ds in snapshot.documents){
                        if(ds.documentID==id) 
                          ds.reference.delete();
                      }
                    });
                    Navigator.of(context).pop();
                  }),
              RaisedButton(
                color: Colors.black87,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(15)),
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
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(backgroundImage: NetworkImage(widget.imageUrl),radius: 22,),
            Text(
              'ChatMate',
              style: TextStyle(
                  color: Colors.green, fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
        actions: <Widget>[
          DropdownButton(
              icon: Icon(Icons.more_vert),
              items: [
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.exit_to_app),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  value: 'logout',
                ),
              ],
              onChanged: (itemValue) {
                if (itemValue == 'logout') _showMyDialog();
              }),
        ],
      ),
      backgroundColor: Colors.green[100],
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
                stream: Firestore.instance.collection('/chats').snapshots(),
                builder: (ctx, snapshot) {
                  //print('username:'+widget.username);
                  //print(widget.owner);
                  //print(widget.other);
                  if(snapshot.connectionState == ConnectionState.waiting)
                  {
                    return CircularProgressIndicator();
                  }
                  final documents= snapshot.data.documents;
                  return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (ctx, ind) {
                        //print('username: '+widget.username);
                        //print('owner: '+documents[ind]['chatNameOwner']);
                        //print('other: '+documents[ind]['chatNameOther']);
                        //print('owner: '+widget.owner[ind].toString());
                        //print('other: '+widget.other[ind].toString());
                        //print(widget.username==widget.owner[ind].toString() || widget.username==widget.other[ind].toString());
                        if(widget.username==documents[ind]['chatNameOwner'].toString() || widget.username==documents[ind]['chatNameOther'].toString())
                        {
                          return GestureDetector(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Colors.green),
                                  width: MediaQuery.of(context).size.width*0.7,
                                  height: 70,
                                  child: Card(
                                    color: Colors.blue,
                                    child: Row(
                                      children: <Widget>[
                                        CircleAvatar(backgroundColor: Colors.grey, backgroundImage: widget.username==documents[ind]['chatNameOwner'] ? NetworkImage(documents[ind]['otherPicUrl']) : NetworkImage(documents[ind]['ownerPicUrl']),radius: 27,),
                                        Text(widget.username==documents[ind]['chatNameOwner'] ? documents[ind]['chatNameOther'] : documents[ind]['chatNameOwner'],style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
                                      ],
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: (){
                              print('tapped');
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (ctx) {
                                return ChatScreen(documents[ind].documentID,documents[ind]['chatNameOther'],documents[ind]['chatNameOwner'],widget.username);
                              }));
                            },
                            onLongPress: (){
                              _confirmDeleteDialog(documents[ind].documentID);
                            },
                            );
                        }
                        else
                        {
                          return SizedBox(height: 0);
                        }
                       /* return (username==own.toString() || username==other.toString()) ?
                        GestureDetector(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  color: Colors.green,
                                  width: MediaQuery.of(context).size.width*0.7,
                                  height: 40,
                                  child: Card(
                                    color: Colors.blue,
                                    child: Text(username==documents[ind]['chatNameOwner'] ? documents[ind]['chatNameOther'] : documents[ind]['chatNameOwner'],style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
                                  ),
                                ),
                              ],
                            ),
                            onTap: (){
                              print('tapped');
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (ctx) {
                                return ChatScreen(documents[ind].documentID,documents[ind]['chatNameOther'],documents[ind]['chatNameOwner'],username);
                              }));
                            }): SizedBox(height: 0);*/
                      });
                }),
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
      floatingActionButton: FlatButton(color: Colors.black87, onPressed: ()async{
        final user= await FirebaseAuth.instance.currentUser();
        Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
          return AddNewChat(user.uid);
        }));
      }, child: Icon(Icons.person_add,color: Colors.white,)),
    );
  }
}
