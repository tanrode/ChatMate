import 'package:chatMate/screens/add_new_chat.dart';
import 'package:chatMate/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatHomeScreen extends StatefulWidget {
  ChatHomeScreen(this.userId,this.username);
  final String userId;
  final String username;
  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  
  void initState()
  {
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
      appBar: AppBar(
        title: Text(
          'ChatMate',
          style: TextStyle(
              color: Colors.green, fontSize: 28, fontWeight: FontWeight.w800),
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
                  print('username:'+widget.username);
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
                                  color: Colors.green,
                                  width: MediaQuery.of(context).size.width*0.7,
                                  height: 40,
                                  child: Card(
                                    color: Colors.blue,
                                    child: Text(widget.username==documents[ind]['chatNameOwner'] ? documents[ind]['chatNameOther'] : documents[ind]['chatNameOwner'],style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
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
                            });
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
