import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'HelperFunctions.dart' ;
import 'package:google_fonts/google_fonts.dart';
import 'OrderPage.dart';
import 'WksPage.dart';
import 'HelperFunctions.dart';
import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';

class SearchPage extends StatefulWidget{
  String title = "";
  SearchPage({super.key,  required this.title});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _txtController = TextEditingController();
  String searchType = "ALL_SEARCH";
  bool isLoading = false;
  List<Material> tiles = [];
  List<globals.SearchItem> items = [];
  List<bool> isSelected = [true, false, false, false];
  List<String> searches = ["ALL_SEARCH", "WKS_SEARCH",  "RELNO_SEARCH","ORDER_SEARCH", ];
  Border tileBorder = const Border(
    top: BorderSide(color: Color(0xFFDEDEDE), width: 0.5),
    bottom: BorderSide(color: Color(0xFFDEDEDE), width: 0),
    left: BorderSide(color: Color(0xFFDEDEDE), width: 1),
    right: BorderSide(color: Color(0xFFDEDEDE), width: 1),
  );



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
                  controller: _txtController,
                  suffixMode: OverlayVisibilityMode.always,
                  onSuffixTap: (){
                    _txtController.text = "";
                    FocusManager.instance.primaryFocus?.unfocus();
                    getData();
                  } ,
                  //onSubmitted: runSearch,
                  onChanged: (_) {getData(); },
                )),
          ),
        ),
        body: SingleChildScrollView(child:
          Column(children: [
            ToggleButtons(
              constraints: BoxConstraints(
                  minHeight: 40,
                  minWidth: MediaQuery.of(context).size.width /4,),
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelected[buttonIndex] = !isSelected[buttonIndex];
                      searchType = searches[buttonIndex];
                      getData();
                    } else {
                      isSelected[buttonIndex] = false;
                    }
                  }
                });
              },
              isSelected: isSelected,
              selectedColor: Colors.amber,
              renderBorder: false,
              fillColor: Colors.transparent,
              children: [
                CustomIcon(title: "All", isSelected: isSelected[0],),
                CustomIcon(title: "Worksheet", isSelected: isSelected[1],),
                CustomIcon(title: "Release", isSelected: isSelected[2],),
                CustomIcon(title: "Order", isSelected: isSelected[3],),

              ],
            ),
            isLoading ?
              Center( child: CircularProgressIndicator.adaptive(),) :
              ListView(scrollDirection: Axis.vertical, shrinkWrap: true, children: tiles, physics: const ScrollPhysics(), ),
          ],)
        )
      /*   */
    );
  }


