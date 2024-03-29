import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:location/location.dart';
import 'package:march/support/functions.dart';
import 'package:march/ui/profileScreen.dart';
import 'package:march/utils/database_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:march/widgets/ProfileWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' show ImageFilter;
import 'package:status_alert/status_alert.dart';

class TestHomePage extends StatefulWidget {
  TestHomePage({Key key}) : super(key: key);

  @override
  _TestHomePageState createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  DataBaseHelper db = DataBaseHelper();
  List<Widget> stackedCards = [];
  List details = [];
  List crossCheckList = [];
  String token, uid, name = "";
  String id = "51";
  int check = 0;
  int clicked = 0;
  List goalList = [];
  String lat;
  String lng;
  String goals = "";
  Location location = new Location();
  int maxAge = 100;
  int minAge = 18;
  TextEditingController myController;
  int radius = 100;
  SocketIO socketIO;
  String level = "none";
  LocationData _locationData;
  PermissionStatus _permissionGranted;
  bool _serviceEnabled;
  List myUsers = [];
  bool loadPage = false;
  int pageNo = 0;
  int alen = 0;
  int nlen = 0;
  List allProfiles = [];
  List allProfilesCrossCheck = [];
  String defaultMsg = "";
  bool nearSendAgain = true, allSendAgain = true;
  List<bool> showButton = [];
  @override
  void initState() {
    _load();
    socketIO = SocketIOManager().createSocketIO(
      'https://glacial-waters-33471.herokuapp.com',
      '/',
    );
    socketIO.init();
    socketIO.connect();
    _getAllPeople();
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer t) {
      print("FIRED");
      setState(() {
        nearSendAgain = true;
        allSendAgain = true;
      });
    });
  }

  BoxDecoration selected() {
    return BoxDecoration(
        color: Theme.of(context).primaryColor,
        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
        borderRadius: (pageNo == 0)
            ? BorderRadius.only(
                topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
            : BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15)));
  }

  BoxDecoration unSelected() {
    return BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Theme.of(context).primaryColor),
        borderRadius: (pageNo == 1)
            ? BorderRadius.only(
                topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))
            : BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15)));
  }

  Future<List<Widget>> _getPeople() async {
    // if (token != null && id != null && check == 1) {
    _getAllPeople();

    if (nearSendAgain) {
      var ur = 'https://march.lbits.co/api/worker.php';
      Map nearbyReqs = <String, dynamic>{
        'serviceName': "",
        'work': "search with distance",
        'lat': '$lat',
        'lng': '$lng',
        'goals': "$goals",
        'radius': '$radius',
        'maxAge': '$maxAge',
        'minAge': '$minAge',
        'uid': id
      };
      var resp = await http.post(
        ur,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(nearbyReqs),
      );
      var result = json.decode(resp.body);
      print(result);
      stackedCards.clear();
      if (result['response'] == 200) {
        nearSendAgain = false;
        int l = result['result'].length;
        List requiredRes = result['result'].toList()..shuffle();
        for (var i = 0; i < l; i++) {
          db.getPersonWithId(requiredRes[i]['user_info']['id']).then((value) {
            if (value[0]['personCount'].toString() == '0') {
              db.insertPersonForPeopleFinder({
                DataBaseHelper.peopleFinderid: requiredRes[i]['user_info']
                    ['id'],
                DataBaseHelper.peopleFinderName: requiredRes[i]['user_info']
                    ['fullName'],
                DataBaseHelper.peopleFinderPic: requiredRes[i]['user_info']
                    ['profile_pic'],
                DataBaseHelper.peopleFinderProfession: requiredRes[i]
                    ['user_info']['profession'],
                DataBaseHelper.peopleFinderLocation:
                    "${requiredRes[i]['user_info']['distance']} Km away",
                DataBaseHelper.peopleFinderBio: requiredRes[i]['user_info']
                    ['bio'],
                DataBaseHelper.peopleFinderGender: requiredRes[i]['user_info']
                    ['sex'],
                DataBaseHelper.peopleFinderAge: requiredRes[i]['user_info']
                    ['age'],
              }).then((value) {
                requiredRes[i]['goal_info'].toList().forEach((element) {
                  db.addPersonGoal({
                    DataBaseHelper.peopleFinderPersonId: requiredRes[i]
                        ['user_info']['id'],
                    DataBaseHelper.peopleFinderGoalName:
                        element['personGoalName'],
                    DataBaseHelper.peopleFinderGoalLevel:
                        element['personGoalLevel']
                  }).then((value) => print("ADDED"));
                });
              });
            }
          });
        }
      }
    }

    return stackedCards;
  }

  _getAllPeople() async {
    if (allSendAgain) {
      var ur = 'https://march.lbits.co/api/worker.php';
      Map xxx = <String, dynamic>{
        'serviceName': "",
        'work': "get all profiles",
        'maxAge': '$maxAge',
        'minAge': '$minAge',
        'goals': "$goals",
        'uid': id,
      };
      http
          .post(
        ur,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(xxx),
      )
          .then((resp) {
        var jsonResp = json.decode(resp.body);
        // print(jsonResp);
        if (jsonResp['response'] == 200) {
          allSendAgain = false;
          print(jsonResp);
          List allprofs = jsonResp['result'].toList()..shuffle();
          if (allprofs.length == 0) {
            setState(() {
              alen = 1;
              //alen is 0 before checking , 1 if len is 0,
            });
          } else {
            setState(() {
              alen = 0;
            });
          }
          allprofs.forEach((element) {
            if (!allProfilesCrossCheck.contains(element['user_info']['id'])) {
              setState(() {
                allProfiles.add(element);
                allProfilesCrossCheck.add(element['user_info']['id']);
              });
              db.getSingleUser(element['user_info']['id']).then((value) {
                setState(() {
                  if (value[0]['user_count'].toString() != '0') {
                    showButton.add(false);
                  } else {
                    showButton.add(true);
                  }
                });
              });
            }
            db.getSingleUser(element['user_info']['id']).then((value) {
              setState(() {
                if (value[0]['user_count'].toString() != '0') {
                  showButton.add(false);
                } else {
                  showButton.add(true);
                }
              });
            });
          });
        }
      });
    }
  }

  Widget goalBox(goal, BuildContext context, int cnt) {
    Size size = MediaQuery.of(context).size;
    List<Map> colors = [
      {'bgColor': Color(0xFFCCEEED), 'textColor': Color(0xFF00ACA3)},
      {'bgColor': Color(0xFFF1D3B5), 'textColor': Color(0xFF926D51)},
      {'bgColor': Color(0xFFF2C5D3), 'textColor': Color(0xFF926D51)}
    ];
    List<Map> goalAssets = [
      {
        'name': 'Newbie',
        'image': 'assets/images/newbie.png',
        'bgColor': Color(0xFFCCEEED),
        'textColor': Color(0xFF00ACA3)
      },
      {
        'name': 'Skilled',
        'image': 'assets/images/skilled.png',
        'bgColor': Color(0xFFB1D1DF),
        'textColor': Color(0xFF4D6874)
      },
      {
        'name': 'Proficient',
        'image': 'assets/images/proficient.png',
        'bgColor': Color(0xFFE35E64),
        'textColor': Color(0xFF74272A)
      },
      {
        'name': 'Experienced',
        'image': 'assets/images/experienced.png',
        'bgColor': Color(0xFFF2C5D3),
        'textColor': Color(0xFF926D51)
      },
      {
        'name': 'Expert',
        'image': 'assets/images/expert.png',
        'bgColor': Color(0xFFF1D3B5),
        'textColor': Color(0xFF926D51)
      },
    ];
    return Container(
      decoration: BoxDecoration(
          color: colors[cnt]['bgColor'],
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Text(
          goal['personGoalName'],
          style: TextStyle(
              color: colors[cnt]['textColor'],
              fontSize: size.height / 60,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }

  Widget cardGenerator(tag, id, name, pic, profession, location, description,
      List goals, List testimonials, int index) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
        onVerticalDragUpdate: (x) {
          if (x.delta.dy <= -6) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                          name: name,
                          profession: profession,
                          userId: id,
                          pic: pic,
                          location: location,
                          bio: description,
                          goals: goals,
                          fromNetwork: false,
                        )));
          }
        },
        child: SizedBox(
          width: size.width * 0.95,
          height: (0.58 * size.height),
          child: Card(
            color: Colors.white,
            shadowColor: Colors.grey[50],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            // elevation: 5.0 * (index),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Hero(
                    flightShuttleBuilder: _flightShuttleBuilder,
                    tag: "$tag",
                    child: ProfileTop(
                        name: "$name",
                        picUrl: "$pic",
                        profession: "$profession",
                        location: "$location"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "$name's Goals",
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: size.height / 45),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Wrap(
                        children: List.generate(
                            goals.length,
                            (index) => Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                  child: goalBox(goals[index], context, index),
                                )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              deleteItem(index, id);
                            },
                            child: Container(
                              width: size.width * 0.35,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).primaryColor),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Center(
                                child: Text(
                                  "Skip",
                                  style: TextStyle(
                                      fontSize: size.height / 44,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          (showButton[index])
                              ? InkWell(
                                  onTap: () {
                                    add(id, name, pic, index);
                                  },
                                  child: Container(
                                    width: size.width * 0.35,
                                    height: size.height * 0.06,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Theme.of(context).primaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Center(
                                      child: Text(
                                        "Connect",
                                        style: TextStyle(
                                            fontSize: size.height / 44,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: size.width * 0.35,
                                  height: size.height * 0.06,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      border: Border.all(
                                          width: 1,
                                          color:
                                              Theme.of(context).primaryColor),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Center(
                                    child: Text(
                                      "Connect",
                                      style: TextStyle(
                                          fontSize: size.height / 44,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Future<List<Widget>> _getDataFromLocalDb() async {
    // _getPeople();
    int i = 0;
    stackedCards.clear();
    // details.clear();
    db.getPeopleFinderPeople().then((value) {
      // print('This is from Local DB: $value Hello');
      if (value.length == 0) {
        setState(() {
          nlen = 1;
        });
      } else {
        setState(() {
          nlen = 0;
        });
      }
      value.forEach((element) {
        List goals = [];
        // List testimonials = [];
        db.selectGoals("${element['personId']}").then((value2) {
          goals = value2;
        }).then((value) {
          // setState(() {
          if (!crossCheckList.contains(element['personId'])) {
            // print("$element, $goals");
            details.add({"user_info": element, "goal_info": goals});
            setState(() {
              stackedCards.add(cardGenerator(
                  element['personName'],
                  element['personId'],
                  element['personName'],
                  element['personPic'],
                  element['personProfession'],
                  element['personLocation'],
                  element['personBio'],
                  goals,
                  null,
                  i));
            });
            crossCheckList.add(element['personId']);
          }
          // });
        });

        i = i + 1;
      });
    });

    return stackedCards;
  }

  timecounter() async {
    Timer.periodic(Duration(seconds: 5), (Timer t) {
      setState(() {
        nearSendAgain = true;
        allSendAgain = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    (pageNo == 0)
        ? _getPeople().then((value) {
            _getDataFromLocalDb();
          })
        : _getAllPeople();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: size.width,
                height: size.height * 0.22,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.elliptical(250, 120))),
                      ),
                    ),
                    Positioned(
                        top: 30,
                        right: 5,
                        child: Image.asset(
                          "assets/images/09.png",
                          width: 100,
                          height: 100,
                        )),
                    Positioned(
                      top: size.height * 0.05,
                      left: 25,
                      child: RichText(
                        text: TextSpan(
                            text: "A New Great Day,\n",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: size.height * 0.028,
                                color: Colors.black,
                                wordSpacing: 1,
                                letterSpacing: 0,
                                //height: 1.5,
                                fontFamily: 'Nunito'),
                            children: [
                              TextSpan(
                                  text: "${name.split(" ")[0]}!",
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal))
                            ]),
                      ),
                    ),
                    Container(
                      child: Positioned(
                          bottom: 13,
                          left: 25,
                          child: Text(
                            "March towards your goal\nwith like minded souls",
                            style: TextStyle(
                                color: Colors.black,
                                textBaseline: TextBaseline.alphabetic,
                                fontSize: size.height * 0.02,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500),
                          )),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 6.0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            pageNo = 0;
                          });
                        },
                        child: Container(
                          width: 120,
                          height: size.height * 0.06,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  Icons.my_location,
                                  size: 18,
                                ),
                                Text(
                                  "Near Me",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          decoration: (pageNo == 0) ? selected() : unSelected(),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            pageNo = 1;
                          });
                          _getAllPeople();
                        },
                        child: Container(
                          width: 120,
                          height: size.height * 0.06,
                          child: Center(
                            child: Text(
                              "All",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                          decoration: (pageNo == 1) ? selected() : unSelected(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (pageNo == 0)
                  ? (details.length > 0)
                      ? Stack(
                          children: List.generate(details.length, (index) {
                          var uinfo = details[(details.length - 1) - index]
                              ['user_info'];
                          return cardGenerator(
                              uinfo['personName'],
                              uinfo['personId'],
                              uinfo['personName'],
                              uinfo['personPic'],
                              uinfo['personProfession'],
                              uinfo['personLocation'],
                              uinfo['personBio'],
                              details[(details.length - 1) - index]
                                  ['goal_info'],
                              [],
                              (details.length - 1) - index);
                        }))
                      : nlen == 0
                          ? Center(
                              child: Image.asset(
                                "assets/images/animat-search-color.gif",
                                height: 125.0,
                                width: 125.0,
                              ),
                            )
                          : Container(
                              child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Image.asset(
                                    'assets/images/oops.png',
                                    height: size.height / 2.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Center(
                                    child: Text(
                                      'No Similar People',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                  : showAllProfiles(),
            ],
          ),
        ));
  }

  deleteItem(index, id) {
    int x, y;
    // details.removeAt(index);
    details.forEach((val) {
      x = (val['user_info']['id'] == id) ? details.indexOf(val) : 0;
    });
    allProfiles.forEach((val) {
      y = (val['user_info']['id'] == id) ? allProfiles.indexOf(val) : 0;
    });
    setState(() {
      print("x: $x, y: $y");
      details.removeAt(x);
      allProfiles.removeAt(y);
      // crossCheckList.removeAt(crossCheckList.indexOf(id));
      // allProfilesCrossCheck.removeAt(allProfilesCrossCheck.indexOf(id));
      db.peopleFinderRemovePerson(id);
      db.removePersonGoals(id);
    });
    db.peopleFinderRemovePerson(id);
    db.removePersonGoals(id);
  }

  void _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('token') ?? "";
    // uid = prefs.getString('uid') ?? "";
    id = prefs.getString('id') ?? "";
    // SQLITE

    int n;
    db.getGoalCount().then((value) {
      setState(() {
        n = value;
      });
    });
    // var user = await db.getUser(1);
    db.getUser(1).then((value) {
      setState(() {
        uid = value.userId;
        name = value.username;
      });
    });

    db.getGoalsName().then((value) {
      setState(() {
        var m = value[0];
        goals = m["goalName"];
        goalList.add(m["goalName"]);
        for (var i = 1; i < n; i++) {
          var m = value[i];
          goals = goals + "," + m["goalName"];
          goalList.add(m["goalName"]);
        }
        // print(goals);
      });
    });

    setState(() {
      token = userToken;
      //   uid = user.userId;
    });
    _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.granted) {
      _serviceEnabled = await location.serviceEnabled();

      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          // print("No Thanks");
          setState(() {
            lat = "17.4538444";
            lng = "78.416675";
            check = 1;
          });
          return;
        } else {
          // print("Clicked Ok");
          _locationData = await location.getLocation();
          print("lat : " +
              _locationData.latitude.toString() +
              "long : " +
              _locationData.longitude.toString());
          setState(() {
            lat = _locationData.latitude.toString();
            lng = _locationData.longitude.toString();
            check = 1;
          });
        }
      } else {
        _locationData = await location.getLocation();
        print("lat : " +
            _locationData.latitude.toString() +
            "long : " +
            _locationData.longitude.toString());
        setState(() {
          lat = _locationData.latitude.toString();
          lng = _locationData.longitude.toString();
          check = 1;
        });
      }
    } else {
      //location permission in settings
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted == PermissionStatus.granted) {
        //checking gps
        _serviceEnabled = await location.serviceEnabled();

        if (!_serviceEnabled) {
          _serviceEnabled = await location.requestService();
          if (!_serviceEnabled) {
            print("No Thanks");
            setState(() {
              lat = "17.4538444";
              lng = "78.416675";
              check = 1;
            });
            return;
          } else {
            print("Clicked Ok");
            _locationData = await location.getLocation();
            print("lat : " +
                _locationData.latitude.toString() +
                "long : " +
                _locationData.longitude.toString());
            setState(() {
              lat = _locationData.latitude.toString();
              lng = _locationData.longitude.toString();
              check = 1;
            });
          }
        } else {
          _locationData = await location.getLocation();
          print("lat : " +
              _locationData.latitude.toString() +
              "long : " +
              _locationData.longitude.toString());
          setState(() {
            lat = _locationData.latitude.toString();
            lng = _locationData.longitude.toString();
            check = 1;
          });
        }
      } else {
        //when location permission rejected
        setState(() {
          lat = "17.09";
          lng = "78.05";
          check = 1;
        });
      }
    }
  }

  Widget showAllProfiles() {
    Size size = MediaQuery.of(context).size;
    print("$allProfiles");
    (pageNo == 0)
        ? _getPeople().then((value) {
            _getDataFromLocalDb();
          })
        : _getAllPeople();
    return Center(
      child: Container(
        child: (allProfiles.length == 0)
            ? alen == 0
                ? Center(
                    child: Image.asset(
                      "assets/images/animat-search-color.gif",
                      height: 125.0,
                      width: 125.0,
                    ),
                  )
                : Container(
                    child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Image.asset(
                          'assets/images/oops.png',
                          height: size.height / 2.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(
                            'No Similar People',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ))
            : Column(
                children: List.generate(
                    (allProfiles.length > 20) ? 20 : allProfiles.length,
                    (index) {
                  var userInfo = allProfiles[index]['user_info'];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                    name: userInfo['fullName'],
                                    pic: userInfo['profile_pic'],
                                    bio: userInfo['bio'],
                                    profession: userInfo['profession'],
                                    goals: allProfiles[index]['goal_info'],
                                    location: "Age: ${userInfo['age']}",
                                    userId: userInfo['id'],
                                    fromNetwork: false,
                                  )));
                    },
                    child: Card(
                        color: Colors.white,
                        shadowColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              width: size.width - 50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 5, top: 5),
                                    child: Container(
                                      width: size.width / 4,
                                      height: size.width / 4,
                                      decoration: BoxDecoration(
                                          //border: Border.all(width: 5, color: Colors.white),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "${allProfiles[index]['user_info']['profile_pic']}",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 8.0, bottom: 8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "${allProfiles[index]['user_info']['fullName']}",
                                          style: TextStyle(
                                              fontSize: size.height / 39,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(height: 3),
                                        Container(
                                          width: size.width * 0.57,
                                          child: Text(
                                            "${allProfiles[index]['user_info']['profession']}",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: size.height / 43,
                                                fontFamily: 'Nunito',
                                                fontWeight: FontWeight.w600),
                                            maxLines: 2,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          "Age: ${allProfiles[index]['user_info']['age']}",
                                          style: TextStyle(
                                              fontSize: size.height / 48,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(height: 6),
                                        Container(
                                          width: size.width * 0.57,
                                          child: AutoSizeText(
                                            "${(allProfiles[index]['user_info']['bio'].toString())}",
                                            style: TextStyle(
                                                fontSize: size.height / 46),
                                            maxLines: 3,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                db
                                                    .getSingleUser(
                                                        allProfiles[index]
                                                            ['user_info']['id'])
                                                    .then((value) {
                                                  add(
                                                      allProfiles[index]
                                                          ['user_info']['id'],
                                                      allProfiles[index]
                                                              ['user_info']
                                                          ['fullName'],
                                                      allProfiles[index]
                                                              ['user_info']
                                                          ['profile_pic'],
                                                      index);
                                                });
                                              },
                                              child: Container(
                                                width: size.width * 0.26,
                                                height: size.height * 0.05,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Center(
                                                  child: Text(
                                                    "Connect",
                                                    style: TextStyle(
                                                        fontSize:
                                                            size.height / 44,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        )),
                  );
                }),
              ),
      ),
    );
  }

  Future<void> add(userId, userName, userImage, index) async {
    bool checkStatus = false;
    TextEditingController messageController = new TextEditingController();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String msg = prefs.getString('DefaultMessage') ?? "";
    messageController.text = "";
    setState(() {
      if (msg != "") {
        messageController.text = msg;
        checkStatus = true;
      } else {
        messageController.clear();
      }
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(// StatefulBuilder
              builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(15.0))), //this right here
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.46,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Send A Message",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 35,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        Container(
                          height: 15,
                        ),
                        TextField(
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500),
                          controller: messageController,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey[300], width: 1.0),
                              ),
                              hintText: 'Enter a Message'),
                        ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: checkStatus,
                              onChanged: (value) {
                                setState(() {
                                  checkStatus = value;
                                });
                                rememberMessage(value, messageController.text);
                              },
                            ),
                            Text("Set as Default")
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width / 2.2,
                            ),
                            Expanded(
                              child: SizedBox(
                                width: 100,
                                child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    onPressed: () async {
                                      var msg = messageController.text;
                                      var db = DataBaseHelper();
                                      messageController.clear();
                                      rememberMessage(checkStatus, msg);
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String id = prefs.getString('id') ?? "";
                                      print("UID IS EMPTY? $uid");
                                      await http.post(
                                          'https://march.lbits.co/api/worker.php',
                                          body: json.encode(<String, dynamic>{
                                            "serviveName": "",
                                            "work": "add new request",
                                            "uid": "$uid",
                                            "sender": "$id",
                                            "receiver": "$userId",
                                            "message": "$msg",
                                            "requestStatus": "pending"
                                          }),
                                          headers: {
                                            'Authorization': 'Bearer $token',
                                            'Content-Type': 'application/json'
                                          }).then((value) {
                                        var resp = json.decode(value.body);
                                        print(resp);
                                        deleteItem(index, userId);
                                        if (resp['response'] == 200) {
                                          print('res:200');
                                          Navigator.pop(context);
                                          var key = UniqueKey();
                                          socketIO.sendMessage(
                                              "New user Request",
                                              json.encode({
                                                "msgCode": "$key",
                                                "message": "$msg",
                                                "sender": id,
                                                "receiver": userId,
                                                "containsImage": "0",
                                                "imageUrl": "none",
                                                "time": '${DateTime.now()}',
                                              }));
                                          Map<String, dynamic> messageMap = {
                                            DataBaseHelper.seenStatus: '0',
                                            DataBaseHelper.messageCode: '$key',
                                            DataBaseHelper.messageOtherId:
                                                userId,
                                            DataBaseHelper.messageSentBy: id,
                                            DataBaseHelper.messageText: msg,
                                            DataBaseHelper.messageContainsImage:
                                                '0',
                                            DataBaseHelper.messageImage: 'null',
                                            DataBaseHelper.messageTime:
                                                "${DateTime.now()}"
                                          };

                                          imageSaver(userImage).then((value) {
                                            Map<String, dynamic> friendsMap = {
                                              DataBaseHelper.friendId: userId,
                                              DataBaseHelper.friendName:
                                                  userName,
                                              DataBaseHelper.friendPic:
                                                  value['image'],
                                              DataBaseHelper.friendSmallPic:
                                                  value['small_image'],
                                              DataBaseHelper.friendLastMessage:
                                                  msg,
                                              DataBaseHelper
                                                      .friendLastMessageTime:
                                                  "${DateTime.now()}"
                                            };
                                            db.addUser(friendsMap);
                                            db.addMessage(messageMap);
                                            db.peopleFinderRemovePerson(userId);
                                            db.removePersonGoals(userId);
                                          });
                                        } else {
                                          print("res: " + "$resp");
                                        }
                                      });
                                      StatusAlert.show(context,
                                          duration: Duration(seconds: 2),
                                          title: "Added",
                                          configuration: IconConfiguration(
                                              icon: Icons.done));
                                    },
                                    child: Text(
                                      "Add",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  rememberMessage(value, message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    (value)
        ? prefs.setString("DefaultMessage", message)
        : prefs.remove("DefaultMessage");
  }
}
