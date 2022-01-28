import 'package:flutter/material.dart';

class ContentListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onClick;

  const ContentListItem(
      {Key? key,
      required this.icon,
      required this.title,
      required this.onClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onClick,
    );
  }
}
