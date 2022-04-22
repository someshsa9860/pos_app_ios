import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncStatus { synced, pendingNew, pendingUpdate, syncing, error }

bool isNewPending(String? status) {
  if (status == null) {
    //data is already synced means data is not created from app
    return false;
  }
  return SyncStatus.pendingNew.toString().toLowerCase().contains(status);
}

bool isUpdatePending(String? status) {
  if (status == null) {
    //data is already synced means data is not created from app
    return false;
  }
  return SyncStatus.pendingUpdate.toString().toLowerCase().contains(status);
}

String getNewId(prefix) {
  final date = DateTime.now();

  return '$prefix${(date.day + date.month + date.year + date.hour + date.minute + date.second + date.microsecond + date.millisecond).toString()}';
}

String getRefNo() {
  final date = DateTime.now();
  return 'EP${date.year}/${(date.day + date.month + date.hour + date.minute + date.second + (date.microsecond) + date.millisecond).toString()}';
}

String getFileName() {
  final date = DateTime.now();

  return '${date.year}-${date.month}-${date.day}-${date.hour} ${date.minute} ${date.second} ${date.microsecond} '; // +  date.hour + date.minute + date.second + (date.microsecond) + date.millisecond).toString()}';
}

int getRandomId() {
  final date = DateTime.now();

  final x = (date.day +
      date.month +
      date.year +
      date.hour +
      date.minute +
      date.second +
      date.microsecond +
      date.millisecond);
  return x;
}

Future<String> getInvoiceNum() async{
    final format=NumberFormat('00000');
    final pref= await SharedPreferences.getInstance();
    int x=(pref.getInt('getInvoiceNum')??0)+1;
    final prefix=pref.getString('getInvoiceNumPrefix')??'';
    pref.setInt('getInvoiceNum', x);
  return 'POS$prefix${format.format(x)}';
}

String getContactId() {
  return 'CO${getRandomId()}';
}

class SyncWidget extends AnimatedWidget {
  //final SyncStatus syncStatus;

  const SyncWidget(
      {Key? key,
      //   required this.syncStatus,
      required Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    // TODO: implement build

    return Transform.rotate(
      angle: animation.value,
      child: const IconButton(
          onPressed: null,
          tooltip: 'syncing',
          icon: Icon(
            Icons.sync,
            color: Colors.white,
          )),
    );
  }
}
