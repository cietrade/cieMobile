import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';


void PopUp(BuildContext context, String title, String txt) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title, style: GoogleFonts.lato(fontSize: 23, fontWeight: FontWeight.w700, color: Color(0xFF676769))),
    content: Text(txt, style: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF676769))),
    actions: [ TextButton(
      child: Text("OK", style:GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF676769)) ),
      onPressed: () { Navigator.pop(context, 'OK');},
    ),],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {return alert;},
  );
}

void PopUpConfirm(BuildContext context, String title, String txt) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title, style: GoogleFonts.lato(fontSize: 23, fontWeight: FontWeight.w700, color: Color(0xFF676769))),
    content: Text(txt, style: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF676769))),
    actions: [
      TextButton(
        child: Text("Cancel", style:GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF676769)) ),
        onPressed: () {
          Navigator.pop(context, 'OK');
          },
      ),
      TextButton(
        child: Text("OK", style:GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF676769)) ),
        onPressed: () {
          Navigator.pop(context, 'OK');
          Navigator.of(context).pop();
        },
      ),
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {return alert;},
  );
}
String getUOMID(String UOM){
  switch(UOM){
    case "LB": {return 'L';}
    case "ST": {return 'S';}
    case "KG": {return 'K';}
    case "MT": {return 'M';}
    case "EA": {return 'E';}
    case "FBM": {return 'X';}
    case "M3": {return 'B';}
    case "SQF": {return 'Q';}
    case "MEA": {return 'H';}
    case "(na))": {return '(';}
    case "CSM": {return 'C';}
    case "MSF": {return 'F';}
    case "ADMT": {return 'A';}
    case "GT": {return 'G';}
    case "CWT": {return 'W';}
  }
  return "";
}

String getUOM(String UOM_ID){
  switch(UOM_ID){
    case 'L': {return "LB";}
    case 'S': {return "ST";}
    case 'K': {return "KG";}
    case 'M': {return "MT";}
    case 'E': {return "EA";}
    case 'X': {return "FBM";}
    case 'B': {return "M3";}
    case 'Q': {return "SQF";}
    case 'H': {return "MEA";}
    case '(': {return "(na)";}
    case 'C': {return "CSM";}
    case 'F': {return "MSF";}
    case 'A': {return "ADMT";}
    case 'G': {return "GT";}
    case 'W': {return "CWT";}
  }
  return "";
}
double cnvDouble(String num){
  if(double.tryParse(num.replaceAll(",", "")) == null){
    return 0.0;
  }
  return double.parse(num.replaceAll(",", ""));
}

double lbsToUOM(double wt, String UOM){
  switch(UOM){
    case 'L': {return wt;}
    case 'E': {return wt;}
    case 'X': {return wt;}
    case 'S': {return wt/2000;}
    case 'T': {return wt/2000;}
    case 'K': {return wt/2.2046;}
    case 'M': {return wt/2204.6;}
    case 'A': {return wt/2204.6;}
    case 'G': {return wt/2240;}
    case 'LT': {return wt/2240;}
    case 'B': {return wt*0.0023598;}
  }
  return 0;
}

MediaQuery FixFont(BuildContext context, Widget w){
  return MediaQuery(child: w, data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),);
}

String round(String num, int decimals){
  return cnvDouble(num).toStringAsFixed(decimals);
}

double calcValue(double price, String priceUOM, double wt, String wtUOM){
  double calcPrice = price;
  double calcWt = wt;

  switch(wtUOM){
    case 'S':
      calcWt = wt*2000;
    case 'K':
      calcWt = wt*2.2046;
    case 'M':
      calcWt = wt*2204.6;
    case 'A':
      calcWt = wt*2204.6;
    case 'M':
      calcWt = wt*2204.6;
  }

  switch(priceUOM){
    case 'S':
      calcPrice = price/2000;
    case 'K':
      calcPrice = price/2.2046;
    case 'M':
      calcPrice = price/2204.6;
    case 'A':
      calcPrice = price/2204.6;
    case 'G':
      calcPrice = price/2240;
    case 'H':
      calcPrice = price/1000;
    case 'Y':
      calcPrice = price/1000;
    case 'W':
      calcWt = wt/100;
  }

  if(!['S', 'L', 'M', 'G', 'H', 'K', 'W', 'A'].contains(priceUOM)){
    calcWt = 1;
  }

  return calcWt*calcPrice;
}

Route LeftToRightRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}