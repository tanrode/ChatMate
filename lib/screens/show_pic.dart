import 'package:flutter/material.dart';

class ShowPic extends StatelessWidget {
  final String url;
  ShowPic(this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Container(
        alignment: Alignment.center,
        child: Image.network(url,fit: BoxFit.fill,),
      )
    );
  }
}