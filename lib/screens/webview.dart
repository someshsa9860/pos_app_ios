import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  final String url;

  const MyWebView(this.url, {Key? key}) : super(key: key);

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (Platform.isAndroid) {
      WebView.platform = AndroidWebView();
    }
    double? v = 0;
    bool finished = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Web'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_controller != null) {
            await _controller!.reload();
          }
        },
        child: WebView(
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onProgress: (p) {


          },
          onPageFinished: (x) {


          },
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.url,
        ),
      ),
    );
  }
}
