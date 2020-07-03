import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:march/ui/MessagesScreen.dart';
import 'package:march/ui/find_screen.dart';
import 'package:march/ui/profile.dart';
import 'package:march/ui/settings.dart';
import 'package:march/utils/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

Future myBackgroundMessageHandler(Map<String, dynamic> message) async {
  DataBaseHelper db = DataBaseHelper();
  if (message['data']['type'] == 'message') {
    db.addMessage(<String, String>{
      DataBaseHelper.messageOtherId: message['data']['sender'],
      DataBaseHelper.messageSentBy: message['data']['sender'],
      DataBaseHelper.messageText: message['data']['message'],
      DataBaseHelper.messageContainsImage: '0',
      DataBaseHelper.messageImage: 'null',
      DataBaseHelper.messageTime: message['data']['time'],
    });
    db.updateLastMessage(<String, String>{
      DataBaseHelper.friendLastMessage: message['data']['message'],
      DataBaseHelper.friendLastMessageTime: message['data']['time'],
      DataBaseHelper.friendId: message['data']['sender']
    });
  }
}

class Home extends StatefulWidget {
  final pageName;
  Home(this.pageName);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentindex = 0;
  String title = "Find People";
  List<String> t = ["Find People", "Inbox", "Profile"];
  SocketIO socketIO;
  static String token, uid;
  static String myId;
  String chatsPage;
  final db = DataBaseHelper();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  var iosSubscription;
  List tabs;

  messageChecker() async {
    print("getting messages");
    http.post('https://march.lbits.co/api/worker.php',
        body: json.encode(
            {'serviceName': '', 'work': 'get messages', 'receiver': '$myId'}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }).then((value) {
      var resp = json.decode(value.body);
      if (resp['response'] == 200) {
        var myNewMessages = resp['result'];
        if (myNewMessages.length > 0) {
          myNewMessages.forEach((val) {
            db.checkMessage(val['msgCode']).then((value) {
              if (value[0]['msgCount'] == 0) {
                Map newMessage = <String, String>{
                  DataBaseHelper.messageCode: val['msgCode'],
                  DataBaseHelper.messageOtherId: val['sender_id'],
                  DataBaseHelper.messageSentBy: val['sender_id'],
                  DataBaseHelper.messageText: val['msgText'],
                  DataBaseHelper.messageContainsImage: val['containsImage'],
                  DataBaseHelper.messageImage: val['imageUrl'],
                  DataBaseHelper.messageTransportStatus: 'success',
                  DataBaseHelper.messageTime: val['messageTime']
                };
                Map updateLastMessage = <String, String>{
                  'message': val['msgText'],
                  'messageTime': val['messageTime'],
                  'otherId': val['sender_id']
                };
                db.addMessage(newMessage);
                db.updateLastMessage(updateLastMessage);
              }
            });
          });
        }
      }
    });
  }

  @override
  void initState() {
    tabs = [
      FindScreen(),
      MessagesScreen('$chatsPage'),
      Profile(),
    ];
    _load();

    super.initState();
    socketIO = SocketIOManager().createSocketIO(
        'https://glacial-waters-33471.herokuapp.com', '/',
        socketStatusCallback: _socketStatus);
    socketIO.init();
    socketIO.subscribe('receive message', (jsonData) {
      var data = json.decode(jsonData);
      if (data['receiver'].toString() == myId) {
        // loadMessages();
        // print('$data');
        Map newMessage = <String, String>{
          DataBaseHelper.messageCode: data['msgCode'],
          DataBaseHelper.messageOtherId: data['sender'],
          DataBaseHelper.messageSentBy: data['sender'],
          DataBaseHelper.messageText: data['message'],
          DataBaseHelper.messageContainsImage: data['containsImage'],
          DataBaseHelper.messageImage: '${data['imageUrl']}',
          DataBaseHelper.messageTransportStatus: "success",
          DataBaseHelper.messageTime: '${data['time']}'
        };
        Map updateLastMessage = <String, String>{
          'message': data['message'],
          'messageTime': data['time'],
          'otherId': data['sender']
        };
        db.addMessage(newMessage);
        db.updateLastMessage(updateLastMessage);
      }
    });
    getUserToken().then((value) {
      print("Token: $value");
    });
    _fcm.configure(
        onBackgroundMessage: myBackgroundMessageHandler,
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(message['notification']['title']),
                subtitle: Text(
                    message['notification']['body'] + "${message['data']}"),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(message['notification']['title']),
                subtitle: Text(
                    message['notification']['body'] + "${message['data']}"),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
        });
  }

  void checkforIosPermission() async {
    await _fcm.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  _socketStatus(data) {
    print("Socket Status: $data");
  }

  Future<String> getUserToken() async {
    var tkn;
    if (Platform.isIOS) checkforIosPermission();
    await _fcm.getToken().then((value) {
      tkn = value;
      if (token != null && uid != null) {
        http.post('https://march.lbits.co/api/worker.php',
            body: json.encode({
              'serviceName': '',
              'work': 'save token',
              'uid': uid,
              'token': tkn
            }),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            }).then((value) {
          var val = json.decode(value.body);
          print("$val");
        });
      }
    });
    return tkn;
  }

  Future<Map> updateStatus() async {
    var prefs = await SharedPreferences.getInstance();
    Map myMap = {
      'uid': prefs.getString('id'),
      'time': DateTime.now().toString()
    };
    return myMap;
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _currentindex == 2
          ? Theme.of(context).primaryColor
          : Color(0xFFFFFFFF),
      title: _currentindex == 2
          ? Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Center(
                  child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'montserrat'),
              )),
            )
          : Center(
              child: Text(
              title,
              style: TextStyle(
                  color: Colors.black, fontSize: 18, fontFamily: 'montserrat'),
            )),
      actions: <Widget>[
        //if added change it to 3
        _currentindex == 2
            ? IconButton(
                icon: Icon(
                  Icons.tune,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settings()),
                  );
                },
              )
            : Container(),
      ],
    );
  }

  Widget bottomNavBar() {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 20,
        elevation: 0,
        backgroundColor: Color(0xFFFFFFFF),
        currentIndex: _currentindex,
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(
                Ionicons.ios_people,
                size: 30,
              ),
              title: Text("Find People")),
          //   new BottomNavigationBarItem(icon: new Icon(Icons.date_range,size: 30,),title: Text("")),
          new BottomNavigationBarItem(
              icon: new Icon(
                FontAwesome.send,
                size: 22,
              ),
              title: Text("Chats")),
          new BottomNavigationBarItem(
              icon: new Icon(
                Icons.person,
                size: 30,
              ),
              title: Text("Profile")),
        ],
        unselectedItemColor: Theme.of(context).disabledColor,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          setState(() {
            _currentindex = index;
            title = t[_currentindex];
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(minutes: 1), (timer) {
      messageChecker();
    });

    return Scaffold(
     // appBar: appBar(),
      body: Center(
        child: tabs[_currentindex],
      ),
      bottomNavigationBar: bottomNavBar(),
    );
  }

  void _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    myId = prefs.getString('id');
    uid = prefs.getString('uid');
    prefs.setInt('log', 1);
    if (uid == null) {
      FirebaseAuth.instance.currentUser().then((val) async {
        String uid = val.uid;
        prefs.setString('uid', uid);
      });
    }
    messageChecker();
    socketIO.sendMessage('update my status',
        json.encode({"uid": "$myId", "time": "${DateTime.now()}"}));
  }
}
