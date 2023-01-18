import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  final comment;
  CommentList({@required this.comment});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10,bottom: 10,left: 10),
      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.black12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(comment['title'], style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),overflow: TextOverflow.ellipsis),
          SizedBox(height: 15),
          Text(comment['date'] + ' ~ ' + comment['name']),
          Divider(thickness: 1,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: Text(comment['text'], style: TextStyle(fontSize: 14,height: 2)),
            ),
          ),
        ],
      ),
    );
  }

}