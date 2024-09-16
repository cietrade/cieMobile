import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:ciemobile/SettingsPage.dart';
import 'package:ciemobile/WksPage.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'Globals.dart';
import 'HelperFunctions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'DataTable.dart';
import 'OrderEditPage.dart';
import 'OrderPage.dart';
import 'Login.dart';
import 'WksPage.dart';
import 'AccountSearchPage.dart';
import 'PoWksSearchPage.dart';

class HomePage extends StatefulWidget {
  final String initReport;
  final String initCpID;
  final String initPageNm;
  final String initPO;
  final bool popPage;
  const HomePage({Key? key, this.initReport="", this.initCpID="", this.initPageNm="", this.initPO="", this.popPage = false}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Queue<Future<Widget>> _pages;
  late Queue<String> pageNames;
  late Future<Widget> _page;
  String deptID = "";
  String deptNm = "ALL DEPTS";
  String pageNm = "Home";
  String CpID = "";
  String ReportType = "";
  bool isLoading = false;
  TextStyle title = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black));
  TextStyle tail = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 15,fontWeight: FontWeight.w400, color: Colors.black, fontStyle: FontStyle.italic));
  TextStyle subTitle = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 16, color: Colors.black));
  TextStyle money = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700, color: Color(0xFF000086),));
  TextStyle btn = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 17,fontWeight: FontWeight.normal, color: Colors.blue));
  EdgeInsetsGeometry iconPad = const EdgeInsets.only(top: 2, bottom: 0, left: 0, right: 0);
  Divider div = const Divider(height: 1.2, color: Color(0xFFEAEAEB),);


