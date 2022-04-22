
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BorderRow extends StatelessWidget{
  final Widget? icon;
  final Widget child;

  const BorderRow({this.icon, required this.child,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return           Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 0.5,
              color: Colors.grey,
              style: BorderStyle.solid)),
      child: Row(children: [
        if(icon!=null)
         Padding(
          padding:const EdgeInsets.symmetric(horizontal: 12.0),
          child: icon,
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
                border: Border.symmetric(
                    vertical: BorderSide(
                        width: 0.5,
                        color: Colors.grey,
                        style: BorderStyle.solid))),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: child,
            ),
          ),
        ),
      ]),
    );

  }

}