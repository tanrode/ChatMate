import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  Message(this.msg,this.isMe);
  final String msg;
  final bool isMe;
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.isMe? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width*0.4,
          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
          decoration: BoxDecoration(color: widget.isMe ? Colors.blue:Colors.black87,borderRadius: BorderRadius.only(topLeft: widget.isMe ? Radius.circular(12):Radius.circular(0),topRight: !widget.isMe ? Radius.circular(12):Radius.circular(0),bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
          child: Text(widget.msg,style: TextStyle(color: Colors.white,fontSize: 16),),
        ),
      ],
    );
  }
}