//WIDGET FUNCTIONS


  Material getTile(globals.SearchItem item, Function onTap){
    return  Material(child: ListTile(
      visualDensity: VisualDensity(vertical: -3),
      tileColor: Colors.white,
      title: Row(children: [
        Expanded(flex: 2, child:Text("${item.title}", overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),)),
        Expanded(flex: 10, child: Text("${item.subTitle}", overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF5F656B))),))
      ],) ,
      //subtitle: Text(item.subTitle, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)),),
      onTap: (){onTap(item.objID);},
      shape: tileBorder,
    ));
  }

  //HELPER FUNCTIONS
  void _onBack(){
    Navigator.of(context).pop();
  }

  void openOrder(String PONumber){
    setState(() {isLoading = true;});
    Future<OrderPage> page = getOrder(PONumber);
    page.then((value) => {
      setState(() {isLoading = false;}),
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, value)))
    });
  }

  void openWks(String BuySellNo){
    setState(() {isLoading = true;});
    Future<WksPage> page = getWks(BuySellNo, "", "Wks No. ${BuySellNo}");
    page.then((value) => {
      setState(() {isLoading = false;}),
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, value)))
    });
  }

  //API CALLS
  Future<List<Material>> getData() async {

    if(_txtController.text.isEmpty){
      setState(() {
        tiles = [];
        items = [];
      });
      return [];
    }

    setState(() {isLoading = true;});

    List<Material> tileData = [];
    List<globals.SearchItem> itemData = [];
    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=${searchType}&ObjID=${_txtController.text}&UserID=${globals.cieTradeUserID}"));
    if (rep.statusCode == 200) {
      var body = jsonDecode(rep.body);
      for (var i = 0; i < body.length; i++) {
        globals.SearchItem item = globals.SearchItem(
          title: body[i]["ObjNm"] == null ? "" : body[i]["ObjNm"].toString(),
          subTitle: body[i]["ObjID2"] == null ? "" : body[i]["ObjID2"].toString(),
          objID: body[i]["ObjID"] == null ? "" : body[i]["ObjID"].toString(),
        );
        if(item.subTitle.isEmpty){item.subTitle = item.objID;}
        itemData.add(item);

        if (item.title == "PO" || item.title == "SO" ) {
          tileData.add(getTile(item, openOrder));
        } else {
          tileData.add(getTile(item, openWks));
        }

      }
      setState(() {
        tiles = tileData;
        items = itemData;
        isLoading = false;
      });

      return tileData;
    } else {
      setState(() {isLoading = false;});
      return [];
    }
  }

  Future<WksPage> getWks(String BuySellNo, String WksType, String Header ) async {
    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&ObjID=${BuySellNo}&ObjType=WKS"));
    if(rep.statusCode == 200){
      List<globals.WksDetail> details = [];
      var body = jsonDecode(rep.body);
      for(var i = 0; i < body["Details"].length; i++) {
        details.add(
            globals.WksDetail(
                ProductDesc: body["Details"][i]["ProductDesc"] == null ? "" : body["Details"][i]["ProductDesc"].toString(),
                UnitDesc: body["Details"][i]["UnitDesc"] == null ? "" : body["Details"][i]["UnitDesc"].toString(),
                PQuantityDesc: body["Details"][i]["PQuantityDesc"] == null ? "" : body["Details"][i]["PQuantityDesc"].toString(),
                PPrice: body["Details"][i]["PPrice"] == null ? "" : body["Details"][i]["PPrice"].toString(),
                PExtension: body["Details"][i]["PExtension"] == null ? "" : body["Details"][i]["PExtension"].toString(),
                SQuantityDesc: body["Details"][i]["SQuantityDesc"] == null ? "" : body["Details"][i]["SQuantityDesc"].toString(),
                SPrice: body["Details"][i]["SPrice"] == null ? "" : body["Details"][i]["SPrice"].toString(),
                SExtension: body["Details"][i]["SExtension"] == null ? "" : body["Details"][i]["SExtension"].toString(),
                Specifications: body["Details"][i]["Specifications"] == null ? "" : body["Details"][i]["Specifications"].toString()
            )
        );
      }

      globals.Worksheet wks = globals.Worksheet(
        Details: details,
        BuySellNo: body["BuySellNo"] == null ? "" : body["BuySellNo"].toString(),
        DeptNm: body["DeptNm"] == null ? "" : body["DeptNm"].toString(),
        TradeType: body["TradeType"] == null ? "" : body["TradeType"].toString(),
        PostingDt: body["PostingDt"] == null ? "" : body["PostingDt"].toString(),
        ShipDt: body["ShipDt"] == null ? "" : body["ShipDt"].toString(),
        OrderRef: body["OrderRef"] == null ? "" : body["OrderRef"].toString(),
        ReleaseNo: body["ReleaseNo"] == null ? "" : body["ReleaseNo"].toString(),
        BookingNo: body["BookingNo"] == null ? "" : body["BookingNo"].toString(),
        EndUserNm: body["EndUserNm"] == null ? "" : body["EndUserNm"].toString(),
        SalesRepNm: body["SalesRepNm"] == null ? "" : body["SalesRepNm"].toString(),
        Delivery: body["Delivery"] == null ? "" : body["Delivery"].toString(),
        PaymentTerms: body["PaymentTerms"] == null ? "" : body["PaymentTerms"].toString(),
        DueDate: body["DueDate"] == null ? "" : body["DueDate"].toString(),
        SoldToCompany: body["SoldToCompany"] == null ? "" : body["SoldToCompany"].toString(),
        SoldToAddress: body["SoldToAddress"] == null ? "" : body["SoldToAddress"].toString(),
        ShipToCompany: body["ShipToCompany"] == null ? "" : body["ShipToCompany"].toString(),
        ShipToAddress: body["ShipToAddress"] == null ? "" : body["ShipToAddress"].toString(),
        TaxCodeNm: body["TaxCodeNm"] == null ? "" : body["TaxCodeNm"].toString(),
        CurrencyCd: body["CurrencyCd"] == null ? "" : body["CurrencyCd"].toString(),
        FxInvoiceAmt: body["FxInvoiceAmt"] == null ? "" : body["FxInvoiceAmt"].toString(),
        FxTaxAmount: body["FxTaxAmount"] == null ? "" : body["FxTaxAmount"].toString(),
        FxInvoiceTotal: body["FxInvoiceTotal"] == null ? "" : body["FxInvoiceTotal"].toString(),
        FxPayments: body["FxPayments"] == null ? "" : body["FxPayments"].toString(),
        FxBalanceDue: body["FxBalanceDue"] == null ? "" : body["FxBalanceDue"].toString(),
        SoldToAddrType: body["SoldToAddrType"] == null ? "" : body["SoldToAddrType"].toString(),
        SoldFromCompany: body["SoldFromCompany"] == null ? "" : body["SoldFromCompany"].toString(),
        SoldFromAddress: body["SoldFromAddress"] == null ? "" : body["SoldFromAddress"].toString(),
        SoldFromAddrType: body["SoldFromAddrType"] == null ? "" : body["SoldFromAddrType"].toString(),
        ShipFromCompany: body["ShipFromCompany"] == null ? "" : body["ShipFromCompany"].toString(),
        ShipFromAddress: body["ShipFromAddress"] == null ? "" : body["ShipFromAddress"].toString(),
        PickUpNo: body["PickUpNo"] == null ? "" : body["PickUpNo"].toString(),
        PO: body["PO"] == null ? "" : body["PO"].toString(),
        SO: body["SO"] == null ? "" : body["SO"].toString(),
        Status: body["Status"] == null ? "" : body["Status"].toString(),
        TotalWt: body["TotalWt"] == null ? "" : body["TotalWt"].toString(),
        TotalWtUOM: body["TotalWtUOM"] == null ? "" : body["TotalWtUOM"].toString(),
        OrderDt: body["OrderDt"] == null ? "" : body["OrderDt"].toString(),
        Sales: body["Sales"] == null ? "" : body["Sales"].toString(),
        Purchases: body["Purchases"] == null ? "" : body["Purchases"].toString(),
        Expenses: body["Expenses"] == null ? "" : body["Expenses"].toString(),
        GrossProfit: body["GrossProfit"] == null ? "" : body["GrossProfit"].toString(),
        OrderDtLbl: body["OrderDtLbl"] == null ? "" : body["OrderDtLbl"].toString(),

      );

      return WksPage(wks: wks, onBack: _onBack, wksType: WksType, header: Header,);
    }
    return WksPage(wks: globals.Worksheet(Details: []), onBack: _onBack, wksType: WksType, header: Header,);
  }

  Future<OrderPage> getOrder(String PONumber ) async {
    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&ObjID=${PONumber}&ObjType=PO"));
    if(rep.statusCode == 200){
      List<globals.OrderDetail> details = [];
      var body = jsonDecode(rep.body);
      for(var i = 0; i < body["Details"].length; i++) {
        details.add(
            globals.OrderDetail(
              PODetailID: body["Details"][i]["PODetailID"] == null ? "" : body["Details"][i]["PODetailID"].toString(),
              GradeID: body["Details"][i]["GradeID"] == null ? "" : body["Details"][i]["GradeID"].toString(),
              GradeNm: body["Details"][i]["GradeNm"] == null ? "" : body["Details"][i]["GradeNm"].toString(),
              OrderNo: body["Details"][i]["OrderNo"] == null ? "" : body["Details"][i]["OrderNo"].toString(),
              PODesc: body["Details"][i]["PODesc"] == null ? "" : body["Details"][i]["PODesc"].toString(),
              Specifications: body["Details"][i]["Specifications"] == null ? "" : body["Details"][i]["Specifications"].toString(),
              Weight: body["Details"][i]["Weight"] == null ? "" : body["Details"][i]["Weight"].toString(),
              WeightUOM: body["Details"][i]["WeightUOM"] == null ? "" : body["Details"][i]["WeightUOM"].toString(),
              Packaging: body["Details"][i]["Packaging"] == null ? "" : body["Details"][i]["Packaging"].toString(),
              UnitTypeID: body["Details"][i]["UnitTypeID"] == null ? "" : body["Details"][i]["UnitTypeID"].toString(),
              Units: body["Details"][i]["Units"] == null ? "" : body["Details"][i]["Units"].toString(),
              Price: body["Details"][i]["Price"] == null ? "" : body["Details"][i]["Price"].toString(),
              PriceUOM: body["Details"][i]["PriceUOM"] == null ? "" : body["Details"][i]["PriceUOM"].toString(),
              FxAmount: body["Details"][i]["FxAmount"] == null ? "" : body["Details"][i]["FxAmount"].toString(),
              CurrencyCd: body["Details"][i]["CurrencyCd"] == null ? "" : body["Details"][i]["CurrencyCd"].toString(),
              Amount: body["Details"][i]["Amount"] == null ? "" : body["Details"][i]["Amount"].toString(),
              Ordered: body["Details"][i]["Ordered"] == null ? "" : body["Details"][i]["Ordered"].toString(),
              Shipped: body["Details"][i]["Shipped"] == null ? "" : body["Details"][i]["Shipped"].toString(),
              Opened: body["Details"][i]["Opened"] == null ? "" : body["Details"][i]["Opened"].toString(),
              LinkedWks: body["Details"][i]["LinkedWks"] == null ? "" : body["Details"][i]["LinkedWks"].toString(),
            )
        );
      }

      globals.Order Order = globals.Order(
        Details: details,
        PONumber: body["PONumber"] == null ? "" : body["PONumber"].toString(),
        UserID: body["UserID"] == null ? "" : body["UserID"].toString(),
        UserNm: body["UserNm"] == null ? "" : body["UserNm"].toString(),
        Source: body["Source"] == null ? "" : body["Source"].toString(),
        Reference: body["Reference"] == null ? "" : body["Reference"].toString(),
        DeptID: body["DeptID"] == null ? "" : body["DeptID"].toString(),
        DeptNm: body["DeptNm"] == null ? "" : body["DeptNm"].toString(),
        TradeType: body["TradeType"] == null ? "" : body["TradeType"].toString(),
        PODate: body["PODate"] == null ? "" : body["PODate"].toString(),
        Status: body["Status"] == null ? "" : body["Status"].toString(),
        CpID: body["CpID"] == null ? "" : body["CpID"].toString(),
        AccountName: body["AccountName"] == null ? "" : body["AccountName"].toString(),
        AddrType: body["AddrType"] == null ? "" : body["AddrType"].toString(),
        RepName1: body["RepName1"] == null ? "" : body["RepName1"].toString(),
        RepID1: body["RepID1"] == null ? "" : body["RepID1"].toString(),
        RepName2: body["RepName2"] == null ? "" : body["RepName2"].toString(),
        RepID2: body["RepID2"] == null ? "" : body["RepID2"].toString(),
        ShipToType: body["ShipToType"] == null ? "" : body["ShipToType"].toString(),
        ShipAddrType: body["ShipAddrType"] == null ? "" : body["ShipAddrType"].toString(),
        ShipToAddress: body["ShipToAddress"] == null ? "" : body["ShipToAddress"].toString(),
        ShipAddrID: body["ShipAddrID"] == null ? "" : body["ShipAddrID"].toString(),
        DestCountry: body["DestCountry"] == null ? "" : body["DestCountry"].toString(),
        DestCountryNm: body["DestCountryNm"] == null ? "" : body["DestCountryNm"].toString(),
        Terms: body["Terms"] == null ? "" : body["Terms"].toString(),
        PriceBasis: body["PriceBasis"] == null ? "" : body["PriceBasis"].toString(),
        ShipVia: body["ShipVia"] == null ? "" : body["ShipVia"].toString(),
        FxRate: body["FxRate"] == null ? "" : body["FxRate"].toString(),
        Instructions: body["Instructions"] == null ? "" : body["Instructions"].toString(),
        PrimaryLoc: body["PrimaryLoc"] == null ? "" : body["PrimaryLoc"].toString(),
        RemitEmail: body["RemitEmail"] == null ? "" : body["RemitEmail"].toString(),
        ScheduleDt: body["ScheduleDt"] == null ? "" : body["ScheduleDt"].toString(),
        ExpirationDt: body["ExpirationDt"] == null ? "" : body["ExpirationDt"].toString(),
        TotalAmt: body["TotalAmt"] == null ? "" : body["TotalAmt"].toString(),
        TotalWt: body["TotalWt"] == null ? "" : body["TotalWt"].toString(),
        Currency: body["Currency"] == null ? "" : body["Currency"].toString(),
        MinWt: body["MinWt"] == null ? "" : body["MinWt"].toString(),
        MaxWt: body["MaxWt"] == null ? "" : body["MaxWt"].toString(),
        MinMaxUOM: body["MinMaxUOM"] == null ? "" : body["MinMaxUOM"].toString(),
        OrderType: body["OrderType"] == null ? "" : body["OrderType"].toString(),
      );

      return OrderPage(Order: Order, onBack: _onBack,);
    }
    return OrderPage(Order: globals.Order(Details: []), onBack: _onBack,);
  }
}

class CustomIcon extends StatefulWidget {
  final bool isSelected;
  final String title;
   CustomIcon({super.key, this.isSelected = false, required this.title,});
  @override
  _CustomIconState createState() => _CustomIconState();
}

class _CustomIconState extends State<CustomIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
          height: 32,
          width: MediaQuery.of(context).size.width*3 /13,
          decoration: BoxDecoration(
            border: widget.isSelected ? Border.all(color: Colors.blue) : Border.all(color: const Color(0xFF5F656B)),
            color: widget.isSelected ? Colors.blue : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(15),),
          ),
          child: Center(child:  Text(widget.title, style: TextStyle(fontWeight:  FontWeight.w600, color: widget.isSelected ? Colors.white : Color(0xFF5F656B)),)),
        );

  }
}