import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:march/support/PhoneAuthCode.dart';
import 'package:http/http.dart' as http;
import 'package:march/ui/registration.dart';
import 'package:march/ui/select.dart';
import 'dart:convert' as convert;

import 'home.dart';

class PhoneAuthVerify extends StatefulWidget {
  final Color cardBackgroundColor = Color(0xFFFCA967);
  final String appName = "Flowance app";

  @override
  _PhoneAuthVerifyState createState() => _PhoneAuthVerifyState();
}

class _PhoneAuthVerifyState extends State<PhoneAuthVerify> {
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();
  String code = "";

  @override
  void initState() {
    FirebasePhoneAuth.phoneAuthState.stream.listen((PhoneAuthState state) async {
      print("Hello There $state");
      if (state == PhoneAuthState.Verified) {
        FirebaseAuth.instance.currentUser().then((val) async {
          print(val.uid);
          var url = 'https://march.lbits.co/app/api/goals.php?uid=' + val.uid;
          var response = await http.get(url);
          var jsonResponse = convert.jsonDecode(response.body);
          if (jsonResponse.length!=0) {

            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) => Home()),
                  (Route<dynamic> route) => false,);

          } else {


            var url = 'https://march.lbits.co/app/api/index.php?uid=' + val.uid;
            var response = await http.get(url);
            if (response.statusCode == 200) {

              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => Register(val.phoneNumber)),
                    (Route<dynamic> route) => false,);

            } else {

              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => Select()),
                    (Route<dynamic> route) => false,);

              print('Request failed with status: ${response.statusCode}.');

            }

            print('Request failed with status: ${response.statusCode}.');

          }

        });


        //   FirebaseAuth.instance.currentUser().then((value) async {
      //   var reg = await http
      //       .get("https://march.lbits.co/app/api/index.php?uid=${value.uid}");
      //   if (reg.body == "null") {
      //     print("This is user data ${reg.body}");
      //     Navigator.pushAndRemoveUntil(
      //         context,
      //         MaterialPageRoute(builder: (context) => Register()),
      //         (route) => false);
      //   } else {
      //     var goals = await http
      //         .get("https://march.lbits.co/app/api/goals.php?uid=${value.uid}");
      //     print("This is goals ${goals.body}");
      //     if (goals.body == "[]") {
      //       Navigator.pushAndRemoveUntil(
      //           context,
      //           MaterialPageRoute(builder: (context) => Select()),
      //           (route) => false);
      //     } else {
      //       Navigator.pushAndRemoveUntil(
      //           context,
      //           MaterialPageRoute(builder: (context) => Home()),
      //           (route) => false);
      //     }
      //   }
      // });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: AppBar(
              title: Text(
                "Verification Code",
                style: TextStyle(color: Colors.black),
              ),
              leading: RaisedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios, size: 12.0),
                label: Text(""),
                color: Colors.white,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(50.0),
                ),
              ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0.0,
            ),
          )),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: _getBody(),
          ),
        ),
      ),
    );
  }

  Widget _getBody() => Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: <Widget>[
            Text(widget.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700)),
            //  Info text
            Row(
              children: <Widget>[
                SizedBox(width: 22.0),
                Expanded(
                    child: Text(
                  "SMS with code has been sent to mobile.",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
                  textAlign: TextAlign.center,
                )),
                SizedBox(width: 16.0),
              ],
            ),

            SizedBox(height: 46.0),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                getPinField(key: "1", focusNode: focusNode1),
                SizedBox(width: 5.0),
                getPinField(key: "2", focusNode: focusNode2),
                SizedBox(width: 5.0),
                getPinField(key: "3", focusNode: focusNode3),
                SizedBox(width: 5.0),
                SizedBox(width: 5.0),
                getPinField(key: "4", focusNode: focusNode4),
                SizedBox(width: 5.0),
                getPinField(key: "5", focusNode: focusNode5),
                SizedBox(width: 5.0),
                getPinField(key: "6", focusNode: focusNode6),
                SizedBox(width: 5.0),
              ],
            ),
            SizedBox(height: 10.0),
            Center(
                child: Row(
              children: <Widget>[
                SizedBox(width: 150.0),
                Text("0:01 "),
                Text("Resend"),
              ],
            )),
            SizedBox(height: 32.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FlatButton(
                  onPressed: signIn,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'VERIFY',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.all(12),
                ),
              ],
            ),
            SizedBox(height: 275.0)
          ],
        ),
      );

  signIn() {
    if (code.length != 6) {
      //  TODO: show error
    }
    FirebasePhoneAuth.signInWithPhoneNumber(smsCode: code);
  }

  Widget getPinField({String key, FocusNode focusNode}) => SizedBox(
        height: 40.0,
        width: 35.0,
        child: TextField(
          key: Key(key),
          expands: false,
          autofocus: key.contains("1") ? true : false,
          focusNode: focusNode,
          onChanged: (String value) {
            if (value.length == 1) {
              code += value;
              switch (code.length) {
                case 1:
                  FocusScope.of(context).requestFocus(focusNode2);
                  break;
                case 2:
                  FocusScope.of(context).requestFocus(focusNode3);
                  break;
                case 3:
                  FocusScope.of(context).requestFocus(focusNode4);
                  break;
                case 4:
                  FocusScope.of(context).requestFocus(focusNode5);
                  break;
                case 5:
                  FocusScope.of(context).requestFocus(focusNode6);
                  break;
                default:
                  FocusScope.of(context).requestFocus(FocusNode());
                  break;
              }
            }
          },
          maxLengthEnforced: false,
          textAlign: TextAlign.center,
          cursorColor: Colors.black,
          keyboardType: TextInputType.number,
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      );
}