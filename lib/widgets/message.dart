import 'package:chatMate/screens/show_pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  Message(this.msg,this.isMe,this.time,this.isPic);
  final String msg;
  final bool isMe;
  final Timestamp time;
  final String isPic;
  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: widget.isMe? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width*0.46,
              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
              decoration: BoxDecoration(color: widget.isMe ? Colors.blue:Colors.black87,borderRadius: BorderRadius.only(topLeft: widget.isMe ? Radius.circular(12):Radius.circular(0),topRight: !widget.isMe ? Radius.circular(12):Radius.circular(0),bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
              child: widget.isPic=='no' ? Text(widget.msg,style: TextStyle(color: Colors.white,fontSize: 16),) : GestureDetector(child: Container(child: Image.network(widget.msg,fit: BoxFit.contain,)),onTap: (){
                Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
                  return ShowPic(widget.msg);
                }));
                }),
            ),
          
          Text((DateTime.fromMillisecondsSinceEpoch(widget.time.seconds*1000,isUtc: false)).toString().substring(0,(DateTime.fromMillisecondsSinceEpoch(widget.time.seconds*1000,isUtc: false)).toString().lastIndexOf(':')),style: TextStyle(fontWeight:FontWeight.bold),),
          ],
        ),
      ],
    );
  }
}