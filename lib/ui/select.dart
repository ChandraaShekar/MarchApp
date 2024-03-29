import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:march/models/goal.dart';
import 'package:march/ui/home.dart';
import 'package:http/http.dart' as http;
import 'package:march/utils/database_helper.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Select extends StatefulWidget {
  @override
  _SelectState createState() => _SelectState();
}

class _SelectState extends State<Select> with SingleTickerProviderStateMixin {
  List<String> added = ["", "", ""];
  String currentText = "";
  String currentText1 = "";
  int click = 0;
  Future<PermissionStatus> permissionStatus;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> key1 = new GlobalKey();
  int count = 0;
  String remind = "0";
  Color c = Colors.grey[100];
  final GlobalKey<ScaffoldState> _sk = GlobalKey<ScaffoldState>();
  List<String> suggestions = [];
// drop down
  var db = new DataBaseHelper();
  String note = "";
  String goalsLevel = "";
// till here
  String sendTime = "none";
  int cnt = 1;
  String uid;
  String token;
  bool checkedValue = false;
  bool timeView = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Color activeColor = Color(0xffFFBF46);
  AnimationController animationController;
  Animation d1, p1, d2, p2, d3, p3, d4, p4, d5;
  TextEditingController nameController;
  TextEditingController numberController;
  TextEditingController dateController;
  TextEditingController cvvController;
  TimeOfDay time;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    });
    _load();
    super.initState();
    time=TimeOfDay.now();
    nameController = TextEditingController();
    numberController = TextEditingController();
    dateController = TextEditingController();
    cvvController = TextEditingController();

    animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    d1 = ColorTween(begin: Colors.white, end: activeColor).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.3, 0.5, curve: Curves.linear)));
    p1 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController, curve: Interval(0.5, 0.6)));
    d2 = ColorTween(begin: Colors.white, end: activeColor).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.6, 0.8, curve: Curves.linear)));
    p2 = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Interval(0.8, 1)));
    d3 = ColorTween(begin: Colors.white, end: activeColor).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.8, 1, curve: Curves.linear)));
    animationController.forward();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    print("Tapped on Notification");
  }

  final myController = TextEditingController();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  int _disable = 0;

  @override
  Widget build(BuildContext context) {
    final dotSize = 20.0;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _sk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Select Your Goals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 1.2,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                  child: Text(
                "Goal " + cnt.toString() + " of 3",
                style: Theme.of(context).textTheme.headline2,
              )),
              AnimatedBuilder(
                animation: animationController,
                builder: (BuildContext context, Widget child) => Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.all(12),
                          width: MediaQuery.of(context).size.width,
                          child: Row(children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 0.5, color: activeColor)),
                              width: dotSize + 13,
                              height: dotSize + 13,
                              child: Center(
                                child: Container(
                                    width: dotSize,
                                    height: dotSize,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(dotSize / 2),
                                        color: activeColor)),
                              ),
                            ),
                            Container(
                              child: Center(
                                child: Container(
                                  height: 3,
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  child: LinearProgressIndicator(
                                    backgroundColor: cnt >= 2
                                        ? activeColor
                                        : Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        cnt >= 2
                                            ? activeColor
                                            : Colors.transparent),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 0.5,
                                      color: cnt >= 2
                                          ? activeColor
                                          : Colors.grey)),
                              width: dotSize + 13,
                              height: dotSize + 13,
                              child: Center(
                                child: Container(
                                  width: dotSize,
                                  height: dotSize,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(dotSize / 2),
                                      color: cnt >= 2
                                          ? activeColor
                                          : Colors.grey[200]),
                                ),
                              ),
                            ),
                            Container(
                              child: Center(
                                child: Container(
                                  height: 3,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: LinearProgressIndicator(
                                    backgroundColor: cnt >= 3
                                        ? activeColor
                                        : Colors.grey[200],
                                    //  value: p1.value,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        cnt >= 3
                                            ? activeColor
                                            : Colors.transparent),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 0.5,
                                    color: cnt >= 3 ? activeColor : Colors.grey,
                                    // color: activeColor
                                  )),
                              width: dotSize + 13,
                              height: dotSize + 13,
                              child: Center(
                                child: Container(
                                  width: dotSize,
                                  height: dotSize,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(dotSize / 2),
                                      //    color: d3.value
                                      color: cnt >= 3
                                          ? activeColor
                                          : Colors.grey[300]),
                                ),
                              ),
                            ),
                          ])),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.only(left: 10, right: 22),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(count > 0 ? added[0] : "Goal 1",
                        style: Theme.of(context).textTheme.caption),
                    Text(count > 1 ? added[1] : "Goal 2",
                        style: Theme.of(context).textTheme.caption),
                    // SizedBox(width: MediaQuery.of(context).size.width * 0.25,),
                    Text(count > 2 ? added[2] : "Goal 3",
                        style: Theme.of(context).textTheme.caption),
                  ],
                ),
              ),
              _disable == 1
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20.0,20,20,10),
                      child: SimpleAutoCompleteTextField(
                        key: key,
                        decoration: new InputDecoration(
                            filled: true,
                            fillColor: c,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: c, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(15, 15, 15, 5),
                            hintText: "Enter Your Goals",
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            )),
                        controller: TextEditingController(),
                        suggestions: suggestions,
                        textChanged: (text) => currentText = text,
                        clearOnSubmit: true,
                        textSubmitted: (text) => setState(() {
                          if (text != "" && _disable == 0) {
                            if (count < 3) {
                              added[count] = text;
                              count = count + 1;
                              _disable = 1;
                            } else {
                              _sk.currentState.showSnackBar(SnackBar(
                                content: Text(
                                  "You can Select only 3",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12.0),
                                        topRight: Radius.circular(12.0))),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.lightBlueAccent,
                              ));
                            }
                          } else {
                            _sk.currentState.showSnackBar(SnackBar(
                              content: Text(
                                "Enter all details and Submit next",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.0),
                                      topRight: Radius.circular(12.0))),
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.lightBlueAccent,
                            ));
                          }
                        }),
                      ),
                    ),
              _disable == 1
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20,20,20,10),
                      child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Expanded(child: Text(added[count - 1])),
                                IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _disable = 0;
                                        added[count - 1] = "";
                                        count = count - 1;
                                      });
                                    }),
                              ],
                            ),
                          )),
                    )
                  : Container(),

              Padding(
                padding: const EdgeInsets.fromLTRB(12.0,0,12,8),
                child: Theme(
                  data: ThemeData(primaryColor: Colors.black),
                  child: Container(
                    // color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: goalsLevel==""?c:Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: goalsLevel==""?c:Colors.grey, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(15, 15, 15, 5),
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(5.0),
                              ),
                            ),
                          
                            ),
                        items: [
                          DropdownMenuItem<String>(
                                value: "0",
                                child: Text(
                                  "Newbie",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    fontSize: 16,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: "1",
                                child: Text(
                                  "Skilled",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: "2",
                                child: Text(
                                  "Proficient",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: "3",
                                child: Text(
                                  "Experienced",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: "4",
                                child: Text(
                                  "Expert",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            goalsLevel=value;
                          });
                        },
                        isExpanded: true,
                        hint: Text(
                          "Choose Your Expertise ",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            fontFamily: 'Nunito',
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              CheckboxListTile(
                title: Text(
                  "Remind me every day",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
                value: checkedValue,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (newValue) {
                   permissionStatus = NotificationPermissions.requestNotificationPermissions();
                     permissionStatus.then((PermissionStatus status) {
                        if(status==PermissionStatus.granted){
                            setState(() {
                               checkedValue = newValue;
                               sendTime='${time.hour}:${time.minute}:00';
                            });
                              _pickTime();
                            print('granted');
                         }
                        else{
                          setState(() {
                             sendTime='none';
                             print(sendTime);
                           });
                           print('rejected');
                        }
                       });

                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 5, right: 20),
                child: Divider(
                  thickness: 1,
                ),
              ),
              Center(
                child: Visibility(
                    maintainSize: false,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: checkedValue,
                    child: Container(
                        height: size.height / 10,
                        width: size.width / 1.14,
                        margin: EdgeInsets.only(top: 5, bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                                'Remind me Everyday at ${time.hour}:${time.minute} ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Divider(
                                thickness: 1,
                              ),
                            ),

                            /*Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top:12.0),
                                  child: Text("Write a Note (Optional)",style: Theme.of(context).textTheme.subtitle2,),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0.0,10.0,0.0,10),
                                  child: TextField(
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black
                                    ),
                                    decoration: InputDecoration(
                                        hintText: "its time to work on your goal",
                                        border: OutlineInputBorder(),
                                        hintStyle: TextStyle(color: Colors.black26, fontSize: 15.0)),
                                    onChanged: (String value) {
                                      try {
                                        note = value;
                                      } catch (exception) {
                                        note ="";
                                      }
                                    },
                                  ),
                                ),
                                Text("these will be text on your notification",style: Theme.of(context).textTheme.headline3,),
                              ],
                            ),
*/
                          ],
                        ))),
              ),
              cnt > 1
                  ? Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                                child: FlatButton(
                                    child: Text(
                                      'SKIP',
                                      style: Theme.of(context).textTheme.button,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: const EdgeInsets.all(15),
                                    color: Theme.of(context).primaryColor,
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setInt('log', 1);

                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Home('')),
                                          (Route<dynamic> route) => false);
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                                child: FlatButton(
                                  child: Text(
                                    'NEXT',
                                    style: Theme.of(context).textTheme.button,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  onPressed: () async {
                                      if (goalsLevel != "" &&
                                          added[count - 1] != "") {
                                        if (sendTime != "none") {
                                          setState(() {
                                            remind = "1";
                                          });
                                        }
                                        _onLoading();
                                        print('cnt :' +
                                            cnt.toString() +
                                            ' expertise :' +
                                            goalsLevel);

                                        print(remind + " " + sendTime);

                                        var url =
                                            'https://march.lbits.co/api/worker.php';
                                        var resp = await http.post(
                                          url,
                                          headers: {
                                            'Content-Type': 'application/json',
                                            'Authorization': 'Bearer $token'
                                          },
                                          body: json.encode(<String, dynamic>{
                                            'serviceName': "",
                                            'work': "add goal",
                                            'uid': uid,
                                            'goalName': added[count - 1],
                                            'goalNumber': count.toString(),
                                            'goalLevel': int.parse(goalsLevel),
                                            'remindEveryday': int.parse(remind),
                                            'remindTime': sendTime,
                                          }),
                                        );

                                        print(resp.body.toString());
                                        var result = json.decode(resp.body);
                                        if (count == 3 &&
                                            result['response'] == 200) {

                                          if(remind=="1"){
                                            _showNotification(count,added[count-1], "It's time to work on your goal",
                                                Time(time.hour,time.minute));
                                          }

                                          Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Home('')),
                                              (Route<dynamic> route) => false);

                                          int savedGoal = await db.saveGoal(
                                              new Goal(
                                                  uid,
                                                  added[count - 1],
                                                  goalsLevel,
                                                  remind,
                                                  sendTime,
                                                  count.toString()));

                                          print("goal saved :$savedGoal");

                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.setInt('log', 1);
                                        } else if (result['response'] == 200) {
                                          // check what to save
                                          if(remind=="1"){
                                            _showNotification(count,added[count-1], "It's time to work on your goal",
                                                Time(time.hour,time.minute));
                                          }

                                          int savedGoal = await db.saveGoal(
                                              new Goal(
                                                  uid,
                                                  added[count - 1],
                                                  goalsLevel,
                                                  remind,
                                                  sendTime,
                                                  count.toString()));

                                          print("goal saved :$savedGoal");

                                          Navigator.pop(context);
                                          setState(() {
                                            suggestions.remove(added[count - 1]);
                                            _disable = 0;
                                            sendTime = "none";
                                            remind = "0";
                                            note = "";
                                            timeView = false;
                                            checkedValue = false;
                                            click = 0;
                                            goalsLevel = "";
                                            cnt = cnt + 1;
                                          });
                                        } else {
                                          Navigator.pop(context);
                                          setState(() {
                                            checkedValue = false;
                                            timeView = false;
                                            sendTime = "none";
                                            remind = "0";
                                            note = "";
                                            click = 0;
                                            goalsLevel = "";
                                            _disable = 0;
                                            added[count - 1] = "";
                                            count = count - 1;
                                          });

                                          _sk.currentState
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                              "There is Some Technical Problem Submit again",
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 15,
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(12.0),
                                                    topRight:
                                                        Radius.circular(12.0))),
                                            duration: Duration(seconds: 3),
                                            backgroundColor:
                                                Colors.lightBlueAccent,
                                          ));
                                        }
                                      } else {
                                        _sk.currentState.showSnackBar(SnackBar(
                                          content: Text(
                                            "Enter all details and Submit next",
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 15,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(12.0),
                                                  topRight:
                                                      Radius.circular(12.0))),
                                          duration: Duration(seconds: 3),
                                          backgroundColor:
                                              Colors.lightBlueAccent,
                                        ));
                                      }
                                    }
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
                          child: FlatButton(
                            child: Text(
                              'NEXT',
                              style: Theme.of(context).textTheme.button,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.all(15),
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                                if (goalsLevel != "" && added[0] != "") {
                                  if (sendTime != "none") {
                                    setState(() {
                                      remind = "1";
                                    });
                                  }
                                  _onLoading();
                                  print('cnt :' +
                                      cnt.toString() +
                                      ' expertise :' +
                                      goalsLevel);

                                  print(remind + " " + sendTime);

                                  var url =
                                      'https://march.lbits.co/api/worker.php';
                                  var resp = await http.post(
                                    url,
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization': 'Bearer $token'
                                    },
                                    body: json.encode(<String, dynamic>{
                                      'serviceName': "",
                                      'work': "add goal",
                                      'uid': uid,
                                      'goalName': added[count - 1],
                                      'goalNumber': count.toString(),
                                      'goalLevel': int.parse(goalsLevel),
                                      'remindEveryday': int.parse(remind),
                                      'remindTime': sendTime,
                                      //                                'note':"",
                                    }),
                                  );

                                  print(resp.body.toString());
                                  var result = json.decode(resp.body);
                                  if (result['response'] == 200) {
                                    if(remind=="1"){
                                      _showNotification(count,added[count-1], "It's time to work on your goal",
                                          Time(time.hour,time.minute));
                                    }

                                    int savedGoal = await db.saveGoal(new Goal(
                                        uid,
                                        added[count - 1],
                                        goalsLevel,
                                        remind,
                                        sendTime,
                                        count.toString()));

                                    print("goal saved :$savedGoal");

                                    Navigator.pop(context);
                                    setState(() {
                                      suggestions.remove(added[count - 1]);
                                      _disable = 0;
                                      note = "";
                                      click = 0;
                                      timeView = false;
                                      checkedValue = false;
                                      sendTime = "none";
                                      remind = "0";
                                      goalsLevel = "";
                                      cnt = cnt + 1;
                                    });
                                  } else {
                                    Navigator.pop(context);
                                    setState(() {
                                      goalsLevel = "";
                                      note = "";
                                      click = 0;
                                      timeView = false;
                                      checkedValue = false;
                                      sendTime = "none";
                                      remind = "0";
                                      _disable = 0;
                                      added[count - 1] = "";
                                      count = count - 1;
                                    });

                                    _sk.currentState.showSnackBar(SnackBar(
                                      content: Text(
                                        "There is Some Technical Problem Submit again",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 15,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12.0),
                                              topRight: Radius.circular(12.0))),
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.lightBlueAccent,
                                    ));
                                  }
                                } else {
                                  _sk.currentState.showSnackBar(SnackBar(
                                    content: Text(
                                      "Enter all details and Submit next",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 15,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.0),
                                            topRight: Radius.circular(12.0))),
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.lightBlueAccent,
                                  ));
                                }
                              }
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showNotification(int goalNumber, String title, String content,
      Time notificationTime) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails('100',
        'Goal Reminder', 'This channel is reserved for the goal Reminders',
        playSound: false, importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      goalNumber,
      '$title',
      '$content',
      notificationTime,
      platformChannelSpecifics,
    );
  }

  _pickTime() async{
    TimeOfDay t = await showTimePicker(
      context: context,
      initialTime: time,
    );

    if(t!=null){
      setState(() {
        sendTime='${t.hour}:${t.minute}:00';
        print(sendTime);
        time=t;
      });
    }
  }


  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          child: Center(
            child: Image.asset(
              "assets/images/animat-rocket-color.gif",
              height: 125.0,
              width: 125.0,
            ),
          ),
        );
      },
    );
  }

  void _load() async {

    permissionStatus = NotificationPermissions.requestNotificationPermissions();

    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      token = pref.getString('token');
    });

    var url = 'https://march.lbits.co/api/worker.php';
    var resp = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(<String, dynamic>{
        'serviceName': "",
        'work': "get goals list",
      }),
    );

    print(resp.body.toString());
    var res = json.decode(resp.body);
    if (res['response'] == 200) {
      List n = res['result'];
      setState(() {
        for (var i = 0; i < n.length; i++) {
          suggestions.add(res['result'][i].toString());
        }
      });
    }
  }
}
