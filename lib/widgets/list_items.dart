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

class ListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onClickItem;
  final VoidCallback onClickIcon;

  const ListItem(
      {Key? key,
      required this.icon,
      required this.title,
      required this.onClickItem,
      required this.onClickIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      leading: IconButton(onPressed: onClickIcon, icon: Icon(icon)),
      title: Text(title),
      onTap: onClickItem,
    );
  }
}

class ViewItem extends StatelessWidget {
  final String keyText;
  final String valueText;

  const ViewItem({Key? key, required this.keyText, required this.valueText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      leading: Text(keyText.replaceAll("_", " ").replaceFirst(keyText.substring(0,1), keyText.substring(0,1).toString().toUpperCase())),
      trailing: Text(valueText),
    );
  }
}

class MapUnit {
  final String key;
  final String value;

  MapUnit(this.key, this.value);
}

class ViewPageItem extends StatelessWidget {

  final List<MapUnit> list ;
  final String title;

  const ViewPageItem({Key? key, required this.list, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: list.length,
          itemBuilder: (ctx, index) => ViewItem(
              keyText: list.elementAt(index).key,
              valueText: list.elementAt(index).value)),
    );
  }
}
