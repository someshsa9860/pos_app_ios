import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/data_management/pos_database.dart';
import 'package:pos_app/data_management/pos_web_links.dart';
import 'package:pos_app/data_management/sync.dart';
import 'package:pos_app/provider/customer_provider.dart';
import 'package:pos_app/provider/expense_provider.dart';
import 'package:pos_app/provider/location_provider.dart';
import 'package:pos_app/provider/paccounts_provider.dart';
import 'package:pos_app/provider/pmethods_provider.dart';
import 'package:pos_app/provider/supplier_provider.dart';
import 'package:pos_app/provider/tax_provider.dart';
import 'package:pos_app/provider/user_provider.dart';
import 'package:pos_app/screens/contacts/add_contact_screen.dart';
import 'package:pos_app/widgets/app_drawer.dart';
import 'package:pos_app/widgets/border_row.dart';
import 'package:pos_app/widgets/custom_card.dart';
import 'package:provider/provider.dart';

enum ExpenseType { expense, categories }

class ExpensesAddScreen extends StatefulWidget {
  const ExpensesAddScreen({Key? key}) : super(key: key);
  static const routeName = '/expenses-add-screen';

  @override
  State<StatefulWidget> createState() {
    return _Screen();
  }
}

class _Screen extends State<ExpensesAddScreen> {
  final FocusNode _focusTotalAmount = FocusNode();
  final FocusNode _focusExpenseNotes = FocusNode();

  final FocusNode _focusAmount = FocusNode();
  final FocusNode _focusPaymentNote = FocusNode();

  final form = GlobalKey<FormState>();
  var id;

  // List<Map<String, dynamic>> mapLocations = [];
  // List<dynamic> mapContacts = [];

  List<DropdownMenuItem<int>> users(UsersProvider mapUsers) {
    return mapUsers.mapData
        .map((e) => DropdownMenuItem(
              child: Text(e['username']),
              value: e['id'] as int,
            ))
        .toSet()
        .toList();
  }

  bool _required(List<String> keys, List<String> messages) {
    bool valid = true;
    int id = 0;
    for (int i = 0; i < keys.length; i++) {
      if (initData[keys[i]] == null) {
        id = i;
        valid = false;
      }
    }
    if (!valid) {
      Fluttertoast.showToast(msg: messages[id]);
    }
    return valid;
  }

  List<DropdownMenuItem<String>> categories = [
    const DropdownMenuItem(
      child: Text('LOGISTICS'),
      value: 'LOGISTICS',
    ),
  ];

