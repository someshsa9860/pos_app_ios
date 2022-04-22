import 'package:flutter/material.dart';
import 'package:pos_app/widgets/app_drawer.dart';

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
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          onTap: onClick,
        ),
        const Divider(),
      ],
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
    return Column(
      children: [
        ListTile(
          trailing: IconButton(
              onPressed: onClickIcon,
              icon: Icon(
                icon,
                color: Theme.of(context).colorScheme.secondary,
              )),
          leading: Text(title),
          onTap: onClickItem,
        ),
        const Divider(),
      ],
    );
  }
}

class ViewItem extends StatelessWidget {
  final keyText;
  final valueText;

  const ViewItem({Key? key, required this.keyText, required this.valueText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              keyText.toString().replaceAll("_", " ").replaceFirst(
                  keyText.substring(0, 1),
                  keyText.substring(0, 1).toString().toUpperCase()),
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valueText.toString(),
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  String getText(String valueText) {
    return valueText
        .replaceAll("_", " ")
        .replaceAll(']', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll('[', '')
        .split(',')
        .join('\n');
  }
}

class MapUnit {
  final String key;
  final String value;

  MapUnit(this.key, this.value);
}

class ViewPageItem extends StatelessWidget {
  final List<MapUnit> list;

  final String title;
  final String mapKey;

  const ViewPageItem(
      {Key? key, required this.list, required this.title, this.mapKey = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, index) {
                return ViewItem(
                    keyText: list.elementAt(index).key,
                    valueText: list.elementAt(index).value);
              }),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
