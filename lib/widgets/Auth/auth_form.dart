//The login/Signup form 
import 'package:chatMate/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn,this.isLoading);
  final void Function(String email,String username,String password,bool isLogin,BuildContext ctx) submitFn;
  final bool isLoading;
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _userEmail = '';
  String _username = '';
  String _password = '';
  bool isLogin = true;
  @override
  Widget build(BuildContext context) {
    return Center(
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
                        onSaved: (value) {
                          _password = value;
                        }),
                    SizedBox(
                      height: 15,
                    ),
                    if(widget.isLoading)
                      CircularProgressIndicator(),
                    if(!widget.isLoading)
                      RaisedButton(
                          child: Text(isLogin ? 'Login' : 'Sign up',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            final validity = _formKey.currentState.validate();
                            FocusScope.of(context)
                                .unfocus(); // To pop the virtual keyboard
                            if (validity) _formKey.currentState.save();
                            widget.submitFn(_userEmail.trim(),_username.trim(),_password,isLogin,context);
                            //Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
                            //  return ChatScreen();
                            //}));
                          }),
                    SizedBox(
                      height: 6,
                    ),
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
                  ],
                ))),
      ),
    );
  }
}
