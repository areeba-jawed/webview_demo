import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_demo/webview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = DevHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Webview Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final key = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();

  bool isURL(String potentialUrl) {
    if (Uri.tryParse(potentialUrl)?.hasScheme ?? false) {
      return true; // It's an absolute URL with a scheme (e.g., http:// or https://)
    }
    // else if (Uri.tryParse('http://$potentialUrl') != null ||
    //     Uri.tryParse('https://$potentialUrl') != null) {
    //   return true; // It's a valid URL without a scheme; add http:// or https:// as needed
    // }
    else {
      return false; // Not a valid URL
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synergates'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type here... ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill this field';
                    } else if (!isURL(value)) {
                      return 'Please enter a valid url';
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  WebviewScreen(url: controller.text)),
                        );
                      }
                    },
                    child: const Text('Continue')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
