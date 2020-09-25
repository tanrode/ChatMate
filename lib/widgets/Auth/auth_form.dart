//The login/Signup form 
import 'dart:io';
import 'package:chatMate/screens/change_password.dart';
import 'package:chatMate/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn,this.isLoading,this._fbUser);
  final void Function(String email,String username,String password,bool isLogin,BuildContext ctx,File image) submitFn;
  final bool isLoading;
  final FirebaseAuth _fbUser;
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _username = '';
  String _password = '';
  String _confirmPassword='';
  bool isLogin = true;
  File _image;

  void _pickImageCamera()async
  {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera, imageQuality: 20);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _image = pickedImageFile;
    });
  }
  void _pickImageDevice()async
  {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery,imageQuality: 20);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _image = pickedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<dynamic> _showImageOptions()
    {
      return showModalBottomSheet(context: context, builder: (context){
        return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.green,width: 4)),
          height: 120,
          child: Column(
            children:[
              FlatButton.icon(onPressed: (){
                _pickImageCamera();
                Navigator.of(context).pop();
                }, icon: Icon(Icons.camera_alt), label: Text('Click a picture')),
              FlatButton.icon(onPressed: (){
                _pickImageDevice();
                Navigator.of(context).pop();
                }, icon: Icon(Icons.image), label: Text('Upload from device'))
            ],
          ),
        );
      });
    }

    return Center(
      child: Card(
        margin: EdgeInsets.all(5),
        child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Form(
                key: _formKey,
                child: Column(
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    if(!isLogin)
                      CircleAvatar(child: _image==null ? Icon(Icons.person,color: Colors.black,size: 60,):null , radius: 40,backgroundColor: Colors.grey,backgroundImage: _image==null ? null : FileImage(_image),),
                    if(!isLogin)
                      FlatButton.icon(onPressed: (){
                        _showImageOptions();
                      }, icon: Icon(Icons.camera_alt), label: Text('Add Profile Picture')),
                    TextFormField(
                      key: Key('email'),
                      validator: (value) {
                        if (value.isEmpty ||
                            !value.contains('@') ||
                            !value.contains('.') ||
                            value.length < 10)
                          return 'Enter a valid email address';
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email address'),
                      onSaved: (value) {
                        _userEmail = value;
                      },
                    ),
                    if(!isLogin)
                      TextFormField(
                          key: Key('username'),
                          validator: (value) {
                            if (value.isEmpty || value.length < 3)
                              return 'Username must be atleast 3 characters long';
                            return null;
                          },
                          decoration: InputDecoration(labelText: 'Username'),
                          onSaved: (value) {
                            _username = value;
                          }),
                    TextFormField(
                        key: Key('password'),
                        validator: (value) {
                          if (value.isEmpty || value.length < 7)
                            return 'Password must be minimum 7 characters long';
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                        onChanged: (value) {
                          _password = value;
                        }),
                        if(!isLogin)
                          TextFormField(
                              key: Key('confirm password'),
                              validator: (value) {
                                if (value.isEmpty || value.length < 7)
                                  return 'Password must be minimum 7 characters long';
                                return null;
                              },
                              obscureText: true,
                              decoration: InputDecoration(labelText: 'Confirm Password'),
                              onChanged: (value) {
                                _confirmPassword = value;
                              }),
                    SizedBox(
                      height: 3,
                    ),
                    if(widget.isLoading)
                      CircularProgressIndicator(),
                    if(!widget.isLoading)
                      RaisedButton(
                          child: Text(isLogin ? 'Login' : 'Sign up',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            if(_image==null && !isLogin)
                            {
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please select a profile picture'),backgroundColor: Colors.red ));
                              return;
                            }
                            if(!isLogin && _password!=_confirmPassword)
                            {
                              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Entries in the Password and Confirm Password fields do not match.'),backgroundColor: Colors.red ));
                              return;
                            }
                            final validity = _formKey.currentState.validate();
                            FocusScope.of(context)
                                .unfocus(); // To pop the virtual keyboard
                            if (validity) _formKey.currentState.save();
                            widget.submitFn(_userEmail.trim(),_username.trim(),_password,isLogin,context,_image);
                            //Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
                            //  return ChatScreen();
                            //}));
                          }),
                    if(!widget.isLoading)
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(isLogin
                              ? 'New Member? Sign Up'
                              : 'Already have an account? Login')),
                    if(!widget.isLoading && isLogin)
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
                              return ChangePassword(widget._fbUser,ctx);
                            }));
                          },
                          child: Text('Forgot Password?')),
                  ],
                ))),
      ),
    );
  }
}
