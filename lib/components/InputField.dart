import 'package:flutter/material.dart';

class InputFieldArea extends StatelessWidget {

  final String hint;
  final bool obscure;
  final IconData icon;
  final validator;
  final onSaved;
  final controller;
  final int maxLines;

  InputFieldArea({this.hint, this.icon, this.obscure, this.validator, this.onSaved, this.controller, this.maxLines: 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: Color(0xFFF0F0F1),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(3)
        ),
      /*decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: Colors.white30)
        )
      ),*/
      child: TextFormField(
        maxLines: maxLines,
        controller: controller,
        onSaved: onSaved,
        validator: validator,
        obscureText: obscure,
        style: TextStyle(color: Color(0xFF868A8F),fontWeight: FontWeight.w400),
        decoration: InputDecoration(
          //icon: Icon(icon, color: Color(0xFF868A8F)),
          //border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF868A8F)),
          contentPadding: EdgeInsets.all(10),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white30)
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlueAccent,width: 2)
          ),
          errorStyle: TextStyle(color: Colors.red),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red)
          ),
          focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red)
          ),
        ),
      )
    );
  }
}