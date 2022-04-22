import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCustomProgressBar extends StatelessWidget {
  final String msg;
  final bool progressBar;

  const MyCustomProgressBar(
      {Key? key, this.msg = 'empty', this.progressBar = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child:
            //progressBar
              //  ?
            CircularProgressIndicator()
               // : const Icon(Icons.hourglass_empty_sharp),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Fetching data...',
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          )
        ],
      ),
    );
  }
}
