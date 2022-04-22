import 'package:flutter/material.dart';
import 'package:pos_app/data_management/pos_web_links.dart';
import 'package:pos_app/screens/webview.dart';

class PosSearch extends StatelessWidget {
  final VoidCallback scan;
  final VoidCallback search;

  const PosSearch({Key? key, required this.scan, required this.search})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration:const  BoxDecoration(
              border: Border(
                  right: BorderSide(
                      width: 0.5,
                      color: Colors.grey,
                      style: BorderStyle.solid))),
          child:  IconButton(
              onPressed: scan,
              icon: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).primaryColor,
              )),
        ),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            TextButton(
              onPressed: search,
              child:const Text('Search product by name or sku,scan barcode',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w300),),
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
                  Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const MyWebView(addProduct)));
                },
                icon: const Icon(Icons.add,color: Colors.blue,),
              ),
            )
          ],),
        )

      ],
    );
  }
}
