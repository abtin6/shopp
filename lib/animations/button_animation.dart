import 'package:flutter/material.dart';
import 'package:shopapp/constants.dart' as Const;

class buttonAnimation extends StatelessWidget {
  final Animation<double> controller;
  final Animation<double> buttonSqueezAnimation;
  final Animation<double> buttonZoomOut;
  final label;
  buttonAnimation({this.controller,this.label}):
        buttonSqueezAnimation = Tween(begin: 280.0, end: 60.0).animate(CurvedAnimation(parent: controller, curve: Interval(0.0, 0.150))),
        buttonZoomOut = Tween(begin: 70.0, end: 1000.0).animate(CurvedAnimation(parent: controller, curve: Interval(0.550, 0.999, curve: Curves.bounceOut)));

  Widget _animationBuilder(BuildContext context, Widget child){
    return buttonZoomOut.value <= 300
        ? Container(
          margin: EdgeInsets.only(bottom: 10),
          width: buttonZoomOut.value == 70 ? buttonSqueezAnimation.value : buttonZoomOut.value,
          height: buttonZoomOut.value == 70 ? 50 : buttonZoomOut.value,
          decoration: BoxDecoration(
              color: Const.LayoutColor,
              borderRadius: buttonZoomOut.value < 400 ? BorderRadius.all(const Radius.circular(5)) : BorderRadius.all(const Radius.circular(0)),
          ),
          alignment: Alignment.center,
          child: buttonSqueezAnimation.value > 75
              ? Text(this.label, style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w300,letterSpacing: .3),)
              : buttonZoomOut.value < 300 ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : null,
        )
        : Container(
              width: buttonZoomOut.value, height: buttonZoomOut.value,
              decoration: BoxDecoration(
                shape: buttonZoomOut.value < 500 ? BoxShape.circle : BoxShape.rectangle,
                color: const Color(0xff075e54)
              )
          );
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: controller, builder: _animationBuilder);
  }
}