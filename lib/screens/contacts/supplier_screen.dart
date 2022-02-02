import 'package:flutter/material.dart';
import 'package:pos_app/provider/contact_provider.dart';
import 'package:pos_app/screens/contacts/add_contact_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/list_items.dart';
import 'package:provider/provider.dart';

enum Menu { csv, excel, print, colVis, pdf }

class ContactsSupplierScreen extends StatefulWidget {
  const ContactsSupplierScreen({Key? key}) : super(key: key);
  static const routeName = '/contacts-supplier';

  @override
  State<ContactsSupplierScreen> createState() => _ContactsSupplierScreenState();
}

class _ContactsSupplierScreenState extends State<ContactsSupplierScreen> {
  @override
  Widget build(BuildContext context) {
    final contacts = Provider.of<ContactsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddContact.routeName,
                    arguments: [ContactType.supplier, -1]);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton(
              itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      child: Text('Export to CSV'),
                      value: Menu.csv,
                    ),
                    const PopupMenuItem(
                      child: Text('Export to Excel'),
                      value: Menu.excel,
                    ),
                    const PopupMenuItem(
                      child: Text('Print'),
                      value: Menu.print,
                    ),
                    const PopupMenuItem(
                      child: Text('Column Visibility'),
                      value: Menu.colVis,
                    ),
                    const PopupMenuItem(
                      child: Text('Export to PDF'),
                      value: Menu.pdf,
                    ),
                  ])
        ],
      ),
      body: ListView.builder(
          itemCount: contacts.mapSupplyer.length,
          itemBuilder: (ctx, index) {
            return ListItem(
                icon: Icons.edit,
                title: contacts.getField('contact_id', index) ?? "nucll",
                onClickItem: () {
                  final List<MapUnit> listMap = [];
                  Map<String, dynamic> map = contacts.mapSupplyer[index];
                  map.forEach((key, value) {
                    if (value != null) {
                      listMap.add(MapUnit(key, value.toString()));
                    }
                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return ViewPageItem(
                        list: listMap,
                        title:
                            contacts.getField('contact_id', index) ?? "null");
                  }));
                },
                onClickIcon: () {
                  Navigator.of(context).pushNamed(AddContact.routeName,
                      arguments: [ContactType.supplier, index]);
                });
          }),
      drawer: AppDrawer(),
    );
  }

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final contacts = Provider.of<ContactsProvider>(context, listen: false);
      contacts.getContactSupplyer();
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