  List<DropdownMenuItem<int>> getLocationsList(LocationProvider provider) {
    return getMapLocations(provider)
        .map((v) {
          return DropdownMenuItem(
            child: Text(v['name']),
            value: v['id'] as int,
          );
        })
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> getMapLocations(LocationProvider provider) =>
      [...provider.mapData];

  List<DropdownMenuItem<int>> contactsList(
      SupplierProvider supplierProvider, CustomerProvider customerProvider) {
    return getMapContacts(supplierProvider, customerProvider)
        .map((v) {
          return DropdownMenuItem(
            child: Text(v['name']),
            value: v['id'] as int,
          );
        })
        .toSet()
        .toList();
  }


  List<Map<String, dynamic>> getMapContacts(
      SupplierProvider supplierProvider, CustomerProvider customerProvider) {
    var mlist = [];
    mlist.addAll(supplierProvider.mapData);

    mlist.addAll(customerProvider.mapData);
    mlist.removeWhere((element) => element['id'] == null);
    return [...mlist.toSet().toList()];
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(id == null ? "Add new Expense" : "Edit Expense"),
      actions: [
        ElevatedButton(
            onPressed: () async {
              if (form.currentState == null) {
                return;
              }
              form.currentState!.save();
              if (form.currentState!.validate()) {
                if (_required([
                  'location_id',
                  'final_total'
                ], [
                  'Select Location',
                  'Enter total expense',
                  'add at least one product'
                ])) {
                  bool allow = false;
                  await showDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text('Confirm'),
                          content: const Text('Are you sure to add expense'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  allow = false;
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('no')),
                            ElevatedButton(
                                onPressed: () {
                                  allow = true;
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('yes')),
                          ],
                        );
                      });
                  if (allow) {
                    uploading = true;
                    await upload();
                    Future.delayed(Duration(milliseconds: 500))
                        .whenComplete(() {
                      cancel();
                      setState(() {
                        uploading = false;
                        initData = {};
                      });
                    });
                  }
                }
              }
            },
            child: const Text('Save'))
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        bool pop = false;
        {
          await showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext ctx) {
                return AlertDialog(
                  title: const Text('Cancel Transaction'),
                  content: const Text(
                      'Are you sure to cancel this transaction and exit?'),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          pop = false;
                        },
                        child: const Text('no')),
                    ElevatedButton(
                        onPressed: () {
                          cancel();

                          Navigator.of(ctx).pop();
                          pop = true;
                        },
                        child: const Text('yes')),
                  ],
                );
              });
        }

        return pop;
      },
      child: Scaffold(
        appBar: appBar,
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height:
              MediaQuery.of(context).size.height - appBar.preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:uploading?const Center(child: CircularProgressIndicator(),): SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  children: [
                    MyCustomCard([
                      Column(
                        children: [
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Business Location:'),
                            ),
                          ),
                          BorderRow(child: Consumer<LocationProvider>(
                            builder: (ctx, provider, _) {
                              return DropdownButton(
                                  //icon: const Icon(Icons.contact_support),
                                  value: int.tryParse(
                                      initData['location_id'].toString()),
                                  underline: null,
                                  hint: const Text(
                                    'Business Location',
                                    textAlign: TextAlign.end,
                                  ),
                                  onChanged: (v) {
                                    initData['location_id'] =
                                        int.tryParse('$v');
                                    setState(() {});
                                  },
                                  items: getLocationsList(provider));
                            },
                          ))
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
                              child: Text('Expense For:'),
                            ),
                          ),
                          BorderRow(child: Consumer<UsersProvider>(
                              builder: (ctx, providerData, _) {
                            return Autocomplete<Map<String, dynamic>>(
                              displayStringForOption: (map) =>
                                  '${map['surname']} ${map['first_name']} ${map['last_name']} ',
                              onSelected: (map) {
                                setState(() {
                                  initData['expense_for'] = map['id'];
                                });
                              },
                              optionsBuilder: (v) {
                                if (v.text == '') {
                                  return [];
                                }
                                return providerData.mapData.where((element) =>
                                    element['first_name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(v.text.toLowerCase()));
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onSubmitted) {
                                // if (controller.text.isEmpty) {
                                //   controller
                                //       .text = providerData.mapData.firstWhere(
                                //           (element) =>
                                //               element['id'].toString() ==
                                //               initData['expense_for'].toString(),
                                //           orElse: () => {})['first_name'] ??
                                //       '';
                                // }
                                return TextFormField(
                                  focusNode: focusNode,
                                  controller: controller,
                                  decoration: const InputDecoration(
                                      hintText:
                                          'Start entering first name of user',
                                      border: InputBorder.none),
                                  onFieldSubmitted: (v) => onSubmitted,
                                );
                              },
                            );
                          }))
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
                              child: Text('Expense for contact:'),
                            ),
                          ),
                          BorderRow(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Consumer<CustomerProvider>(
                                    builder: (ctx, customers, _) {
                                      return Consumer<SupplierProvider>(
                                        builder: (ctx, supplier, _) {
                                          var list = getMapContacts(
                                              supplier, customers);

                                          list = list.toSet().toList();

                                          return Autocomplete<
                                              Map<String, dynamic>>(
                                            displayStringForOption: (map) =>
                                                map['name'],
                                            onSelected: (map) {
                                              setState(() {
                                                initData['contact_id'] =
                                                    map['id'];
                                              });
                                            },
                                            optionsBuilder: (v) {
                                              if (v.text == '') {
                                                return [];
                                              }
                                              return list.where((element) =>
                                                  element['name']
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(v.text
                                                          .toLowerCase()));
                                            },
                                            fieldViewBuilder: (context,
                                                controller,
                                                focusNode,
                                                onSubmitted) {
                                              // if (controller.text.isEmpty) {
                                              //   controller.text =
                                              //       customers.mapData.firstWhere(
                                              //               (element) =>
                                              //                   element['id']
                                              //                       .toString() ==
                                              //                   initData[
                                              //                           'contact_id']
                                              //                       .toString(),
                                              //               orElse: () =>
                                              //                   {})['name'] ??
                                              //           '';
                                              // }
                                              return TextFormField(
                                                focusNode: focusNode,
                                                controller: controller,
                                                decoration: const InputDecoration(
                                                    hintText:
                                                        'Expense for contact',
                                                    border: InputBorder.none),
                                                onFieldSubmitted: (v) =>
                                                    onSubmitted,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      border: Border.symmetric(
                                          vertical: BorderSide(
                                              width: 0.4,
                                              color: Colors.grey,
                                              style: BorderStyle.solid))),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AddContact.routeName);
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            icon: const Icon(
                              Icons.person_rounded,
                              color: Colors.grey,
                            ),
                          ),
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
                              child: Text('Expense Category'),
                            ),
                          ),
                          BorderRow(
                              child: DropdownButton(
                                  //icon: const Icon(Icons.contact_support),
                                  value: initData['category_id'],
                                  hint: const Text(
                                    'Expense Category',
                                    textAlign: TextAlign.end,
                                  ),
                                  onChanged: (v) {
                                    initData['category_id'] = v! as String;
                                    setState(() {});
                                  },
                                  items: categories))
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
                              child: Text('Applicable tax'),
                            ),
                          ),
                          BorderRow(child: Consumer<TaxProvider>(
                            builder: (ctx, taxP, _) {
                              final list = taxP.mapData
                                  .toSet()
                                  .toList()
                                  .map((e) => DropdownMenuItem(
                                      value: e['id'], child: Text(e['name'])))
                                  .toSet()
                                  .toList();
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: DropdownButton(
                                    value: initData['tax_rate_id'],
                                    hint: const Text(
                                      'Applicable tax',
                                      textAlign: TextAlign.end,
                                    ),
                                    onChanged: (v) {
                                      initData['tax_rate_id'] = v!;
                                      setState(() {});
                                    },
                                    items: list),
                              );
                            },
                          )),
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
                              child: Text('Transaction Date'),
                            ),
                          ),
                          BorderRow(
                              child: TextButton(
                                  onPressed: () {
                                    _selectDate();
                                  },
                                  child: Text(initData['transaction_date'] ??
                                      DateFormat("y-M-d HH:mm")
                                          .format(DateTime.now()))))
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
                              child: Text('Total amount'),
                            ),
                          ),
                          BorderRow(
                            child: TextFormField(
                              focusNode: _focusTotalAmount,
                              textInputAction: TextInputAction.done,
                              initialValue: initData['final_total'] ?? '',
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (v) {
//                              FocusScope.of(context)
                                //                                .requestFocus(_focusExpenseNotes);
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'This is required field';
                                }
                                return null;
                              },
                              onSaved: (v) {
                                initData['final_total'] = v;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Total amount',
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
                              child: Text('Expense Notes'),
                            ),
                          ),
                          BorderRow(
                            child: TextFormField(
                              focusNode: _focusExpenseNotes,
                              textInputAction: TextInputAction.done,
                              initialValue: initData['additional_notes'] ?? '',
                              keyboardType: TextInputType.multiline,
                              // onFieldSubmitted: (v) {
                              //   FocusScope.of(context)
                              //       .requestFocus(_focusTotalAmount);
                              // },
                              maxLines: null,
                              validator: (v) {
                                return null;
                              },
                              onSaved: (v) {
                                initData['additional_notes'] = v;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Expense Notes',
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                              value:
                                  initData['is_refund'] == '1' ? true : false,
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    initData['is_refund'] = '${v ? 1 : 0}';
                                  });
                                }
                              }),
                          const Text('Is refund?'),
                        ],
                      ),
                    ]),
                    const Divider(),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Divider(),
                    if ((initData['is_refund']) == '1')
                      MyCustomCard([
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Is recurring?'),
                            Checkbox(
                                value: initData['is_recurring'] == '1'
                                    ? true
                                    : false,
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      initData['is_recurring'] = '${v ? 1 : 0}';
                                    });
                                  }
                                }),
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
                                child: Text('Recurring interval'),
                              ),
                            ),
                            BorderRow(
                              child: TextFormField(
                                textInputAction: TextInputAction.done,
                                initialValue: initData['recur_interval'] ?? '',
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  return null;
                                },
                                onSaved: (v) {
                                  initData['recur_interval'] = v;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Recurring interval',
                                  border: InputBorder.none,
                                ),
                              ),
                              icon: DropdownButton(
                                  value: initData['recur_interval_type'],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() {
                                        initData['recur_interval_type'] = v;
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
                                  ]),
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
                                child: Text('No. of repetition'),
                              ),
                            ),
                            BorderRow(
                              child: TextFormField(
                                textInputAction: TextInputAction.done,
                                initialValue:
                                    initData['recur_repetitions'] ?? '',
                                keyboardType: TextInputType.number,
                                // onFieldSubmitted: (v) {
                                //   FocusScope.of(context)
                                //       .requestFocus(_focusTotalAmount);
                                // },
                                validator: (v) {
                                  return null;
                                },
                                onSaved: (v) {
                                  initData['recur_repetitions'] = v;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'No. of repetition',
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                          ],
                        ),
                      ]),
                    MyCustomCard([
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Payment'),
                                ),
                              ),
                              BorderRow(
                                child: Consumer<PaymentMethodsProvider>(
                                  builder: (ctx, provider, _) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: DropdownButton(
                                          hint: const Text('Payment Methods'),
                                          value: method,
                                          onChanged: (v) {
                                            method = v;
                                            setState(() {});
                                          },
                                          items: methodList(provider)),
                                    );
                                  },
                                ),
                                icon: const Icon(Icons.info),
                              ),
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
                                  child: Text('Enter amount'),
                                ),
                              ),
                              BorderRow(
                                child: TextFormField(
                                  focusNode: _focusAmount,
                                  textInputAction: TextInputAction.done,
                                  initialValue: amount ?? '',
                                  keyboardType: TextInputType.number,
                                  onFieldSubmitted: (v) {
                                    //                              FocusScope.of(context)
                                    //                                .requestFocus(_focusPaymentNote);
                                  },
                                  validator: (v) {
                                    return null;
                                  },
                                  onSaved: (v) {
                                    amount = v;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Enter amount',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
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
                                  child: Text('Payment Account'),
                                ),
                              ),
                              BorderRow(
                                child: Consumer<PaymentAccountProvider>(
                                  builder: (ctx, accounts, _) {
                                    return DropdownButton(
                                        //icon: const Icon(Icons.contact_support),
                                        value: account,
                                        underline: null,
                                        hint: const Text(
                                          'Payment Accounts',
                                          textAlign: TextAlign.end,
                                        ),
                                        onChanged: (v) {
                                          account = v;
                                          setState(() {});
                                        },
                                        items: accountsList(accounts));
                                  },
                                ),
                                icon: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.grey,
                                ),
                              ),
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
                                  child: Text('Enter Payment Notes'),
                                ),
                              ),
                              BorderRow(
                                child: TextFormField(
                                  focusNode: _focusPaymentNote,
                                  textInputAction: TextInputAction.done,
                                  initialValue: note,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  validator: (v) {
                                    return null;
                                  },
                                  onSaved: (v) {
                                    note = v;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Payment Notes',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ],
                      )
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
        drawer: const AppDrawer(),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now());
    if (date != null) {
      final sdate = DateFormat("y-M-d").format(date);
      final time = await showTimePicker(
        context: context,
        builder: (ctx, child) {
          return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!);
        },
        initialTime: TimeOfDay.now(),
      );
      var stime = (TimeOfDay.now().hour.toString() +
              ':' +
              TimeOfDay.now().minute.toString() +
              ':' +
              '0')
          .toString();
      if (time != null) {
        stime =
            (time.hour.toString() + ':' + time.minute.toString() + ':' + '0')
                .toString();
      }
      initData['transaction_date'] = sdate + " " + stime;
      setState(() {});
    }
  }

  bool uploading = false;

  upload() async {
    setState(() {
      uploading = true;
    });

    var provider = Provider.of<ExpenseProvider>(context, listen: false);
    Map<String, dynamic> initData = {};
    initData.addAll(this.initData);

    initData['id'] = id;
    if (initData['ref_no'] == null) {
      initData['ref_no'] = getRefNo();
    }
    initData.removeWhere((key, value) => value == null);
    initData['payment'] = [
      {
        'amount': amount,
        'method': method,
        'account_id': account,
      }
    ];
    if (id != null && id >= 0) {
      await provider.update(initData);
    } else {
      await provider.addDataData(initData);
    }
    return 'go';
  }

  var amount, method, account, note;

  List<DropdownMenuItem<String>> methodList(PaymentMethodsProvider provider) {
    List<DropdownMenuItem<String>> list = [];
    getMapMethods(provider).forEach((key, valu) {
      if (valu != null && list.length < 5) {
        var value = valu.toString();
        if (!list.contains(DropdownMenuItem(
          child: Text(value),
          value: key,
        ))) {
          list.add(DropdownMenuItem(
            child: Text(value),
            value: key,
          ));
        }
      }
    });
    return list;
  }

  Map<String, dynamic> getMapMethods(PaymentMethodsProvider provider) {
    return provider.mapData;
  }

  List<DropdownMenuItem<int>> accountsList(PaymentAccountProvider provider) {
    return getMapAccounts(provider)
        .map((v) {
          return DropdownMenuItem(
            child: Text(v['name']),
            value: v['id'] as int,
          );
        })
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> getMapAccounts(PaymentAccountProvider provider) {
    return [...provider.mapData.toSet().toList()];
  }

  var _isInit = true;
  Map<String, dynamic> initData = {};

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;

      List<dynamic> list =
          ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      id = null;
      if (list.first >= 0) {
        final provider = Provider.of<ExpenseProvider>(context, listen: false);

        final expense = provider.mapData[list.first];
        id = expense['id'];

        initData.addAll(expense);

        try {
          initData['expense_for'] = initData['expense_for']?['id'];
        } catch (e) {
          initData['expense_for'] = null;
        }
        initData['contact_id'] = initData['created_by'];
      }
    }
    super.didChangeDependencies();
  }

  getList(List<dynamic> list) {
    return list;
  }

  void cancel() {
    initData.clear();
    amount = '';
    method = null;
    account = null;
    note = '';
  }
  Future<String> setDefaults(Map<String, dynamic> initData) async {



    UniqueDatabase database = UniqueDatabase(tableName: expenseDefaultValuesTable);
    await database.addData({'data': jsonEncode({
      'contact_id':initData['contact_id'] ,
      'expense_for':initData['expense_for'] ,
      'category_id':initData['category_id'] ,
      'tax_rate_id':initData['tax_rate_id'] ,
      'location_id':initData['location_id'] ,
      'method':initData['method'],
      'selling_price_group_id':initData['selling_price_group_id']

    })});
    return '';
  }

  Future<Map<String, dynamic>> getDefaults() async{
    Map<String, dynamic> m = {

    };
    UniqueDatabase database = UniqueDatabase(tableName: expenseDefaultValuesTable);
    final list = await database.getData();
    if (list.isEmpty) {
      return m;
    }
    return jsonDecode(list.last['data']);
  }

  getData() async{
    initData.addAll(await getDefaults());
    setState(() {

    });
  }
}
