import 'dart:core';

import 'package:flutter/material.dart';
import 'package:group_call/src/call_sample_new/screens/call_sample_v2.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomeApp()
    );
  }
}


class MyHomeApp extends StatefulWidget {
  const MyHomeApp({Key? key}) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}


class _MyHomeState extends State<MyHomeApp> {

  final TextEditingController _inputHost = TextEditingController(text: "demo.cloudwebrtc.com");

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter-WebRTC example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _inputHost,
              decoration: InputDecoration(
                label: Text("Host"),
              ),
            ),

            ElevatedButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CallSampleV2(host: _inputHost.text))
                  );
                },
                child: Text('Join call')
            )
          ],
        ),
      ),
    );
  }
}
