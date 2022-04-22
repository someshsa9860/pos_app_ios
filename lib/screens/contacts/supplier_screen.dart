import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/provider/supplier_provider.dart';
import 'package:pos_app/screens/contacts/add_contact_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/refresh_widget.dart';
import 'package:provider/provider.dart';

class ContactsSupplierScreen extends StatefulWidget {
  const ContactsSupplierScreen({Key? key}) : super(key: key);
  static const routeName = '/contacts-supplier';

  @override
  State<ContactsSupplierScreen> createState() => _Screen();
}

class _Screen extends State<ContactsSupplierScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarName),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () => addEdit(-1), icon: const Icon(Icons.add)),
          ),
        ],
      ),
      body: Consumer<SupplierProvider>(
        builder: (BuildContext context, contacts, Widget? child) {
          return RefreshIndicator(
            onRefresh: () => refresh(contacts),
            child: getLength(contacts) == 0
                ? const Center(
                    child: MyCustomProgressBar(
                    msg: 'waiting response from server',
                  ))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _title(
                                    'Contact Id', constraints.maxWidth * 0.15),
                                _title('Business Name',
                                    constraints.maxWidth * 0.15),
                                _title('Name', constraints.maxWidth * 0.15),
                                _title('Email', constraints.maxWidth * 0.15),
                                _title('Edit', constraints.maxWidth * 0.15),
                              ],
                            );
                          },
                        ),
                      ),
                      Expanded(child: buildListView(contacts, context)),
                    ],
                  ),
          );
        },
      ),
      drawer: const AppDrawer(),
    );
  }

  var _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final contacts = Provider.of<SupplierProvider>(context, listen: false);
      refresh(contacts);
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  //screen-specific-changes

  final String appBarName = 'Suppler';

  //swipe-refresh
  Future<void> refresh(SupplierProvider contacts) async {
    await contacts.getData();
    await contacts.sync();
  }

  void addEdit(index) {
    Navigator.of(context).pushNamed(AddContact.routeName,
        arguments: [ContactType.supplier, index]);
  }

  setListForMenu(SupplierProvider value) {
    return value.mapData;
  }

  getLength(SupplierProvider contacts) {
    return contacts.mapData.length;
  }

  String get titleKey => 'name';

  Map<String, dynamic> getMapForFunction(SupplierProvider contacts, int index) {
    return contacts.mapData[index];
  }

  Widget buildListView(SupplierProvider providerData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount: getLength(providerData),
          itemBuilder: (ctx, index) {
            return LayoutBuilder(
              builder: (ctx, constraint) {
                return Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (ctx) {
                          return _ViewPage(
                              map: getMapForFunction(providerData, index),
                              title:
                                  providerData.mapData[index][titleKey] ?? '');
                        }));
                      },
                      child: Row(
                        children: [
                          _item(constraint.maxWidth * 0.2, 'Contact ID:',
                              'contact_id', providerData.mapData[index]),
                          _item(
                              constraint.maxWidth * 0.2,
                              'Business Name:',
                              'supplier_business_name',
                              providerData.mapData[index]),
                          _item(constraint.maxWidth * 0.2, 'Full Name:', 'name',
                              providerData.mapData[index]),
                          _item(constraint.maxWidth * 0.2, 'Email:', 'email',
                              providerData.mapData[index]),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          addEdit(index);
                        },
                        icon: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.black45,
                          ),
                        )),
                  ],
                );
              },
            );
          }),
    );
  }

  Widget _item(width, title1, key1, map, {prefix1}) {
    return SizedBox(
        width: width,
        child: Text(
          prefix1 != null
              ? '$prefix1 ${getValue(map, key1)}'
              : '' + (getValue(map, key1)),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ));
  }

  _title(String v, double size) {
    return SizedBox(
      width: size,
      child: Text(v),
    );
  }
}

class _ViewPage extends StatelessWidget {
  final Map<String, dynamic> map;

  final String title;

  const _ViewPage({Key? key, required this.map, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _item(context, 'Contact ID:', 'contact_id'),
              _item(context, 'Business Name:', 'supplier_business_name'),
              _item(context, 'Full Name:', 'name'),
              _item(context, 'Contact Status:', 'contact_status'),
              _item(context, 'Email:', 'email'),
              _item(context, 'Mobile number:', 'mobile'),
              _item(context, 'Address line1:', 'address_line_1'),
              _item(context, 'Address line2:', 'address_line_2'),
              _item(context, 'Pay Term:', 'pay_term_number'),
              _item(context, 'Tax No.:', 'tax_number'),
              _item(context, 'Balance:', 'balance', prefix1: 'Ksh'),
              _item(context, 'Added On:', 'created_at'),
              _item(context, 'Updated At.:', 'updated_at'),
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }

  Widget _item(BuildContext context, title1, key1, {prefix1}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title1,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              prefix1 != null
                  ? '$prefix1 ${getValue(map, key1)}'
                  : '' + (getValue(map, key1)),
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }
}

String getValue(Map<String, dynamic> map, String key) {
  if (map.containsKey(key) &&
      map[key] != null &&
      map[key].toString().isNotEmpty) {
    return map[key].toString().trim().isEmpty ? '0.0' : map[key].toString();
  }
  return 'unavailable';
}
