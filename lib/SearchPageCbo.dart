import 'package:ciemobile/AccountPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'HelperFunctions.dart' ;
import 'package:google_fonts/google_fonts.dart';
import 'HelperFunctions.dart';
import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';

class SearchPageCbo extends StatefulWidget{
  String objType ;
  String objID;
  String title ;
  bool showSearch ;
  bool addBlank ;
  List<String> setList ;
  Function onClick;
  SearchPageCbo({ required this.objType,  required this.objID, required this.title, required this.onClick, required this.setList, this.showSearch = true, this.addBlank = true });

  @override
  State<SearchPageCbo> createState() => SearchPageCboState();
}
class SearchPageCboState extends State<SearchPageCbo> {
  final _controller = TextEditingController();
  late Future<Widget> _tiles ;
  Border tileBorder = const Border(
    top: BorderSide(color: Color(0xFFDEDEDE), width: 0.5),
    bottom: BorderSide(color: Color(0xFFDEDEDE), width: 0),
    left: BorderSide(color: Color(0xFFDEDEDE), width: 1),
    right: BorderSide(color: Color(0xFFDEDEDE), width: 1),
  );

  @override
  void initState() {
    super.initState();
    setState(() {_tiles = getData();});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          leadingWidth: MediaQuery.of(context).size.width/4,
          scrolledUnderElevation: 0.0,
          leading: TextButton(
              onPressed:  (){Navigator.of(context).pop();},
              child: Align(alignment: Alignment.centerLeft,
                  child:  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.arrow_back_ios_rounded, color: Colors.blue,), SizedBox(width: 2),
                      Text("Back", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.blue))),
                    ],
                  )),
          ),
          title: Text(widget.title, style:  GoogleFonts.lato( textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),),
          bottom:  PreferredSize(preferredSize: const Size.fromHeight(30.0),
            child:  Container(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: CupertinoSearchTextField(
                  controller: _controller,
                  suffixMode: OverlayVisibilityMode.always,
                  onSuffixTap: (){
                    _controller.text = "";
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {_tiles = getData();});
                  } ,
                  //onTap: () {_data = getData();  },
                  onChanged: (_) { setState(() {_tiles = getData();}); },
                )),
          ),
        ),
        body: FutureBuilder<Widget>(
          future: _tiles,
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
            return snapshot.hasData ? snapshot.data! : const Center( child: CircularProgressIndicator.adaptive(),);
          },
        )

      //

      /*   */
    );
  }


  Future<Widget> getData() async{
    List<Material> tileData = [];
    List<globals.SearchItem> itemData = [];
    List<String> nameData = [];
    if(widget.setList.isEmpty){
      Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=${widget.objType}&objID=${widget.objID}"));
      if(rep.statusCode == 200){
        var body = jsonDecode(rep.body);
        if(widget.addBlank){itemData.add(globals.SearchItem(title: "", objID: "",));}


          for(var i = 0; i < body.length; i++) {
            globals.SearchItem item = globals.SearchItem(
              title: body[i]["ObjNm"] == null ? "" : body[i]["ObjNm"].toString(),
              objID: body[i]["ObjID"] == null ? "" : body[i]["ObjID"].toString(),
            );
            itemData.add(item);
          }


      } else {
        return ListView(scrollDirection: Axis.vertical, shrinkWrap: true, children: []);
      }
    } else {
      for(var i = 0; i < widget.setList.length; i++) {
        globals.SearchItem item = globals.SearchItem(
          title: widget.setList[i],
          objID: widget.setList[i],
        );
        itemData.add(item);
      }
    }

    for(var i = 0; i < itemData.length; i++) {
      if(_controller.text == "" || itemData[i].title.toUpperCase().startsWith(_controller.text.toUpperCase())){
        tileData.add(
            Material(child:  ListTile(
              visualDensity: VisualDensity(vertical: -3),
              tileColor: Colors.white,
              title: Text(itemData[i].title, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),),
              onTap: () {widget.onClick(itemData[i]);},
              shape: tileBorder,
            ))
        );
      }
    }

    return ListView(scrollDirection: Axis.vertical, shrinkWrap: true, children: tileData);


  }
}
