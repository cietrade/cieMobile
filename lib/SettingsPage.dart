
import 'package:ciemobile/AccountPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'HelperFunctions.dart' ;
import 'package:google_fonts/google_fonts.dart';
import 'HelperFunctions.dart';
import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';

class SettingsPage extends StatefulWidget{
  Function() refresh;
  SettingsPage({required this.refresh});

  @override
  State<SettingsPage> createState() => SettingsPageState();

}

class SettingsPageState extends State<SettingsPage>{
  late SharedPreferences prefs;
  EdgeInsetsGeometry pad = EdgeInsets.only(left: 16, top: 10, bottom: 10, right: 20);
  List<String> UOMs = <String>["L", "S", "M"];
  List<bool> selectedUOM = [globals.UOM == "L", globals.UOM == "S", globals.UOM == "M"];
  List<Widget> txtUOM = <Widget>[Text('LBS'), Text('ST'), Text('MT')];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      setPrefs();
    });


  }

  @override
  Widget build(BuildContext context) {
    TextStyle headerStyle = GoogleFonts.lato( textStyle:  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600));
    TextStyle subHeaderStyle = GoogleFonts.lato( textStyle:  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500));
    TextStyle valueStyle = GoogleFonts.lato( textStyle:  const TextStyle( fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF5A6978)));
    String WksView = "";
    String OrderView = "";
    String OrderCreate = "";
    String OrderEdit = "";
    String OrderDocs = "";

    if(globals.isDotNet){
      if(globals.WksViewAll == "0"){WksView = "MY WKS";} else {WksView = "ALL";}

      if(globals.POViewAll == "0"){OrderView += "MY PO, ";} else {OrderView += "ALL PO, ";}
      if(globals.SOViewAll == "0"){OrderView += "MY SO, ";} else {OrderView += "ALL SO, ";}
      OrderView = OrderView.substring(0, OrderView.length - 2);

      if(globals.POCreate == "1"){OrderCreate += "PO, ";}
      if(globals.SOCreate == "1"){OrderCreate += "SO, ";}
      if(OrderCreate.isEmpty){OrderCreate = "NONE";} else { OrderCreate = OrderCreate.substring(0, OrderCreate.length - 2);}

      if(globals.POEdit== "1"){OrderEdit += "PO, ";}
      if(globals.SOEdit== "1"){OrderEdit += "SO, ";}
      if(OrderEdit.isEmpty){OrderEdit = "NONE";} else { OrderEdit = OrderEdit.substring(0, OrderEdit.length - 2);}

      if(globals.POEmail== "1"){OrderDocs += "PO, ";}
      if(globals.SOEmail== "1"){OrderDocs += "SO, ";}
      if(OrderEdit.isEmpty){OrderDocs = "NONE";} else { OrderDocs = OrderDocs.substring(0, OrderDocs.length - 2);}
    } else {
      if(globals.WksViewAll == "1"){
        WksView = "ALL";
      } else if(globals.WksViewUser == "1"){
        WksView = "ONLY MINE";
      } else if(globals.WksViewReps == "1"){
        WksView = "ONLY MINE + SALES REPS";
      } else {
        WksView = "NONE";
      }

      if(globals.SOViewAll == "1"){
        OrderView = "ALL";
      } else if(globals.OrderViewUser == "1"){
        OrderView = "ONLY MINE";
      } else if(globals.OrderViewReps== "1"){
        OrderView = "ONLY MINE + SALES REPS";
      }else {
        OrderView = "NONE";
      }

      if(globals.SOEdit == "0"){
        OrderEdit = "NONE";
      } else if(globals.SOEdit == "1"){
        OrderEdit = "ALL";
      } else if(globals.SOEdit == "2"){
        OrderEdit = "ONLY MINE";
      }

      if(globals.SOCreate == "1"){
        OrderCreate = "ALL";
      } else {
        OrderCreate = "NONE";
      }

      if(globals.SOEmail == "1"){
        OrderDocs = "ALL";
      } else {
        OrderDocs = "NONE";
      }
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: Text(""),
          title:  Text("Settings", style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
      ),

      body: ListView(
        children: [
          Divider(),
          getFieldTile(Text("Version", style: headerStyle,), Text(globals.version, style: valueStyle)),
          Divider(),
          getFieldTile(Text("Permissions", style: headerStyle,), Text("")),
          getFieldTile(Text("Is Admin", style: subHeaderStyle,), Text("${globals.isAdmin ? "YES" : "NO"}", style: valueStyle, textAlign: TextAlign.end,)),
          getFieldTile(Text("Dept Locked", style: subHeaderStyle,), Text("${globals.LockedDept == "1" ? "YES" : "NO"}", style: valueStyle, textAlign: TextAlign.end,)),
          getFieldTile(Text("Default Dept", style: subHeaderStyle,), Text("${globals.DefDeptNm.trim() == "ALL DEPTS" ? "" : globals.DefDeptNm}", style: valueStyle, textAlign: TextAlign.end,)),
          getFieldTile(Text("Wks View", style: subHeaderStyle,), Text(WksView, style: valueStyle, textAlign: TextAlign.end,)),
          getFieldTile(Text("Order View", style: subHeaderStyle,), Text(OrderView, style: valueStyle, textAlign: TextAlign.end,)),
          getFieldTile(Text("Order Edit", style: subHeaderStyle,), Text(OrderEdit, style: valueStyle, textAlign: TextAlign.end,)),
          getFieldTile(Text("Order Create", style: subHeaderStyle,), Text(OrderCreate, style: valueStyle, textAlign: TextAlign.end,)),
          getFieldTile(Text("Send Order Docs", style: subHeaderStyle,), Text(OrderDocs, style: valueStyle, textAlign: TextAlign.end,)),

          Padding(
            padding: EdgeInsets.only(left: 16, top: 0, bottom: 0, right: 20),
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Unit of Measure", style: subHeaderStyle,),
                ToggleButtons(
                    children: txtUOM,
                    isSelected: selectedUOM,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  constraints: const BoxConstraints(
                    minHeight: 30.0,
                    minWidth: 50.0,
                  ),
                    onPressed: (int index){
                      globals.UOM = UOMs[index];
                      prefs.setString("UOM", globals.UOM);
                      setState(() {
                        selectedUOM = [false, false, false];
                        selectedUOM[index] = true;}
                      );
                      widget.refresh();
                    },
                )
              ],
            ),
          ),
          Divider(),
          const SizedBox(height: 20,),
          Center( child:
              SizedBox(
                  height: 50,
                  width: 300,
                  child:FloatingActionButton(
                    splashColor: Colors.transparent,
                    backgroundColor: Color(0xFF8E96A1),
                    onPressed: (){
                      Navigator.of(context).pushNamed('/');
                    },
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Text('Log Out', style: GoogleFonts.lato( textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 19)),),
                  )
              )
          )

        ],
      )
    );
  }

  Widget getFieldTile(Text title, Text value){
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 2, bottom: 2, right: 20),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [title, value],
      ),
    );
  }

  setPrefs() async{
      prefs = await SharedPreferences.getInstance();
  }


}