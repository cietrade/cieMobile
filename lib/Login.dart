import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Globals.dart' as globals;
import 'package:http/http.dart';
import 'dart:convert';
import 'HelperFunctions.dart';
import 'HomePage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _userNameTextController = TextEditingController();
  final _pwdTextController = TextEditingController();
  bool loading = false;
  bool saveUserNm = false;
  double _formProgress = 0;
  String version = "";
  late SharedPreferences prefs;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _userNameTextController.dispose();
    _pwdTextController.dispose();
    super.dispose();
  }

  setVersionAndLoginInfo() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    prefs = await SharedPreferences.getInstance();
    final String? UserName = prefs.getString('UserName');
    String? shouldSave = prefs.getString('shouldSave');
    //final String? Password = prefs.getString('Password');
    shouldSave = shouldSave ?? "0";

    if(prefs.containsKey("UOM")) {
      globals.UOM = prefs.getString('UOM')! ;
    } else {
      globals.UOM = "L";
      prefs.setString("UOM", "L");
    }
    setState(() {
      version = packageInfo.buildNumber;

      globals.version = packageInfo.buildNumber;
      if(UserName!.isNotEmpty){
        if(shouldSave == "1"){_userNameTextController.text = UserName;}
      }
      saveUserNm = (shouldSave == "1");
      //if(Password!.isNotEmpty){_pwdTextController.text = Password;}
    });
  }
  @override
  void initState(){
    super.initState();
    _userNameTextController.text = '';//'Admin';
    _pwdTextController.text = '';//'''2Turukuw!';
    WidgetsBinding.instance.addPostFrameCallback((_){
      setVersionAndLoginInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder borderStyle = OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Colors.white, width: 0.0) );

    return Scaffold(
      backgroundColor: const Color(0xFFFE0000),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE0000),
        //Theme.of(context).colorScheme.inversePrimary,
        title: const Text(""),
        actions: [],
        leading: Text(""),
      ),
      bottomNavigationBar: BottomAppBar(

        color: Colors.transparent,
        height: 100,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Version $version', style: GoogleFonts.libreFranklin( textStyle: const TextStyle(color: Colors.white, fontSize: 15,)),),
                  Text('2024 - cieTrade Systems Inc', style: GoogleFonts.libreFranklin( textStyle:TextStyle(color: Colors.white, fontSize: 15,)),),
                ],
              )
              ,)
          ],
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 100.0, bottom: 10.0),
                  child: Text('cieMobile',
                      style: GoogleFonts.libreFranklin( textStyle: const TextStyle(color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold),
                      )),
                ),
                Padding(
                  //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    width: 300,
                    height: 50,
                    child: TextField(
                      controller: _userNameTextController,
                      autocorrect: false,
                      decoration:  InputDecoration(
                        border: borderStyle,
                        focusedBorder: borderStyle,
                        enabledBorder: borderStyle,
                        errorBorder: borderStyle,
                        disabledBorder: borderStyle,
                        contentPadding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                        hintText: 'Username',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5, bottom: 15),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    width: 300,
                    height: 50,
                    child: TextField(
                      controller: _pwdTextController,
                      autocorrect: false,
                      obscureText: true,
                      decoration:  InputDecoration(
                          border: borderStyle,
                          focusedBorder: borderStyle,
                          enabledBorder: borderStyle,
                          errorBorder: borderStyle,
                          disabledBorder: borderStyle,
                          contentPadding: const EdgeInsets.only(top: 5, left: 5, right: 5),
                          hintText: 'Password'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 300,
                  child: FloatingActionButton(
                    splashColor: Colors.transparent,
                    backgroundColor: Colors.white,
                    onPressed: _showWelcomeScreen,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: loading ?  const Center(child: CircularProgressIndicator.adaptive()) :  Text('Login', style: GoogleFonts.lato( textStyle: TextStyle(color: Color(0xFF808080), fontSize: 19)),),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40, top: 20, bottom: 0, right: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Remember Username",style: GoogleFonts.libreFranklin( textStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),) ),
                        Switch(
                            value: saveUserNm,
                            activeColor: Colors.green,
                            activeTrackColor: Colors.white,
                            onChanged: (bool value){
                              setState(() {saveUserNm = value;});
                            }
                        )
                      ]
                  ),
                ),

                const SizedBox(height: 100,),

              ],
            ),
          )
      ),
    );
  }

  //Checks login credentials
  Future<bool> Login(String userNm, String pswd) async {
    var url = Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/LoginAutoUpdate");
    Map data = {
      "User": userNm,
      "Pswd": pswd,
      "AppName": "cieMobile",
      "Version": version
    };
    Response rep = await post(url, headers: {"Content-Type": "application/json"}, body: json.encode(data));

    if (rep.statusCode == 200) {
      var body = jsonDecode(rep.body);
      if (body.length != 1) {
        globals.dBUserID = body["DBUserID"] == null ? "" : body["DBUserID"];
        globals.userID = userNm ;//body["UserID"] == null ? "" : body["UserID"];
        globals.userPswd = pswd;//body["UserPassword"] == null ? "" : body["UserPassword"];
        globals.userName = body["UserName"] == null ? "" : body["UserName"];
        globals.userEmail = body["UserEmail"] == null ? "" : body["UserEmail"];
        globals.lastDB = body["LastDB"] == null ? "" : body["LastDB"];
        globals.serverNm = body["CompanyName"] == null ? "" : body["CompanyName"];
        globals.dBNm = body["DatabaseName"] == null ? "" : body["DatabaseName"];
        globals.cieTradeUserID = body["cieTradeUserID"] == null ? "" : body["cieTradeUserID"];
        globals.dBID = body["DatabaseName"] == null ? "" : body["DatabaseName"];
        globals.driver = body["DispatchDriver"] == null ? "" : body["DispatchDriver"];
        globals.warehouseNm = body["WarehouseNm"] == null ? "" : body["WarehouseNm"];
        globals.warehouseID = body["WarehouseID"] == null ? "" : body["WarehouseID"];
        globals.isDotNet = (body["ServerAddr"] == "CIE-SQLDEV04") ;
        globals.isAdmin = (globals.cieTradeUserID.toUpperCase() == "ADMIN" || globals.cieTradeUserID.toUpperCase() == "SOCSOFT" );
        //if(!globals.isDotNet ){globals.cieTradeUserID = globals.userID;}
      }
    }

    rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=PERMISSIONS&objID=${globals.cieTradeUserID}"));
    if (rep.statusCode == 200) {
      var body = jsonDecode(rep.body);
      globals.SOEdit = body["SOEdit"];
      globals.SOCreate = body["SOCreate"];
      globals.SOViewAll = body["SOViewAll"];
      globals.SOEmail = body["SOEmail"];
      globals.POEdit = body["POEdit"];
      globals.POCreate = body["POCreate"];
      globals.POViewAll = body["POViewAll"];
      globals.POEmail = body["POEmail"];
      globals.SODel = body["SODel"];
      globals.PODel = body["PODel"];
      globals.WksViewAll = body["WksViewAll"];
      globals.WksViewUser = body["WksViewUser"];
      globals.WksViewReps = body["WksViewReps"];
      globals.OrderViewUser = body["OrderViewUser"];
      globals.OrderViewReps = body["OrderViewReps"];
      globals.DefDept = body["DefDept"];
      globals.DefDeptNm = body["DefDeptNm"];
      globals.LockedDept = body["LockedDept"];
      globals.DefRep = body["DefRep"];
      globals.LockedRep = body["LockedRep"];
      globals.isActive = body["IsActive"];
      globals.ReqTradeType = body["ReqTradeType"];
      if(globals.LockedDept == "True"){
        globals.LockedDept = "1";
      } else if(globals.LockedDept == "False"){
        globals.LockedDept = "0";
      }

    }


    return globals.userID != "" && globals.isActive == "1";
  }

  //Transfers to table page
  void _showWelcomeScreen() async {
    String userNm = _userNameTextController.value.text;
    String pswd = _pwdTextController.value.text;
    if(saveUserNm){prefs.setString('UserName', userNm);}
    prefs.setString("shouldSave", saveUserNm ? "1" : "0");
    //prefs.setString('Password', pswd);
    setState(() {loading = true;});
    try{
      bool loginValid = await Login(userNm, pswd);
      setState(() {loading = false;});
      if (loginValid) {
        // ignore: use_build_context_synchronously

        Navigator.of(context).pushNamed('/Home');
      } else {
        //PopUp(context, "Login Info", "Username $userNm password is $pswd.");
        if(globals.isActive != "1" && globals.userID.isNotEmpty){
          PopUp(context, "Login Failed", "This user has been marked as inactive.");
        } else {
          PopUp(context, "Login Failed", "Username and/or password is incorrect.");
        }

      }
    } on Exception catch(e) {
      PopUp(context, "Login Crashed", e.toString());
    }
  }



  void _updateFormProgress() {
    //Updates progress bar. Called on form change
    var progress = 0.0;
    final controllers = [
      _userNameTextController,
      _pwdTextController,
    ];
    for (final controller in controllers) {
      if (controller.value.text.isNotEmpty) {
        progress += 1 / controllers.length;
      }
    }

    setState(() {
      _formProgress = progress;
    });
  }
}
