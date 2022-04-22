import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/provider/customer_provider.dart';
import 'package:pos_app/provider/supplier_provider.dart';
import 'package:pos_app/widgets/border_row.dart';
import 'package:pos_app/widgets/custom_card.dart';
import 'package:pos_app/widgets/input_widgets.dart';
import 'package:provider/provider.dart';

class AddContact extends StatefulWidget {
  static const routeName = '/add-contacts-customer-supplier';

  const AddContact({Key? key}) : super(key: key);

  @override
  State<AddContact> createState() => _AddContactState();
}

enum ContactType { supplier, customer }
enum bisType { individual, business }

class _AddContactState extends State<AddContact> {
  final FocusNode _focusAltMob = FocusNode();
  final FocusNode _focusLandLine = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusMob = FocusNode();
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
    // const DropdownMenuItem(
    //   child: Text("Both (Supplier & Customer)"),
    //   value: ContactType.both,
    // ),
  ];
  final List<DropdownMenuItem<String>> _customerGroups = [
    const DropdownMenuItem(
      child: Text("None"),
      value: 'none',
    ),
    const DropdownMenuItem(
      child: Text("CONSIGNEE"),
      value: 'CONSIGNEE',
    ),
  ];

  int contactId = -1;
  ContactType contactType = ContactType.supplier;
  bisType type = bisType.individual;
  String customerGroupName = 'none';

  String get getDate {
    if (initData['dob'] == null) {
      initData['dob'] = DateFormat('y-M-d').format(DateTime.now());
    }
    return initData['dob'];
  }

  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final appBar = AppBar(
      title: Text(
        contactId < 0 ? "Add new Contact" : "Edit Contact",
      ),
      actions: [
        _uploading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ElevatedButton(
                onPressed: () async {
                  if (form.currentState == null) {
                    return;
                  }
                  form.currentState!.save();
                  if (form.currentState!.validate()) {
                    setState(() {
                      _uploading = true;
                    });
                    try {
                      await upload();
                    } catch (e) {
                      //
                    }
                    setState(() {
                      _uploading = false;
                    });
                  }
                },
                child: const Text("Save"))
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height:
            MediaQuery.of(context).size.height - appBar.preferredSize.height,
        child: _uploading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: form,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        _headers(),
                        const SizedBox(
                          height: 10.0,
                        ),
                        if ((contactType == ContactType.supplier &&
                            type == bisType.business))
                          BorderRow(
                            child: TextFormField(
                              textInputAction: TextInputAction.done,
                              initialValue: initData['supplier_business_name'],
                              keyboardType: TextInputType.text,
                              onFieldSubmitted: (v) {
                                //FocusScope.of(context)
                                //  .requestFocus(_focusPrefix);
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
                                initData['supplier_business_name'] = v!;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Enter business name',
                                border: InputBorder.none,
                              ),
                            ),
                            icon: const Icon(Icons.shopping_bag_sharp),
                          ),
                        if (contactType == ContactType.customer)
                          _contactGrpWidgets(),
                        const SizedBox(
                          height: 10.0,
                        ),
                        MyCustomCard([
                          if ((contactType == ContactType.supplier &&
                              type == bisType.business))
                            Column(
                              children: [
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Prefix'),
                                  ),
                                ),
                                BorderRow(
                                  child: TextFormField(
                                    initialValue: initData['prefix'],
                                    focusNode: _focusPrefix,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.text,
                                    onFieldSubmitted: (v) {
                                      //FocusScope.of(context)
                                      //  .requestFocus(_focusFirstN);
                                    },
                                    validator: (v) {
                                      return null;
                                    },
                                    onSaved: (v) {
                                      initData['prefix'] = v!;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Prefix',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Column(
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('First Name'),
                                ),
                              ),
                              BorderRow(
                                child: TextFormField(
                                  initialValue: initData['first_name'],
                                  textInputAction: TextInputAction.done,
                                  focusNode: _focusFirstN,
                                  keyboardType: TextInputType.name,
                                  onFieldSubmitted: (v) {
                                    //FocusScope.of(context)
                                    //  .requestFocus(_focusMiddleN);
                                  },
                                  validator: (v) {
                                    // if (type == bisType.individual) {
                                    //   return null;
                                    // }
                                    if (v == null) {
                                      return "This field is required";
                                    }
                                    if (v.isEmpty) {
                                      return "This field is required";
                                    }
                                    return null;
                                  },
                                  onSaved: (v) {
                                    initData['first_name'] = v!;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Enter first name',
                                    border: InputBorder.none,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          if ((contactType == ContactType.supplier &&
                              type == bisType.business))
                            Column(
                              children: [
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Middle Name'),
                                  ),
                                ),
                                BorderRow(
                                  child: TextFormField(
                                    initialValue: initData['middle_name'],
                                    focusNode: _focusMiddleN,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.name,
                                    onFieldSubmitted: (v) {
                                      //FocusScope.of(context)
                                      //  .requestFocus(_focusLastN);
                                    },
                                    onSaved: (v) {
                                      // if (type == bisType.individual) {
                                      //   return;
                                      // }
                                      initData['middle_name'] = v!;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Enter middle name',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Column(
                                  children: [
                                    const Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Last Name'),
                                      ),
                                    ),
                                    BorderRow(
                                      child: TextFormField(
                                        initialValue: initData['last_name'],
                                        focusNode: _focusLastN,
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.name,
                                        onFieldSubmitted: (v) {
                                          //FocusScope.of(context)
                                          //  .requestFocus(_focusMob);
                                        },
                                        onSaved: (v) {
                                          // if (type == bisType.individual) {
                                          //   return;
                                          // }
                                          initData['last_name'] = v!;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Enter last name',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                )
                              ],
                            ),
                        ]),
                        MyCustomCard([
                          Column(
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Mobile'),
                                ),
                              ),
                              BorderRow(
                                child: TextFormField(
                                  focusNode: _focusMob,
                                  initialValue: initData['mobile'],
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.phone,
                                  onFieldSubmitted: (v) {
                                    //FocusScope.of(context)
                                    //  .requestFocus(_focusAltMob);
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
                                  onSaved: (v) {
                                    // if (type == bisType.business) {
                                    //   return;
                                    // }
                                    initData['mobile'] = v!;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Enter mobile number',
                                    border: InputBorder.none,
                                  ),
                                ),
                                icon: const Icon(Icons.call),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Column(
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Alternate Mobile'),
                                ),
                              ),
                              BorderRow(
                                child: TextFormField(
                                  initialValue: initData['alternate_number'],
                                  focusNode: _focusAltMob,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.phone,
                                  onFieldSubmitted: (v) {
                                    //FocusScope.of(context)
                                    //  .requestFocus(_focusLandLine);
                                  },
                                  validator: (v) {
                                    return null;
                                  },
                                  onSaved: (v) {
                                    // if (type == bisType.business) {
                                    //   return;
                                    // }
                                    initData['alternate_number'] = v!;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Enter alternate mobile number',
                                    border: InputBorder.none,
                                  ),
                                ),
                                icon: const Icon(Icons.call),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Column(
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Landline'),
                                ),
                              ),
                              BorderRow(
                                child: TextFormField(
                                  initialValue: initData['landline'],
                                  focusNode: _focusLandLine,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.phone,
                                  onFieldSubmitted: (v) {
                                    //FocusScope.of(context)
                                    //  .requestFocus(_focusEmail);
                                  },
                                  validator: (v) {
                                    return null;
                                  },
                                  onSaved: (v) {
                                    // if (type == bisType.individual) {
                                    //   return;
                                    // }
                                    initData['landline'] = v!;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Enter landline',
                                    border: InputBorder.none,
                                  ),
                                ),
                                icon: const Icon(Icons.call),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Column(
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Email'),
                                ),
                              ),
                              BorderRow(
                                child: TextFormField(
                                  initialValue: initData['email'],
                                  textInputAction: TextInputAction.done,
                                  focusNode: _focusEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  onFieldSubmitted: (v) {
                                    //FocusScope.of(context)
                                    //  .requestFocus(_focusCity);
                                  },
                                  validator: (v) {
                                    return null;
                                  },
                                  onSaved: (v) {
                                    // if (type == bisType.individual) {
                                    //   return;
                                    // }
                                    initData['email'] = v!;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Enter email',
                                    border: InputBorder.none,
                                  ),
                                ),
                                icon: const Icon(Icons.email),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          if (type ==
                              (contactId < 0
                                  ? bisType.business
                                  : bisType.individual))
                            BorderRow(
                              child: TextButton(
                                  onPressed: () {
                                    _selectDate();
                                  },
                                  child: Text(getDate)),
                              icon: const Icon(Icons.calendar_today),
                            ),
                        ]),
                        ElevatedButton(
                            onPressed: () {
                              _showMoreInfo = !_showMoreInfo;
                              setState(() {});
                            },
                            child: const Text('More information')),
                        _moreIWidgets()
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  bool _showMoreInfo = false;

  final FocusNode _focusCity = FocusNode();
  final FocusNode _focusState = FocusNode();
  final FocusNode _focusCountry = FocusNode();
  final FocusNode _focusAddressLine2 = FocusNode();
  final FocusNode _focusAddressLine1 = FocusNode();
  final FocusNode _focusZipCode = FocusNode();
  final FocusNode _focusShippingAddress = FocusNode();
  final FocusNode _focusTax = FocusNode();
  final FocusNode _focusBalance = FocusNode();
  final FocusNode _focusPayTerm = FocusNode();
  final FocusNode _focusCreditLimit = FocusNode();

  void _selectDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now());
    if (date != null) {
      initData['dob'] = DateFormat("y-M-d").format(date);
      setState(() {});
    }
  }

  upload() async {
    Map<String, dynamic> initData = {};
    initData.addAll(this.initData);

    initData['name'] = (initData['prefix'] ?? '') +
        ' ' +
        (initData['first_name'] ?? '') +
        ' ' +
        (initData['middle_name'] ?? '') +
        ' ' +
        (initData['last_name'] ?? '');
    initData['type'] = getContactType();
    if (contactType == ContactType.customer) {
      final provider = Provider.of<CustomerProvider>(context, listen: false);

      if (contactId >= 0) {
        initData['id'] = contactId;
        await provider.update(initData);
      } else {
        await provider.addDataData(initData);
      }
    } else {
      final provider = Provider.of<SupplierProvider>(context, listen: false);
      if (contactId >= 0) {
        await provider.update(initData);
      } else {
        await provider.addDataData(initData);
      }
    }

    return 'go';
  }

  getContactType() {
    switch (contactType) {
      case ContactType.supplier:
        return "supplier";
      case ContactType.customer:
        return "customer";
    }
  }

  var _isInit = true;
  Map<String, dynamic> initData = {};

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      List<dynamic>? list =
          ModalRoute.of(context)!.settings.arguments as List<dynamic>?;
      if (list != null) {
        contactType = list.first;
        var index = list.last;
        if (index >= 0) {
          final provider1 =
              Provider.of<CustomerProvider>(context, listen: false);
          final provider2 =
              Provider.of<SupplierProvider>(context, listen: false);
          var contact = contactType == ContactType.customer
              ? provider1.mapData[index]
              : provider2.mapData[index];
          var id = contact['id'];

          contactId = (id ?? -1);

          initData.addAll(contact);
        }
      }
    }
    super.didChangeDependencies();
  }

  Widget _contactGrpWidgets() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Customer Group:'),
          ),
        ),
        BorderRow(
          child: DropdownButton(
              value: customerGroupName,
              hint: const Text('name'),
              onChanged: (v) {
                customerGroupName = v! as String;
                setState(() {});
              },
              items: _customerGroups),
          icon: const Icon(Icons.supervised_user_circle_sharp),
        ),
      ],
    );
  }

  Widget _headers() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Contact type:'),
          ),
        ),
        BorderRow(
            icon: const Icon(Icons.person_sharp),
            child: DropdownButton(
                value: contactType,
                hint: const Text('Contact Type'),
                onChanged: (v) {
                  contactType = v! as ContactType;
                  setState(() {});
                },
                items: types)),
        const Divider(),
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
      ],
    );
  }

  _moreIWidgets() {
    if (!_showMoreInfo) {
      return const SizedBox();
    }
    return Column(
      children: [
        MyCustomCard([
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('City'),
                ),
              ),
              BorderRow(
                child: MyTextFormInput(
                    context,
                    initData['city'],
                    TextInputAction.done,
                    _focusCity,
                    TextInputType.text,
                    _focusState,
                    (v) => initData['city'] = v,
                    'Enter city'),
                icon: const Icon(Icons.add_location),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Country'),
                ),
              ),
              BorderRow(
                child: MyTextFormInput(
                    context,
                    initData['country'],
                    TextInputAction.done,
                    _focusCountry,
                    TextInputType.text,
                    _focusZipCode,
                    (v) => initData['country'] = v,
                    'Enter country'),
                icon: const Icon(Icons.add_location),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Country'),
                ),
              ),
              BorderRow(
                child: MyTextFormInput(
                    context,
                    initData['zip_code'],
                    TextInputAction.done,
                    _focusZipCode,
                    TextInputType.number,
                    _focusAddressLine1,
                    (v) => initData['zip_code'] = v,
                    'Enter Zip code'),
                icon: const Icon(Icons.add_location),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Address line 1'),
                ),
              ),
              BorderRow(
                child: MyTextFormInput(
                    context,
                    initData['address_line_1'],
                    TextInputAction.done,
                    _focusAddressLine1,
                    TextInputType.text,
                    _focusAddressLine2,
                    (v) => initData['address_line_1'] = v,
                    'Enter Address line 1'),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Address line 2'),
                ),
              ),
              BorderRow(
                child: MyTextFormInput(
                    context,
                    initData['address_line_2'],
                    TextInputAction.done,
                    _focusAddressLine2,
                    TextInputType.text,
                    _focusShippingAddress,
                    (v) => initData['address_line_2'] = v,
                    'Enter Address line 2'),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Shipping Address'),
                ),
              ),
              BorderRow(
                child: MyTextFormInput(
                    context,
                    initData['shipping_address'],
                    TextInputAction.done,
                    _focusShippingAddress,
                    TextInputType.text,
                    null,
                    (v) => initData['shipping_address'] = v,
                    'Enter shipping address'),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
        ]),
        MyCustomCard([
          BorderRow(
            child: TextFormField(
              initialValue: initData['tax_number'],
              textInputAction: TextInputAction.done,
              focusNode: _focusTax,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (v) {
//                FocusScope.of(context)
                //                 .requestFocus(_focusBalance);
              },
              validator: (v) {
                return null;
              },
              onSaved: (v) {
                initData['tax_number'] = v;
              },
              decoration: const InputDecoration(
                labelText: 'Tax No.',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          BorderRow(
            child: TextFormField(
              initialValue: initData['balance'],
              textInputAction: TextInputAction.done,
              focusNode: _focusBalance,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (v) {
//                FocusScope.of(context)
                //                 .requestFocus(_focusPayTerm);
              },
              validator: (v) {
                return null;
              },
              onSaved: (v) {
                initData['balance'] = v;
              },
              decoration: const InputDecoration(
                labelText: 'Enter Opening Balance',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          BorderRow(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: initData['_focusPayTerm'],
                    textInputAction: TextInputAction.done,
                    focusNode: _focusPayTerm,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (v) {
                      //FocusScope.of(context)
                      //  .requestFocus(_focusCreditLimit);
                    },
                    validator: (v) {
                      return null;
                    },
                    onSaved: (v) {
                      initData['pay_term_number'] = v;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Pay term',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                DropdownButton(
                    value: initData['pay_term_type'],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          initData['pay_term_type'] = v;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        child: Text('Days'),
                        value: 'days',
                      ),
                      DropdownMenuItem(
                        child: Text('Months'),
                        value: 'months',
                      ),
                      DropdownMenuItem(
                        child: Text('Years'),
                        value: 'years',
                      )
                    ])
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          BorderRow(
            child: TextFormField(
              initialValue: initData['credit_limit'],
              textInputAction: TextInputAction.done,
              focusNode: _focusCreditLimit,
              keyboardType: TextInputType.number,
              onFieldSubmitted: (v) {
//FocusScope.of(context).requestFocus(_focusPayTerm);
              },
              validator: (v) {
                return null;
              },
              onSaved: (v) {
                initData['credit_limit'] = v;
              },
              decoration: const InputDecoration(
                labelText: 'Enter Credit limit',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
        ])
      ],
    );
  }
}
