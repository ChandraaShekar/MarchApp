import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:march/models/goal.dart';
import 'package:march/utils/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class EditGoal extends StatefulWidget {
  String gno;
  String uid;
  EditGoal(this.gno,this.uid);
  @override
  _EditGoalState createState() => _EditGoalState();
}

class Time{
  int id;
  String time;

  Time(this.id,this.time);

  static List<Time> getTime(){
    return <Time> [
      Time(1,'1 Month'),
      Time(2,'3 Month'),
      Time(3,'6 Month'),
      Time(4,'1 Year'),
      Time(5,'>1 Year'),
    ];
  }
}

class _EditGoalState extends State<EditGoal> {

  List<Time> _time=Time.getTime();
  List<DropdownMenuItem<Time>> _dropdownMenuItems;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  Time _selectedTime;
  String token;
  String time="1 Month";
  String selectedGoal="";
  final GlobalKey<ScaffoldState> _sk=GlobalKey<ScaffoldState>();
  int _disable=0;
  String currentText="";
  List<String> suggestions = [
    "Sports",
    "Exam",
    "Health",
    "Music",
    "Dance",
    "Treking",
    "KickBoxing",
  ];


  final myController = TextEditingController();
  String target="";
  onChangeDropDownItem(Time selectedTime){
    setState(() {
      _selectedTime=selectedTime;
      time=selectedTime.time;
    });
  }

  @override
  void initState() {
    _dropdownMenuItems =buildDropDownMenuItems(_time);
    _selectedTime=_dropdownMenuItems[0].value;
    _load();
    super.initState();
  }


  List<DropdownMenuItem<Time>> buildDropDownMenuItems(List tim){
    List<DropdownMenuItem<Time>> items=List();
    for(Time time in tim){
      items.add(DropdownMenuItem(
        value:time,
        child: Text(time.time),
      )
      );
    }
    return items;
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sk,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFFFFFF),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title:  Center(child: Text("Update Goal",style: TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'montserrat'),)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(bottom: 6.0), //Same as `blurRadius` i guess
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 2.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SimpleAutoCompleteTextField(
                      key: key,
                      decoration: new InputDecoration(
                          hintText: "Enter Your Goals",
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          )
                      ),
                      controller: TextEditingController(),
                      suggestions: suggestions,
                      textChanged: (text) => currentText = text,
                      clearOnSubmit: true,
                      textSubmitted: (text) => setState(() {
                        if (text != "" && _disable==0) {
                          print(text);
                          setState(() {
                            _disable=1;
                            selectedGoal=text;
                          });
                        }
                        else{
                          _sk.currentState.showSnackBar(SnackBar(
                            content: Text("Enter all details and Submit next",
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

                  _disable==1?Padding(
                    padding: const EdgeInsets.fromLTRB(18.0,8,8,8),
                    child: Row(
                      children: <Widget>[
                        Text("Selected Goal:  ",style: TextStyle(color: Color.fromRGBO(63, 92, 200, 1)),),
                        Text(selectedGoal)
                      ],
                    ),
                  ):Container(),


                  Padding(
                    padding: const EdgeInsets.fromLTRB(25.0,60,20.0,0),
                    child: Row(
                      children: <Widget>[
                        Text('Time Frame : '),
                        SizedBox(width: 20,),
                        DropdownButton(
                          value: _selectedTime,
                          items: _dropdownMenuItems,
                          onChanged: onChangeDropDownItem,
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top:60.0,left: 15),
                    child: Text("Mention the target for your goal"),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0,20,15,0),
                    child: Container(
                      child: TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Workout for an hour a day",
                          border: OutlineInputBorder(),
                        ),
                        controller: myController,
                        onChanged: (String value) {
                          try {
                            target = value;
                          } catch (exception) {
                            target ="";
                          }
                        },
                      ),
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.only(top:50.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width*0.15,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(6.0),
                                ),
                                color: Color.fromRGBO(63, 92, 200, 1) ,
                                onPressed: () {
                                  setState(() {
                                    target="";
                                    time="1 Month";
                                    selectedGoal="";
                                    _disable=0;
                                    myController.clear();
                                    _selectedTime=_dropdownMenuItems[0].value;
                                  });

                                },
                                child: const Text(
                                    'Clear',
                                    style: TextStyle(fontSize: 12,color: Colors.white)

                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width*0.15,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(6.0),
                                ),
                                color: Color.fromRGBO(63, 92, 200, 1) ,
                                onPressed: () async{

                                  if(selectedGoal!=""&&myController.text!=""){

                                    _onLoading();
                                    print('time : '+time+' target :'+target+" "+widget.uid+" "+widget.gno);

                                    var url= 'https://march.lbits.co/api/worker.php';
                                    var resp=await http.post(url,
                                      headers: {
                                        'Content-Type':
                                        'application/json',
                                        'Authorization':
                                        'Bearer $token'
                                      },
                                      body: json.encode(<String, dynamic>
                                      {
                                        'serviceName': "",
                                        'work': "add goal",
                                        'uid':widget.uid,
                                        'goalName':selectedGoal,
                                        'target':target,
                                        'timeFrame':time,
                                        'goalNumber':widget.gno,
                                      }),
                                    );

                                    print("res "+resp.body.toString());

                                   var result = json.decode(resp.body);
                                    if(result['response'] == 200){
                                      var db = new DataBaseHelper();
                                      int cnt=await db.getGoalCount();

                                      if(cnt>=int.parse(widget.gno)){

                                      //  print(widget.gno+" "+selectedGoal);
                                        await db.updateGoal(Goal(widget.uid,selectedGoal,target,time,widget.gno));

                                        /*Goal g=await db.getGoal(int.parse(widget.gno));
                                        print(g.goalName+" "+g.goalNumber);*/

                                        Navigator.pushAndRemoveUntil(context,
                                            MaterialPageRoute(builder: (context) => Home()),
                                                (Route<dynamic> route) => false);

                                      }
                                      else{

                                        int savedGoal =
                                        await db.saveGoal(new Goal(widget.uid,selectedGoal,target,time,widget.gno));

                                        print("goal saved :$savedGoal");

                                        Navigator.pushAndRemoveUntil(context,
                                            MaterialPageRoute(builder: (context) => Home()),
                                                (Route<dynamic> route) => false);

                                      }

                                    }
                                    else{
                                      Navigator.pop(context);
                                      setState(() {
                                        _disable=0;
                                        target="";
                                        myController.clear();
                                        time="1 Month";
                                        _selectedTime=_dropdownMenuItems[0].value;
                                      });

                                      _sk.currentState.showSnackBar(SnackBar(
                                        content: Text("There is Some Technical Problem Submit again",
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
                                  else{
                                    _sk.currentState.showSnackBar(SnackBar(
                                      content: Text("Enter all Details",
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

                                },
                                child: const Text(
                                    'Submit',
                                    style: TextStyle(fontSize: 12,color: Colors.white)

                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  )



                ],
              ),
            ),

          ),
        ),
      ),
    );
  }

  void _load() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('token') ?? "";
    setState(() {
      token=userToken;
    });
  }
    void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text("Loading"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}