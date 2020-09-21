import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddNewChat extends StatefulWidget {
  AddNewChat(this.id);
  final String id;
  @override
  _AddNewChatState createState() => _AddNewChatState();
}

class _AddNewChatState extends State<AddNewChat> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  bool validEmail=false;
  List<String> userEmails=[];
  List<String> usernames=[];
  String username;
  void initState()
  {
    Firestore.instance.collection('users').getDocuments().then((querySnapshot) {
                        querySnapshot.documents.forEach((result) {
                          print(result.documentID);
                          if(result.documentID==widget.id)
                            username=result.data['username'];
                          userEmails.add(result.data['email']);
                          usernames.add(result.data['username']);
                        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    Future<void> _showSuccessDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Successful'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('New Chat was successfully created.'),
                ],
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text('Done'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),
            ],
          );
        },
      );
    }

    Future<void> _showFailureDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Failed'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('The user with the entered email address does not exist.Please check the email address.'),
                ],
              ),
            ),
            actions: <Widget>[
              RaisedButton(
                  color: Colors.black87,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(15)),
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: Text(
          "ChatMate",
          style: TextStyle(
              color: Colors.green, fontSize: 28, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Center(
      child: SingleChildScrollView(
              child: Card(
          margin: EdgeInsets.all(5),
          child: SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        key: Key('email'),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Enter User\'s Email address'),
                        onChanged: (value) {
                          _userEmail = value;
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      RaisedButton(
                          child: Text('Create',
                              style: TextStyle(color: Colors.white)),
                          onPressed: ()async {
                          if(userEmails.contains(_userEmail)){
                            print('true');
                            int ind=userEmails.indexOf(_userEmail);
                            int ownerInd=usernames.indexOf(username);
                            final user = await FirebaseAuth.instance.currentUser();
                            print(_userEmail+' '+userEmails[ind]);
                            Firestore.instance.collection('chats').add({
                              'ownUser' : userEmails[ownerInd],
                              'otherUser': _userEmail,
                              'chatNameOwner':  username,
                              'chatNameOther': usernames[ind],
                            });
                            print(ind);
                            _showSuccessDialog();
                          }
                          else{
                            print('false');
                            _showFailureDialog();
                          }
                      }),
                      SizedBox(
                        height: 6,
                      ),
                    ],
                  ))),
        ),
      ),
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