//HELPER FUNCTIONS
  void setOrder(String PONumber, String pagenm){
    GetOrder(PONumber).then((value) =>
        Navigator.of(context).push(MaterialPageRoute(
            settings:   RouteSettings(name: "OrderPage_$PONumber"),
            builder: (context) => FixFont(context, value))
        ).then((value){
          refresh();
        })
    );
  }
  void setWks(String BuySellNo, String pagenm, String WksType){
    if(WksType == "CASH"){return;}
    setState(() {
      pageNm = pagenm;
      _page = GetWks(BuySellNo, WksType, pagenm);
      _pages.add(_page);
      pageNames.add("Home");
    });
  }
  
  void setTable(String reportrype, String cpid, String pagenm){
    setState(() {
      pageNm = pagenm;
      CpID = cpid;
      ReportType = reportrype;
      _page = GetData(ReportType, CpID, pageNm, pageNames.last);
      _pages.add(_page);
      pageNames.add(pagenm);
    });
  }
  Future<void> refresh() async{
    setState(() {
      _page = GetData(ReportType, CpID, pageNm, pageNames.last);
    });
  }

  void goBack(){
    setState(() {
      pageNames.removeLast();
      pageNm = pageNames.last;
      if(["Home", "A/R Summary", "Sales", "Purchases", "Sales Orders", "Purchase Orders", "Open Shipments", "Open Receiving"].contains(pageNm)){
        CpID = "";
      }
      if(pageNm == "Home"){
        ReportType = "";
      }
      _pages.removeLast();
      _page = _pages.last;
    });
    refresh();
  }

  void prevPage(){
    Navigator.of(context).pop();
    refresh();
  }

  void prevPageOrder(String CpID, String CompNm, String Source){
    Navigator.of(context).pop();
    goBack();
    setTable("OPEN${Source}", CpID, CompNm);
  }

  void setDept(String DeptNm, String DeptID){
    setState(() {
      deptNm = DeptNm;
      deptID = DeptID;
      _page = GetData("", "", "Home", "");
      _pages.removeLast();
      _pages.add(_page);
    });
  }

  void _handleTabSelection() {
    setState(() {
    });
  }

  Widget getDeptPage(Future<List<globals.SearchItem>> depts){
      return FutureBuilder(
          future: depts,
          builder: (BuildContext context, AsyncSnapshot<List<globals.SearchItem>> snapshot){
            return Scaffold(
                backgroundColor: Color(0xFFF2F4F7),
                appBar: AppBar(
                    surfaceTintColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    centerTitle: true,
                    title:  Text("Depts", style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
                    leadingWidth: MediaQuery.of(context).size.width/4,
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
                    )
                ),
              body: !snapshot.hasData ? Center( child: CircularProgressIndicator.adaptive(),) :
                  ListView.separated(
                    padding:  const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                        tileColor: Colors.white,
                        leading: snapshot.data?[index].objID == deptID ? Icon(Icons.check) : Text(""),
                        title: Text(snapshot.data![index].title),
                        onTap: (){
                          setDept(snapshot.data![index].title, snapshot.data![index].objID);
                          Navigator.of(context).pop();
                        },
                      );
                    }, separatorBuilder: (BuildContext context, int index) => div,
                  )
            );
          }
      );
  }

  //OVERRIDES
  @override
  void initState() {
    super.initState();
    if(globals.LockedDept == "1"){
      setState(() {
        deptID = globals.DefDept;
        deptNm = globals.DefDeptNm;
      });
    }

    _page = GetData("", "", "Home", "");
    _pages = Queue<Future<Widget>>();
    pageNames = Queue<String>();
    _pages.add(_page);
    pageNames.add("Home");

    if(widget.initReport.isNotEmpty){
      setTable(widget.initReport, widget.initCpID, widget.initPageNm);
    }

    if(widget.initPO.isNotEmpty){
      setOrder(widget.initPO, "");
    }

  }

  @override
  Widget build(BuildContext context) {
    TextButton btnDept = TextButton(
      onPressed: () {
        if(globals.LockedDept == "1"){
          PopUp(context, "Permissions Restriction", "This user is Department locked.");
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, getDeptPage(GetDepts()))));
        }
      },
      child: Text("Dept", style: btn,),
    );

    DataList loadingPage = DataList(Title: pageNm, SubTitle: deptNm, btn: btnDept, Tiles: [], TotalAmt: '0', TotalNo: '0', showTotals: false, backText: "", isLoading: true, onBack: () {  }, onRefresh: refresh,);

    return DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: TabBarView(
              children: [
                FutureBuilder<Widget>(
                    future: _page,
                    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if(snapshot.hasData && !isLoading){
                        Widget page = snapshot.data as Widget;
                        return page;
                      } else {
                        return loadingPage;
                      }
                    }
                )
                ,
                AccountSearchPage( objType: 'CP_SEARCH', filterValue: '', title: 'Accounts',),
                SearchPage(title: 'Search',),
                SettingsPage(refresh: refresh,),
              ]
          ),
          bottomNavigationBar:  SizedBox( height: 70, child: TabBar(
            padding: EdgeInsets.only(top: 0, bottom: 15, left: 0, right: 0),
            labelColor: Colors.black,
            unselectedLabelColor: const Color(0xFF9C9C9C),
            indicatorColor: Colors.black,
            indicatorPadding: EdgeInsets.only(top: 0, bottom: 2, left: 0, right: 0),
            indicator: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 2))),
            dividerColor: Colors.transparent,
            labelPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
            tabs: [
              Tab( text: "Home", icon: Icon(Icons.home_outlined, size: 30, ), iconMargin: iconPad,),
              Tab( text: "Accounts", icon: Icon(Icons.account_circle_outlined, size: 30, ), iconMargin: iconPad,),
              Tab( text: "Search", icon: Icon(Icons.search, size: 30, ), iconMargin: iconPad,),
              Tab( text: "Settings", icon: Icon(Icons.settings_outlined, size: 30, ), iconMargin: iconPad,),
            ],

          ),
        ))
    );
  }


  //API CALLS


  Future<List<globals.SearchItem>> GetDepts() async {
    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&ObjType=DEPT"));
    if(rep.statusCode == 200){
      List<globals.SearchItem> depts = [];
      var body = jsonDecode(rep.body);
      depts.add(globals.SearchItem(title: "ALL DEPTS", subTitle: "", objID: "",));

      for (var i = 0; i < body.length; i++) {
        depts.add(
            globals.SearchItem(
              title: body[i]["ObjNm"] == null ? "" : body[i]["ObjNm"].toString(),
              subTitle: "",
              objID: body[i]["ObjID"] == null ? "" : body[i]["ObjID"].toString(),
            )
        );
      }
      return depts;
    } else {
      return [];
    }
  }

  Future<WksPage> GetWks(String BuySellNo, String WksType, String Header ) async {
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

      return WksPage(wks: wks, onBack: goBack, wksType: WksType, header: Header,);
    }
    return WksPage(wks: globals.Worksheet(Details: []), onBack: goBack, wksType: WksType, header: Header,);
  }
  
  Future<OrderPage> GetOrder(String PONumber ) async {
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
            Ordered: body["Details"][i]["Ordered"] == null ? "" : (body["Details"][i]["Ordered"].toString().isEmpty ? "0" : body["Details"][i]["Ordered"].toString()),
            Shipped: body["Details"][i]["Shipped"] == null ? "" : (body["Details"][i]["Shipped"].toString().isEmpty ? "0" : body["Details"][i]["Shipped"].toString()),
            Opened: body["Details"][i]["Opened"] == null ? "" : (body["Details"][i]["Opened"].toString().isEmpty ? "0" : body["Details"][i]["Opened"].toString()),
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

      return OrderPage(Order: Order, onBack: prevPage,);
    }
    return OrderPage(Order: globals.Order(Details: []), onBack: prevPage,);
  }


  Future<DataList> GetData(String ReportType, String CpID, String Title, String PrevTitle) async{
    setState(() {isLoading = true;});
    Widget actionBtn = TextButton(onPressed: (){}, child: Text(""));
    List<Widget> data = [];
    double totalAmt = 0;
    int count = 0;
    String curSymbolTotal = "\$";
    String ShowDetailsOnly = widget.initCpID.isEmpty ? "1" : "0";

    TextButton btnDept = TextButton(
      onPressed: () {
        if(globals.LockedDept == "1"){
          PopUp(context, "Permissions Restriction", "This user is department locked.");
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, getDeptPage(GetDepts()))));
        }
      },
      child: Text("Dept", style: btn,),
    );

    Response rep = await get(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&COID=${deptID}&UserID=${globals.cieTradeUserID}&ReportType=${ReportType}&CpID=${CpID}&WksViewAll=${globals.isAdmin ? "1" : "0"}&OrderViewAll=${globals.isAdmin ? "1" : "0"}&UOM=${globals.UOM}&DetailsOnly=0"));
    if(rep.statusCode == 200){
      var body = jsonDecode(rep.body);
      for(var i = 0; i < body.length; i++){
        //RETURN REPORT FOR SPECIFIC COUNTERPARTY
        if(CpID.isNotEmpty){
          //Returns Datatable for specific CpID
          List<String> subTitle = [];
          String RefID = body[i]["AcctID"] == null ? "" : body[i]["AcctID"].toString();
          String HeaderLabel = body[i]["HeaderLabel"] == null ? "" : body[i]["HeaderLabel"].toString();
          String HeaderValue = body[i]["HeaderValue"] == null ? "" : body[i]["HeaderValue"].toString();
          String ColLabel01 = body[i]["ColLabel01"] == null ? "" : body[i]["ColLabel01"].toString();
          String ColValue01 = body[i]["ColValue01"] == null ? "" : body[i]["ColValue01"].toString();
          String ColLabel02 = body[i]["ColLabel02"] == null ? "" : body[i]["ColLabel02"].toString();
          String ColValue02 = body[i]["ColValue02"] == null ? "" : body[i]["ColValue02"].toString();
          String ColLabel03 = body[i]["ColLabel03"] == null ? "" : body[i]["ColLabel03"].toString();
          String ColValue03 = body[i]["ColValue03"] == null ? "" : body[i]["ColValue03"].toString();
          String DateStr = body[i]["Date"] == null ? "" : body[i]["Date"].toString();
          String DefAddr = body[i]["DefAddr"] == null ? "" : body[i]["DefAddr"].toString();
          String DefCurr = body[i]["DefCurr"] == null ? "" : body[i]["DefCurr"].toString();
          String DefDeptNm = body[i]["DefDeptNm"] == null ? "" : body[i]["DefDeptNm"].toString();
          String DefTerms = body[i]["DefTerms"] == null ? "" : body[i]["DefTerms"].toString();
          String FxRate = body[i]["FxRate"] == null ? "" : body[i]["FxRate"].toString();
          String ObjID = HeaderLabel.replaceAll("SO ", "").replaceAll("PO ", "").replaceAll("Invoice ", "").replaceAll("Wks ", "").replaceAll("Ticket ", "");

          if( HeaderValue.isNotEmpty ){
            if(double.tryParse(HeaderValue.substring(2).replaceAll(",", "")) != null) totalAmt += double.tryParse(HeaderValue.substring(2).replaceAll(",", ""))!;
          }
          //RETURN ORDER
          if(ReportType == "OPENSO" || ReportType == "OPENPO"){
            if(HeaderValue.isNotEmpty){
              if (ColLabel01.isNotEmpty) subTitle.add("${ColLabel01}\n${ ColValue01} ${getUOM(globals.UOM)}");
              if (ColLabel02.isNotEmpty) subTitle.add("${ColLabel02}\n${ ColValue02} ${getUOM(globals.UOM)}");
              if (ColLabel03.isNotEmpty) subTitle.add("${ColLabel03}\n${ ColValue03}");
              DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(DateStr);

              data.add(DataListTile(
                  title: HeaderLabel,
                  subTitle: subTitle,
                  onTap: () => {setOrder(ObjID, HeaderLabel)},
                  tail: "${DateFormat("MMM, d yyyy").format(dt)}",//tail: HeaderValue,
                  money: "")
              );
              data.add(div);
              count += 1;
            }

            String source = ReportType.replaceAll("OPEN", "");
            //MAKE CREATE NEW ORDER BTN
            actionBtn = IconButton(icon: Icon(Icons.add, color: Colors.blue,),
              onPressed: (){
                if((source == "SO" && globals.SOCreate == "0") || (source == "PO" && globals.POCreate == "0")){
                  String OrderType = source == "SO" ? "Sales Orders" : "Purchase Orders";
                  PopUp(context, "Permissions Restriction", "This user does not have permission to create ${OrderType}.");
                }
                else {
                  Navigator.of(context).push(MaterialPageRoute(
                      settings:   RouteSettings(name: "OrderPage_NEW"),
                      builder: (context) => FixFont(context,  OrderEditPage(
                        refresh: refresh,
                        Order: Order(
                          AccountName: Title,
                          CpID: CpID,
                          Status: "WORK",
                          DeptID: globals.DefDept,
                          DeptNm: globals.DefDeptNm,
                          AddrType: DefAddr,
                          Terms: DefTerms,
                          Currency: DefCurr,
                          FxRate: FxRate,
                          OrderType: "0",
                          MinWt: "0",
                          MaxWt: "0",
                          MinMaxUOM: globals.UOM,
                          PODate: DateFormat("yyyy-MM-ddT00:00:00").format(DateTime.now()),
                          Details: [],
                          Source: source))
                  ))
                  ).then((value){
                    refresh();
                  });
                }

              },
            );

          } else { //RETURN WKS
            //if (ColValue01.isNotEmpty && !HeaderLabel.contains("Wks") && !HeaderLabel.contains("Ticket")) subTitle.add(double.tryParse(ColValue01) != null ? "${ NumberFormat("###,###.##").format(cnvDouble(ColValue01))}" : ColValue01);
            if (ColValue02.isNotEmpty) subTitle.add(double.tryParse(ColValue02) != null ? "${ NumberFormat("###,###.##").format(cnvDouble(ColValue02))} ${getUOM(globals.UOM)}" : ColValue02);
            if (ColValue03.isNotEmpty) subTitle.add(double.tryParse(ColValue03) != null ? "${ NumberFormat("###,###.##").format(cnvDouble(ColValue03))} ${getUOM(globals.UOM)}" : ColValue03);

            String wksType ="";
            bool noPage = HeaderLabel.contains("Adj") || HeaderLabel.contains("Unapplied Cash");
            if(HeaderLabel.contains("Invoice")) {wksType = "INVOICE";}
            if(HeaderLabel.contains("Ticket")) {wksType = "";}
            if(HeaderLabel.contains("Unapplied Cash")){wksType = "CASH";}
            if(ReportType == "SALES"){wksType="SALE";}
            if(ReportType == "PURCHASES"){wksType="PURCHASE";}
            if(ReportType == "OPENSHIP"){wksType="OPENSHIP";}

            data.add(DataListTile(
                title: HeaderLabel,
                subTitle: subTitle,
                onTap:  noPage ? (){} : () {setWks(ObjID, HeaderLabel, wksType);},
                tail:  ColValue01 ,
                money: HeaderValue,
                hasIcon: !noPage,),

            );
            data.add(div);
            count += 1;
          }

        }//RETURN REPORT
        else if(ReportType.isNotEmpty){

          //RETURN ORDER REPORT
          if(ReportType == "OPENSO" || ReportType == "OPENPO") {

            List<String> subTitle = [];
            String AcctID = body[i]["AcctID"] == null ? "" : body[i]["AcctID"].toString();
            String HeaderLabel = body[i]["HeaderLabel"] == null ? "" : body[i]["HeaderLabel"].toString();
            String HeaderValue = body[i]["HeaderValue"] == null ? "" : body[i]["HeaderValue"].toString();
            String ColLabel01 = body[i]["ColLabel01"] == null ? "" : body[i]["ColLabel01"].toString();
            String ColValue01 = body[i]["ColValue01"] == null ? "" : body[i]["ColValue01"].toString();
            String ColLabel02 = body[i]["ColLabel02"] == null ? "" : body[i]["ColLabel02"].toString();
            String ColValue02 = body[i]["ColValue02"] == null ? "" : body[i]["ColValue02"].toString();
            String ColLabel03 = body[i]["ColLabel03"] == null ? "" : body[i]["ColLabel03"].toString();
            String ColValue03 = body[i]["ColValue03"] == null ? "" : body[i]["ColValue03"].toString();
            String ColLabel04 = body[i]["ColLabel04"] == null ? "" : body[i]["ColLabel04"].toString();
            String ColValue04 = body[i]["ColValue04"] == null ? "" : body[i]["ColValue04"].toString();

            if (ColLabel01.isNotEmpty) subTitle.add("${ColLabel01}\n${NumberFormat("###,###.##").format(cnvDouble(ColValue01))}");
            if (ColLabel02.isNotEmpty) subTitle.add("${ColLabel02}\n${NumberFormat("###,###.##").format(cnvDouble(ColValue02))} ${getUOM(globals.UOM)}");
            if (ColLabel03.isNotEmpty) subTitle.add("${ColLabel03}\n${NumberFormat("###,###.##").format(cnvDouble(ColValue03))} ${getUOM(globals.UOM)}");
            if (ColLabel04.isNotEmpty) subTitle.add("${ColLabel04}\n${NumberFormat("###,###.##").format(cnvDouble(ColValue04))}");
            if( HeaderValue.isNotEmpty ){
              if(double.tryParse(HeaderValue.substring(2).replaceAll(",", "")) != null) totalAmt += double.tryParse(HeaderValue.substring(2).replaceAll(",", ""))!;
            }
            count += 1;

            data.add(DataListTile(
                title: HeaderLabel,
                subTitle: subTitle,
                onTap: () => {setTable(ReportType, AcctID, HeaderLabel)},
                tail: HeaderValue,
                money: "")
            );
            data.add(div);
          } //RETURN WKS REPORT
          else {
            List<String> subTitle = [];
            String AcctID = body[i]["AcctID"] == null ? "" : body[i]["AcctID"].toString();
            String DetailTitle = body[i]["DetailTitle"] == null ? "" : body[i]["DetailTitle"].toString();
            String DetailTonnage = body[i]["DetailTonnage"] == null ? "" : body[i]["DetailTonnage"].toString();
            String DetailCount = body[i]["DetailCount"] == null ? "" : body[i]["DetailCount"].toString();
            String DetailCountLabel = body[i]["DetailCountLabel"] == null ? "" : body[i]["DetailCountLabel"].toString();
            String DetailValue = body[i]["DetailValue"] == null ? "" : body[i]["DetailValue"].toString();
            String DetailValueLabel = body[i]["DetailValueLabel"] == null ? "" : body[i]["DetailValueLabel"].toString();
            String CurSymbol = body[i]["CurSymbol"] == null ? "" : body[i]["CurSymbol"].toString();
            String moneyStr = "${CurSymbol} ${NumberFormat("###,###.##").format(double.parse(DetailValue))}";

            if (DetailTonnage.isNotEmpty) subTitle.add("${NumberFormat("###,###.##").format(double.parse(DetailTonnage))} ${getUOM(globals.UOM)}");
            if (DetailCount.isNotEmpty) subTitle.add("${DetailCount.trim()} ${DetailCountLabel.trim()}");
            if (DetailValue.isNotEmpty) totalAmt += double.parse(DetailValue);
            if (DetailValueLabel == "Loads") moneyStr = "${NumberFormat("###,###.##").format(double.parse(DetailValue))} Loads";
            curSymbolTotal = CurSymbol;
            count += 1;

            data.add(DataListTile(
                title: DetailTitle,
                subTitle: subTitle,
                onTap: () => {setTable(ReportType, AcctID, DetailTitle )},
                tail: "",
                money: moneyStr)
            );
            data.add(div);
          }
        } //RETURN REPORT SUMMARIES
        else {
          List<String> subTitle = [];
          String ReportType = body[i]["ReportType"] == null ? "" : body[i]["ReportType"].toString();
          String ReportTitle = body[i]["ReportTitle"] == null ? "" : body[i]["ReportTitle"].toString();
          String ReportValue = body[i]["ReportValue"] == null ? "" : body[i]["ReportValue"].toString();
          String CurSymbol = body[i]["CurSymbol"] == null ? "" : body[i]["CurSymbol"].toString();
          String ReportTonnage =  body[i]["ReportTonnage"] == null ? "" : body[i]["ReportTonnage"].toString();
          String ReportCount = body[i]["ReportCount"] == null ? "" : body[i]["ReportCount"].toString();
          String ReportCountLabel = body[i]["ReportCountLabel"] == null ? "" : body[i]["ReportCountLabel"].toString();
          String ReportValueLabel = body[i]["ReportValueLabel"] == null ? "" : body[i]["ReportValueLabel"].toString();
          String moneyStr = "${CurSymbol} ${NumberFormat("###,###.##").format(double.parse(ReportValue))}";

          if(ReportTonnage.isNotEmpty) subTitle.add("${NumberFormat("###,###.##").format(double.parse(ReportTonnage))} ${getUOM(globals.UOM)} ");
          if(ReportCount.isNotEmpty) subTitle.add("${ReportCount.trim()} ${ReportCountLabel.trim()}");
          if(ReportValueLabel == "Loads") moneyStr = "${NumberFormat("###,###.##").format(double.parse(ReportValue))}";

          data.add(DataListTile(
              title: ReportTitle,
              subTitle: subTitle,
              onTap: ()=>{setTable(ReportType, "", ReportTitle )},
              tail: ReportValueLabel,
              money: moneyStr)
          );
          data.add(div);
        }
      }
      setState(() {isLoading = false;});
      return DataList(
          Title: Title,
          SubTitle: deptNm,
          btn:  Title == "Home" ?  btnDept : actionBtn ,
          Tiles: data,
          TotalAmt: "${curSymbolTotal} ${NumberFormat("###,###.##").format(totalAmt)}",
          TotalNo: count.toString(),
          showTotals: !(count == 0),
          backText: Title == "Home" ? "" : "Back",//PrevTitle,
          isLoading: false,
          onBack: widget.popPage ? prevPage : goBack,
        onRefresh:  refresh,
      );

    } else {
      setState(() {isLoading = false;});
      return DataList(
          Title: Title,
          SubTitle: deptNm,
          btn:  Title == "Home" ?  btnDept
              : TextButton(onPressed: () {  }, child: Text("")),
          Tiles: const [],
          TotalAmt: "0",
          TotalNo: "0",
          showTotals: false,
          backText: "Back" ,
          isLoading: false,
          onBack: widget.popPage ? prevPage : goBack,
        onRefresh: refresh,
      );
    }
  }

}

