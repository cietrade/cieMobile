import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'HelperFunctions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DataList extends StatefulWidget {
  final String Title;
  final String SubTitle;
  final String TotalAmt;
  final String TotalNo;
  final String backText;
  final bool showTotals;
  final bool isLoading;
  List<Widget> Tiles = [];
  final Widget btn ;
  final Function() onBack;
  final Future<void> Function() onRefresh;

  DataList({Key? key, required this.Title, required this.SubTitle, required this.btn, required this.Tiles, required this.TotalAmt, required this.TotalNo, required this.showTotals,  required this.backText, required this.isLoading, required this.onBack, required this.onRefresh,}) : super(key: key);

  @override
  State<DataList> createState() => _DataListState();
}

class _DataListState extends State<DataList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title:  Text(widget.Title, style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
        actions: [widget.btn],
        leadingWidth: MediaQuery.of(context).size.width/4,
        leading: widget.backText.isNotEmpty ? TextButton(
          onPressed: widget.onBack,
          child: Align(alignment: Alignment.centerLeft,
              child:  Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_back_ios_rounded, color: Colors.blue,), SizedBox(width: 2),
                  Text(widget.backText, softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.blue))),
                ],
              )),
        )
        : Text(""),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            color: const Color(0xFFDCDCDC),
            child: Row(
              children: [Text(widget.SubTitle, style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),))],
            )

          )
        ),
      ),
      body: widget.isLoading ?
      Center( child: CircularProgressIndicator.adaptive(),) :
        ( widget.Tiles.isNotEmpty ?
            RefreshIndicator.adaptive(
                onRefresh: widget.onRefresh,
                child: ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    children: widget.Tiles
                  ))
        : const Center(child: Text("No data found"))), //:
      bottomNavigationBar: widget.showTotals ? BottomAppBar(
        padding: EdgeInsets.only(top: 3, bottom: 3, left: 10, right: 10),
        height: 40,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        color: const Color(0xFFDCDCDC),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Items: ${widget.TotalNo}", style: GoogleFonts.lato(textStyle:  const TextStyle( fontSize: 16, color: Colors.black)),),
                Text("Total:     ${widget.TotalAmt}", style: GoogleFonts.lato(textStyle:  const TextStyle( fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF000086))),),
              ],
            ),


            //const Text(" "),
          ],
        ),
      )
      : const BottomAppBar(height: 0),
    );
  }
}

class DataListTile extends StatelessWidget {
  final String title;
  final String tail;
  final String money;
  final bool hasIcon;
  final List<String> subTitle;
  final bool isSlide;
  final Function onSlide;
  final Function() onTap;
  Divider div = const Divider(height: 1.2, color: Color(0xFFEAEAEB),);
  TextStyle titleStyle = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black));
  TextStyle tailStyle = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 15,fontWeight: FontWeight.w400, color: Colors.black, fontStyle: FontStyle.italic));
  TextStyle subTitleStyle = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 15, color: Colors.black));
  TextStyle moneyStyle = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.w700, color: Color(0xFF000086),));
  TextStyle btn = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 17,fontWeight: FontWeight.normal, color: Colors.blue));


  DataListTile({
    required this.title, required this.subTitle, required this.onTap, required this.tail, required this.money, this.hasIcon = true, this.isSlide = false, required this.onSlide
  });



  @override
  Widget build(BuildContext context) {
    List<Widget> details = [];
    for(var i = 0; i < subTitle.length; i++){
      details.add(Expanded(
        child: Text(subTitle[i], style: subTitleStyle, overflow: TextOverflow.ellipsis, textAlign: i >= 1 && money.isEmpty ? TextAlign.right : TextAlign.left))
      );
    }
    if(money.isNotEmpty){
      details.add(Expanded(
        child:Text(money, style: moneyStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,)));
    }

    return
      isSlide ?
        Slidable(
          endActionPane:  ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                flex: 2,
                onPressed: (BuildContext context){onSlide();},
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: 'Delete',
              ),
            ],

          ),
            child: ListTile(
              contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 5),
              dense: true,
              tileColor: Colors.white,
              onTap: onTap,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(flex: 6, child: Text(title, style: titleStyle, overflow: TextOverflow.ellipsis,),),
                  Expanded(flex: 4, child:Text(tail, style: money.isEmpty ? moneyStyle : tailStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end,))
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: details,
              ),
              trailing: hasIcon? const Icon(Icons.arrow_forward_ios, color: Color(0xFF8C8C8F), size: 15,) : Text(""),
            ),
        )

   : ListTile(
      contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 5),
      dense: true,
      tileColor: Colors.white,
      onTap: onTap,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 6, child: Text(title, style: titleStyle, overflow: TextOverflow.ellipsis,),),
          Expanded(flex: 4, child:Text(tail, style: money.isEmpty ? moneyStyle : tailStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end,))
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: details,
      ),
      trailing: hasIcon? const Icon(Icons.arrow_forward_ios, color: Color(0xFF8C8C8F), size: 15,) : Text(""),
    );
  }}