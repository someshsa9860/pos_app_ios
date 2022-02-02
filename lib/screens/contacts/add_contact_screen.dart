import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/provider/contact_provider.dart';
import 'package:provider/provider.dart';

class AddContact extends StatefulWidget {
  static const routeName = '/add-contacts-customer-supplier';

  @override
  State<AddContact> createState() => _AddContactState();
}

enum ContactType { supplier, customer, both }
enum bisType { individual, business }

class _AddContactState extends State<AddContact> {
  final FocusNode _focusAltMob = FocusNode();
  final FocusNode _focusLandLine = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusMob = FocusNode();
  final FocusNode _focusDate = FocusNode();
  final FocusNode _focusPrefix = FocusNode();
  final FocusNode _focusFirstN = FocusNode();
  final FocusNode _focusMiddleN = FocusNode();
  final FocusNode _focusLastN = FocusNode();

  final form = GlobalKey<FormState>();

  List<DropdownMenuItem<ContactType>> types = [
    const DropdownMenuItem(
      child: Text("Supplier"),
      value: ContactType.supplier,
    ),
    const DropdownMenuItem(
      child: Text("Customer"),
      value: ContactType.customer,
    ),
    const DropdownMenuItem(
      child: Text("Both (Supplier & Customer)"),
      value: ContactType.both,
    ),
  ];

  String mobileNumber = "",
      altMobileNumber = "",
      prefix = "",
      businessName = "",
      fName = "",
      middleName = "",
      lastName = "",
      email = "",
      landline = "",
      dob = "";
  int contactId = -1;
  ContactType contactType = ContactType.supplier;
  bisType type = bisType.individual;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final appBar = AppBar(
      title: Text(contactId >= 0 ? "Add new Contact" : "Edit Contact"),
    );

