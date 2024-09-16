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
import 'package:alphabetical_scroll/alphabetical_scroll.dart';


class AccountSearchPage extends StatefulWidget{
  String filterValue = "";
  String objType = "";
  String title = "";
  AccountSearchPage({ required this.objType, required this.filterValue, required this.title});

  @override
  State<AccountSearchPage> createState() => _AccountSearchPageState();
}

class _AccountSearchPageState extends State<AccountSearchPage> {
  final _controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Material> tiles = [];
  List<globals.SearchItem> items = [];
  List<String> names = [];
  TextStyle titleStyle = GoogleFonts.lato( textStyle:const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black));
  bool isLoading = false;
  Border tileBorder = const Border(
    top: BorderSide(color: Color(0xFFDEDEDE), width: 0.5),
    bottom: BorderSide(color: Color(0xFFDEDEDE), width: 0),
    left: BorderSide(color: Color(0xFFDEDEDE), width: 1),
    right: BorderSide(color: Color(0xFFDEDEDE), width: 1),
  );
  Border alphaBorder = const Border(
    top: BorderSide(color: Color(0xFFDEDEDE), width: 0.5),
    bottom: BorderSide(color: Color(0xFFDEDEDE), width: 0),
    left: BorderSide(color: Color(0xFFDEDEDE), width: 0),
    right: BorderSide(color: Color(0xFFDEDEDE), width: 0),
  );
  void _onBack(){
    Navigator.of(context).pop();
  }

  Future<List<Material>> getData() async{
    setState(() {isLoading = true;});
    List<Material> tileData = [];
    List<globals.SearchItem> itemData = [];
    List<String> nameData = [];
    if(items.isNotEmpty){
      for(var i = 0; i < items.length; i++){
        if(items[i].title.toUpperCase().startsWith(_controller.text.toUpperCase()) || _controller.text.isEmpty){
          tileData.add(
              Material(child:  ListTile(
                visualDensity: VisualDensity(vertical: -3),
                tileColor: Colors.white,
                title: Text(items[i].title, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),),
                //subtitle: Text(item.subTitle, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)),),
                onTap: () {OpenAccountPage(items[i].objID);},
                shape: tileBorder,
              ))
          );
        }
      }
      setState(() {
        tiles = tileData;
        isLoading = false;
      });
      return tileData;
    } else {
      Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=${widget.objType}&ObjID=${_controller.text}"));
      if(rep.statusCode == 200){
        var body = jsonDecode(rep.body);
        for(var i = 0; i < body.length; i++){
          globals.SearchItem item = globals.SearchItem(
            title: body[i]["CompanyNm"] == null ? "" : body[i]["CompanyNm"].toString(),
            subTitle: body[i]["Contact"] == null ? "" : body[i]["Contact"].toString(),
            objID: body[i]["CpID"] == null ? "" : body[i]["CpID"].toString(),
          );
          itemData.add(item);
          tileData.add(
              Material(child:  ListTile(
                visualDensity: VisualDensity(vertical: -3),
                tileColor: Colors.white,
                title: Text(item.title, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),),
                //subtitle: Text(item.subTitle, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)),),
                onTap: () {OpenAccountPage(item.objID);},
                shape: tileBorder,
              ))
          );
          nameData.add(item.title);
        }
        setState(() {
          tiles = tileData;
          items = itemData;
          names = nameData;
          isLoading = false;
        });

        return tileData;

      } else {
        return [];
      }
    }

  }

  void OpenAccountPage(String CpID){
    Future<AccountPage> page = GetAccount(CpID);
    page.then((value) => {
      Navigator.of(context).push(MaterialPageRoute(
          settings:   RouteSettings(name: "AccountPage_$CpID"),
          builder: (context) =>
              FixFont(context, value)
      )
      )
    });
  }

  Future<AccountPage> GetAccount(String CpID) async {
    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&ObjID=${CpID}&ObjType=CPID_SEARCH&ObjID2=${globals.cieTradeUserID}"));
    if(rep.statusCode == 200){
      List<globals.WksDetail> details = [];
      var body = jsonDecode(rep.body);
      globals.Counterparty cp = globals.Counterparty(
        CompanyNm: body["CompanyNm"] == null ? "" : body["CompanyNm"].toString(),
        CpID: body["CpID"] == null ? "" : body["CpID"].toString(),
        Role: body["Role"] == null ? "" : body["Role"].toString(),
        VendorNo: body["VendorNo"] == null ? "" : body["VendorNo"].toString(),
        CurrCode: body["CurrCode"] == null ? "" : body["CurrCode"].toString(),
        GroupNm: body["GroupNm"] == null ? "" : body["GroupNm"].toString(),
        ActiveStatus: body["ActiveStatus"] == null ? "" : body["ActiveStatus"].toString(),
        Addr1: body["Addr1"] == null ? "" : body["Addr1"].toString(),
        Addr2: body["Addr2"] == null ? "" : body["Addr2"].toString(),
        Addr3: body["Addr3"] == null ? "" : body["Addr3"].toString(),
        City: body["City"] == null ? "" : body["City"].toString(),
        Region: body["Region"] == null ? "" : body["Region"].toString(),
        PostalCd: body["PostalCd"] == null ? "" : body["PostalCd"].toString(),
        Country: body["Country"] == null ? "" : body["Country"].toString(),
        Contact: body["Contact"] == null ? "" : body["Contact"].toString(),
        Telephone: body["Telephone"] == null ? "" : body["Telephone"].toString(),
        Email: body["Email"] == null ? "" : body["Email"].toString(),
        WebSite: body["WebSite"] == null ? "" : body["WebSite"].toString(),
        CreditLimit: body["CreditLimit"] == null ? "" : body["CreditLimit"].toString(),
        OnHold: body["OnHold"] == null ? "" : body["OnHold"].toString(),
        ActiveCreditProtocolID: body["ActiveCreditProtocolID"] == null ? "" : body["ActiveCreditProtocolID"].toString(),
        APContact: body["APContact"] == null ? "" : body["APContact"].toString(),
        APVoiceNo: body["APVoiceNo"] == null ? "" : body["APVoiceNo"].toString(),
        Terms: body["Terms"] == null ? "" : body["Terms"].toString(),
        SupplierGL: body["SupplierGL"] == null ? "" : body["SupplierGL"].toString(),
        VendorGL: body["VendorGL"] == null ? "" : body["VendorGL"].toString(),
        ReverseBilling: body["ReverseBilling"] == null ? "" : body["ReverseBilling"].toString(),
        CycleName: body["CycleName"] == null ? "" : body["CycleName"].toString(),
        BillOn: body["BillOn"] == null ? "" : body["BillOn"].toString(),
        StatementType: body["StatementType"] == null ? "" : body["StatementType"].toString(),
        UserDefined1: body["UserDefined1"] == null ? "" : body["UserDefined1"].toString(),
        UserDefined2: body["UserDefined2"] == null ? "" : body["UserDefined2"].toString(),
        UserDefined3: body["UserDefined3"] == null ? "" : body["UserDefined3"].toString(),
        UserDefined4: body["UserDefined4"] == null ? "" : body["UserDefined4"].toString(),
        IndustryNm: body["IndustryNm"] == null ? "" : body["IndustryNm"].toString(),
        SCAC: body["SCAC"] == null ? "" : body["SCAC"].toString(),
        DistributionMode: body["DistributionMode"] == null ? "" : body["DistributionMode"].toString(),
        SalesRep: body["SalesRep"] == null ? "" : body["SalesRep"].toString(),
        DefSalesRep: body["DefSalesRep"] == null ? "" : body["DefSalesRep"].toString(),
        Notes: body["Notes"] == null ? "" : body["Notes"].toString(),
        TotalInvoices: body["TotalInvoices"] == null ? "" : body["TotalInvoices"].toString(),
        TotalSales: body["TotalSales"] == null ? "" : body["TotalSales"].toString(),
        TotalPurch: body["TotalPurch"] == null ? "" : body["TotalPurch"].toString(),
        TotalSO: body["TotalSO"] == null ? "" : body["TotalSO"].toString(),
        TotalPO: body["TotalPO"] == null ? "" : body["TotalPO"].toString(),
        IsIntercompany: body["IsIntercompany"] == null ? "" : body["IsIntercompany"].toString(),
      );
      if(cp.IsIntercompany == "False") {cp.IsIntercompany = "0";}
      if(cp.IsIntercompany == "True") {cp.IsIntercompany = "1";}
      return  AccountPage(account: cp, onBack: _onBack,);
    }
    return  AccountPage(account: new globals.Counterparty(), onBack: _onBack,);
  }

  @override
  void initState() {
    super.initState();
    getData() ;
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
          leading: Text(""),
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
                    getData();
                  } ,
                  //onTap: () {_data = getData();  },
                  onChanged: (_) {getData(); },
                )),
          ),
        ),
        body: isLoading ? Center( child: CircularProgressIndicator.adaptive(),) :
        (
          _controller.text.isNotEmpty ? ListView(scrollDirection: Axis.vertical, shrinkWrap: true, children: tiles) :
          AlphabetListScreen<globals.SearchItem>(
            alphabetBarItemHeight: 18,
            isBorderedAlphabetBar: false,
            isHeaderShown: true,
            contactItemHeight: 40,
              sources: items,
              sourceFilterItemList: items.map((e) => e.title).toList(),
              itemBuilder: (context, item){
                return ListTile(
                  title: Text(item.title, overflow: TextOverflow.ellipsis, style: titleStyle,),
                  dense: true,
                  tileColor: Colors.white,
                );
                },
              onTap: (item){OpenAccountPage(item.objID);},
              listScrollController: scrollController
          )
          /*AlphabetScrollView(
            itemExtent: 70,//items.length.toDouble(),
            itemBuilder: (_, k, id) {

              return  Material(child:  ListTile(
                //visualDensity: VisualDensity(vertical: -3),
                dense: true,
                tileColor: Colors.white,
                title: Text(items[k].title, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),),
                //subtitle: Text(items[k].subTitle, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)),),
                onTap: () {OpenAccountPage(items[k].objID);  },
                shape: tileBorder,
              ));
            },
            selectedTextStyle: GoogleFonts.lato( textStyle:  const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 17 )),
            unselectedTextStyle: GoogleFonts.lato( textStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
            list: names.map((e) => AlphaModel(e)).toList(),
          )*/
        )
          //

      /*   */
    );
  }
}
