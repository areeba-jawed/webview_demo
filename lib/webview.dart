import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebviewScreen extends StatefulWidget {
  final String url;

  const WebviewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  WebViewController? webViewController;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadWebView();
    addFileSelectionListener();
  }

  loadWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log('Page started loading: $url');
          },
          onProgress: (int progress) {
            log('WebView is loading (progress : $progress%)');
          },
          onPageFinished: (String url) {
            log('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            log('Webview resource error ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains("http:/")) {
              log("first redirection ${request.url}");
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Synergates'),
            centerTitle: true,
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: WebViewWidget(
                    controller: webViewController!,
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void addFileSelectionListener() async {
    if (Platform.isAndroid) {
      log('pick');
      final androidController =
          webViewController?.platform as AndroidWebViewController;
      await androidController.setOnShowFileSelector(_androidFilePicker);
    }
  }

  Future<List<String>> _androidFilePicker(
      final FileSelectorParams params) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      return [file.uri.toString()];
    }
    return [];
  }
}
