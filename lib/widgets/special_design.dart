import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomRow extends StatelessWidget {
  final Widget? icon;
  final Widget child;
  final Color color;
  final Color iconColor;
  final double radius;
  final BorderStyle borderStyle;

  const CustomRow(
      {this.icon,
        required this.child,
        Key? key,
        this.color = Colors.white,
        this.iconColor = Colors.white,
        this.borderStyle=BorderStyle.none,
        this.radius = 24.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
              width: 0.4, color: Colors.grey, style: borderStyle)),
      child: Row(children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: icon,
          ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                    width: 0.5, color: Colors.grey, style: borderStyle)),
            child: child,
          ),
        ),
      ]),
    );
  }
}

class CustomButton extends StatelessWidget {
  final Widget? icon;
  final Widget child;
  final Color color;
  final MainAxisSize mainAxisSize;

  const CustomButton(
      {this.icon, required this.child, Key? key, this.color = Colors.white,this.mainAxisSize=MainAxisSize.min})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
              width: 0.5, color: Colors.grey, style: BorderStyle.none)),
      child: Row(
          mainAxisSize: mainAxisSize,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: icon,
              ),
            Container(
              decoration: const BoxDecoration(
                  border: Border.symmetric(
                      vertical: BorderSide(
                          width: 0.5,
                          color: Colors.grey,
                          style: BorderStyle.none))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: child,
              ),
            ),
          ]),
    );
  }
}
