import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/Auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _fbUser = FirebaseAuth.instance;
  var _isLoading=false;
  void submittedDetails(String email,String username,String password,bool isLogin,BuildContext ctx,File image) async
  {
    AuthResult result;
    try{
      setState(() {
          _isLoading=true;
      });
      if(isLogin==true)
      {
        result = await _fbUser.signInWithEmailAndPassword(email: email, password: password);
      }
      else
      {
        result = await _fbUser.createUserWithEmailAndPassword(email: email, password: password);
        final ref= FirebaseStorage.instance.ref().child('user_profile_pics').child(email+'.jpg');
        await ref.putFile(image).onComplete;
        final url = await ref.getDownloadURL();
        await Firestore.instance.collection('users').document(result.user.uid).setData({
          'username':username,
          'email':email,
          'picUrl':url,
        });
      }
    }
    on PlatformException catch(err){
      var msg= isLogin ? 'Login Unsuccessful, please check your credentials' : 'Sign up unsuccessful, please check your credentials';
      setState(() {
        _isLoading=false;
      });
      //To show snackbar to the user
      Scaffold.of(ctx).showSnackBar(SnackBar(content: Text(msg+''),backgroundColor: Colors.red,));
    }
    catch(err)
    {
      print(err);
      setState(() {
        _isLoading=false;
      });
    }
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(title: Text('ChatMate',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),centerTitle: true,backgroundColor: Colors.black87,),
      backgroundColor: Colors.green,
      body: AuthForm(submittedDetails,_isLoading),
      bottomNavigationBar: Container(padding: EdgeInsets.all(3),color: Colors.black87,child: Text('\u00A9 Created by TanLabs',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center)),
    );
  }
}
