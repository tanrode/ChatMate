import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class ChangePassword extends StatelessWidget 
{
  ChangePassword(this._fbUser,this.ctx);
  final FirebaseAuth _fbUser;
  final BuildContext ctx;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final control=TextEditingController();
  String _userEmail='';
  @override
  Widget build(BuildContext context) {

    Future<void> _showResetDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Password Change Request'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Password change link has been sent to the entered Email address'),
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
                  }),
            ],
          );
        },
      );
    }

    Future<void> _showErrorDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Request Failed'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please check the entered Email address.'),
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
          "Change Password",
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
                        controller: control,
                        key: Key('email'),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Enter your registered Email address'),
                        onChanged: (value) {
                          _userEmail= value;
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      RaisedButton(
                          child: Text('Change Password',
                              style: TextStyle(color: Colors.white)),
                          onPressed: ()async {
                            try{
                              FocusScope.of(context).unfocus();
                              await _fbUser.sendPasswordResetEmail(email: _userEmail);
                              _showResetDialog();
                              //Scaffold.of(ctx).showSnackBar(SnackBar(content: Text('Password reset link has been sent to your email address.'), backgroundColor: Colors.red,)); 
                            }
                            catch(err)
                            {
                              print(err);
                              _showErrorDialog();
                              //Scaffold.of(ctx).showSnackBar(SnackBar(content: Text('Request Failed. Please check your email address.'), backgroundColor: Colors.red,));
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