    return Scaffold(
      appBar: appBar,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height:
            MediaQuery.of(context).size.height - appBar.preferredSize.height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Contact type:'),
                      DropdownButton(
                          icon: const Icon(Icons.contact_support),
                          value: contactType,
                          hint: const Text('Contact Type'),
                          onChanged: (v) {
                            contactType = v! as ContactType;
                          },
                          items: types),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Individual'),
                      Radio(
                          value: bisType.individual,
                          groupValue: type,
                          onChanged: (v) {
                            setState(() {
                              type = v! as bisType;
                            });
                          }),
                      const Spacer(),
                      const Text('Business'),
                      Radio(
                          value: bisType.business,
                          groupValue: type,
                          onChanged: (v) {
                            setState(() {
                              type = v! as bisType;
                            });
                          }),
                    ],
                  ),
                  type == bisType.business ? _getBisWidget() : Container(),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    focusNode: _focusMob,
                    initialValue: initData['mobile'],
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusAltMob);
                    },
                    validator: (v) {
                      if (v == null) {
                        return "This field is required";
                      }

                      if (v.isEmpty) {
                        return "This field is required";
                      }
                      return null;
                    },
                    onSaved: (v) => mobileNumber = v!,
                    decoration: const InputDecoration(
                      labelText: 'Enter mobile number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    focusNode: _focusAltMob,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusLandLine);
                    },
                    validator: (v) {
                      return null;
                    },
                    onSaved: (v) => altMobileNumber = v!,
                    decoration: const InputDecoration(
                      labelText: 'Enter alternate mobile number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    focusNode: _focusLandLine,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    onFieldSubmitted: (v) {
                      FocusScope.of(context).requestFocus(_focusEmail);
                    },
                    validator: (v) {
                      return null;
                    },
                    onSaved: (v) => landline = v!,
                    decoration: const InputDecoration(
                      labelText: 'Enter landline',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    focusNode: _focusEmail,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (v) {
                      //FocusScope.of(context).requestFocus(_focusLandLine);
                    },
                    validator: (v) {
                      return null;
                    },
                    onSaved: (v) => email = v!,
                    decoration: const InputDecoration(
                      labelText: 'Enter email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (form.currentState == null) {
                          return;
                        }
                        form.currentState!.save();
                        if (form.currentState!.validate()) {
                          upload(null);
                        }
                      },
                      child: Text(contactId >= 0
                          ? "Update Contact"
                          : "Add new Contact"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBisWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          textInputAction: TextInputAction.next,
          initialValue: initData['supplier_business_name'],
          keyboardType: TextInputType.text,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(_focusPrefix);
          },
          validator: (v) {
            if (type == bisType.individual) {
              return null;
            }
            if (v == null) {
              return "This field is required";
            }
            if (v.isEmpty) {
              return "This field is required";
            }
            return null;
          },
          onSaved: (v) {
            businessName = v!;
          },
          decoration: const InputDecoration(
            labelText: 'Enter business name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        TextFormField(
          initialValue: initData['prefix'],
          focusNode: _focusPrefix,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(_focusFirstN);
          },
          validator: (v) {
            return null;
          },
          onSaved: (v) {
            prefix = v!;
          },
          decoration: const InputDecoration(
            labelText: 'Prefix',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        TextFormField(
          initialValue: initData['first_name'],
          textInputAction: TextInputAction.next,
          focusNode: _focusFirstN,
          keyboardType: TextInputType.name,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(_focusMiddleN);
          },
          validator: (v) {
            if (type == bisType.individual) {
              return null;
            }
            if (v == null) {
              return "This field is required";
            }
            if (v.isEmpty) {
              return "This field is required";
            }
            return null;
          },
          onSaved: (v) => fName = v!,
          decoration: const InputDecoration(
            labelText: 'Enter first name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        TextFormField(
          initialValue: initData['middle_name'],
          focusNode: _focusMiddleN,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(_focusLastN);
          },
          onSaved: (v) => middleName = v!,
          decoration: const InputDecoration(
            labelText: 'Enter middle name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        TextFormField(
          initialValue: initData['last_name'],
          focusNode: _focusLastN,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(_focusMob);
          },
          onSaved: (v) => lastName = v!,
          decoration: const InputDecoration(
            labelText: 'Enter last name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () {
                  _selectDate();
                },
                child: const Text('Select DOB')),
            Text(dob)
          ],
        )
      ],
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now());
    if (date != null) {
      dob = DateFormat("yyyy/MM/dd").format(date);
      setState(() {});
    }
  }

  bool uploading = false;

  void upload(id) async {
    setState(() {
      uploading = true;
    });

    final data = {
      'type': getContactType(),
      'supplier_business_name': businessName,
      //'name': null,
      'prefix': prefix,
      'first_name': fName,
      'middle_name': middleName,
      'last_name': lastName,
      'email': email,
      'contact_id': id,
      //'contact_status': null,
      //'tax_number': null,
      //'city': null,
      //'state': null,
      //'country': null,
      //'address_line_1': null,
      //'address_line_2': null,
      //'zip_code': null,
      'dob': dob,
      'mobile': mobileNumber,
      'landline': landline,
      'alternate_number': altMobileNumber,
      //'pay_term_number': null,
      //'pay_term_type': null,
      //'credit_limit': null,
      //'created_by': null,
      //'balance': null,
      //'total_rp': null,
      //'total_rp_used': null,
      //'total_rp_expired': null,
      //'is_default': null,
      //'shipping_address': null,
      //'shipping_custom_field_details': null,
      //'is_export': null,
      //'export_custom_field_1': null,
      //'export_custom_field_2': null,
      //'export_custom_field_3': null,
      //'export_custom_field_4': null,
      //'export_custom_field_5': null,
      //'export_custom_field_6': null,
      //'position': null,
      //'customer_group_id': null,
      'custom_field1': null
    };
    final provider = Provider.of<ContactsProvider>(context, listen: false);
    final response = await provider.addContact(data);
    print(json.decode(response.body));

    setState(() {
      uploading = false;
    });
  }

  getContactType() {
    switch (contactType) {
      case ContactType.both:
        return "both";
      case ContactType.supplier:
        return "supplier";
      case ContactType.customer:
        return "customer";
    }
  }

  var _isInit = true;
  var initData={};
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      List<dynamic> list =
          ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      contactType = list.first;
      var index = list.last;
      if(contactId>=0){
        final provider=Provider.of<ContactsProvider>(context,listen: false);
        var contact=contactType==ContactType.supplier?provider.mapSupplyer[index]:provider.mapCustomer[index];
        contactId=contact['contact_id'];
        dob=contact['dob'];
        initData = {
          'type': getContactType(),
          'supplier_business_name': contact['supplier_business_name'],
          //'name': null,
          'prefix': contact['prefix'],
          'first_name': contact['first_name'],
          'middle_name': contact['middle_name'],
          'last_name': contact['last_name'],
          'email': contact['email'],
          'contact_id': contact['contact_id'],
          //'contact_status': null,
          //'tax_number': null,
          //'city': null,
          //'state': null,
          //'country': null,
          //'address_line_1': null,
          //'address_line_2': null,
          //'zip_code': null,
          'dob': contact['dob'],
          'mobile': contact['mobile'],
          'landline': contact['landline'],
          'alternate_number': contact['alternate_number'],
          //'pay_term_number': null,
          //'pay_term_type': null,
          //'credit_limit': null,
          //'created_by': null,
          //'balance': null,
          //'total_rp': null,
          //'total_rp_used': null,
          //'total_rp_expired': null,
          //'is_default': null,
          //'shipping_address': null,
          //'shipping_custom_field_details': null,
          //'is_export': null,
          //'export_custom_field_1': null,
          //'export_custom_field_2': null,
          //'export_custom_field_3': null,
          //'export_custom_field_4': null,
          //'export_custom_field_5': null,
          //'export_custom_field_6': null,
          //'position': null,
          //'customer_group_id': null,
          //'custom_field1': null
        };
        //initData.removeWhere((key, value) => value==null);
      }
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
