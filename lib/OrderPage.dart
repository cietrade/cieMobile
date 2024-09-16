import 'package:flutter/cupertino.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'HelperFunctions.dart' ;
import 'package:google_fonts/google_fonts.dart';
import 'HelperFunctions.dart';
import 'OrderEditPage.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class OrderPage extends StatefulWidget{
  final globals.Order Order;
  final Function() onBack;
  final popOnBack;
  OrderPage({Key? key, required this.Order, required this.onBack, this.popOnBack = false  }) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}



class _OrderPageState extends State<OrderPage> {
  EdgeInsets tilePadding = const EdgeInsets.only(top: 2, bottom: 2, left: 18, right: 10);
  Widget div = const Padding( padding: EdgeInsets.only(left: 16), child: Divider(height: 1.2, color: Color(0xFFCBCBCF),));
  Widget detailDiv = const Divider(height: 1.2, color: Color(0xFFCBCBCF),);
  Color greyFont = const Color(0xFF61676E);
  Color greyBackground = Color(0xFFE3E3E3);
  TextStyle detailSubSubTitleStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF4A5059));
  TextStyle titleStyle = const TextStyle( fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF4A5059));
  TextStyle subTitleStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  TextStyle detailTitleStyle = const TextStyle( fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF343F4B));
  TextStyle detailSubTitleStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF5A6978));
  TextStyle statusStyle =  GoogleFonts.lato( textStyle:  const TextStyle( fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF61676E)));
  TextStyle soldToStyle = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.deepOrange));
  TextStyle purchFromStyle = GoogleFonts.lato( textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green));
  TextStyle headerTitleStyle = GoogleFonts.lato( textStyle:  const TextStyle(fontSize: 19, fontWeight: FontWeight.w600));
  TextStyle headerSubTitleStyle = GoogleFonts.lato( textStyle:  const TextStyle( fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF4A5059)));
  TextStyle totalLabelStyle = GoogleFonts.lato(textStyle:  const TextStyle( fontSize: 15, color: Color(0xFF535355)));
  TextStyle totalValueStyle = GoogleFonts.lato(textStyle:  const TextStyle( fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF343F4B)));
  TextStyle orderNoStyle =  GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF61676E)));
  var fWt = NumberFormat("###,###.####", "en_US");
  var fCur = NumberFormat("###,##0.00", "en_US");
  var fUnit = NumberFormat("###,###.##", "en_US");



  Widget getDetailTile(globals.OrderDetail Detail){

    String UnitStr = "";
    if(Detail.Packaging.isNotEmpty){
      UnitStr = "${Detail.Packaging}-${fUnit.format(cnvDouble(Detail.Units))}";
    }

    return ListTile(
      contentPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 15, right: 20),
      dense: true,
      tileColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child:  Text(Detail.PODesc.isEmpty ? Detail.GradeNm : Detail.PODesc, style: detailTitleStyle, overflow: TextOverflow.ellipsis,),
          ),
         Expanded(
           flex: 4,
           child: Text("${fWt.format(cnvDouble(Detail.Price))}/${getUOM(Detail.PriceUOM)} ${Detail.CurrencyCd}", style: detailTitleStyle, textAlign: TextAlign.end,),
         )

        ],
      ),
      subtitle: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${UnitStr} ${Detail.Specifications}", style: detailSubTitleStyle,),
              Text("${fCur.format(cnvDouble(Detail.FxAmount))}", style: detailSubTitleStyle,),
            ],
          ),
          Container(height: 10,),
          Row(
            children: [
              Expanded(flex: 3, child: Text("ORDERED", style: detailSubSubTitleStyle,)),
              Expanded(flex: 3, child: Text("SHIPPED", style: detailSubSubTitleStyle,)),
              Expanded(flex: 4, child: Text("OPENED", style: detailSubSubTitleStyle,)),
            ],
          ),
          Row(
            children: [
              Expanded(flex: 3, child: Text("${fWt.format(cnvDouble(Detail.Ordered))} ${getUOM(Detail.WeightUOM)}", style: detailSubTitleStyle,)),
              Expanded(flex: 3, child: Text("${fWt.format(cnvDouble(Detail.Shipped))}", style: detailSubTitleStyle,)),
              Expanded(flex: 4, child: Text("${fWt.format(cnvDouble(Detail.Opened))}", style: detailSubTitleStyle,)),
            ],
          )
        ],
      ),
    );
  }

  Widget getFieldTile(Text title, Text value){
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 10, bottom: 10, right: 20),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [title, value],
      ),
    );
  }

  showEmailDialog(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    _emailController.text = widget.Order.RemitEmail;
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel", style:GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF676769)) ),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Send", style:GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF676769)),),
      onPressed:  () {
        if(_emailController.text.isNotEmpty){
          SendDoc("${_emailController.text}");
          Navigator.of(context).pop();
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: Center(child:Text("Send Email", style: GoogleFonts.lato(fontSize: 23, fontWeight: FontWeight.w700, color: Color(0xFF676769)),)),
      content: Container(
        height: 100,
        child: Column(
          children: [
            Center(child: Text("Send Order Document to:", style: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF676769)),),),
            Text(" "),
            TextField(
              controller: _emailController,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFFBEBEC2)),
                contentPadding: const EdgeInsets.only(top: 3, bottom: 3, right: 10, left: 10),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4D4D4)),
                ),
              ),),
          ],
        ),
      ),
      actions: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              cancelButton,
              continueButton,
            ])
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> body = [];
    List<Widget> details = [];
    String strPoDate = "";
    String strSchDate = "";
    String strExpDate = "";

    //Format Date Str
    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(widget.Order.PODate) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(widget.Order.PODate);
      strPoDate = "${DateFormat("MMM, d yyyy").format(dt)}";
    }
    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(widget.Order.ScheduleDt) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(widget.Order.ScheduleDt);
      strSchDate = "${DateFormat("MMM, d yyyy").format(dt)}";
    }

    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(widget.Order.ExpirationDt) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(widget.Order.ExpirationDt);
      strExpDate = "${DateFormat("MMM, d yyyy").format(dt)}";
    }

    //Create PO Detail tiles
    for(var i = 0; i < widget.Order.Details.length; i++){
      details.add(getDetailTile(widget.Order.Details[i]));
      details.add(detailDiv);
    }

    body.add(
      Container(
        decoration:  BoxDecoration(color: greyBackground, border: const Border(top: BorderSide(width: 1, color: Color(0xFFD4D4D4)))),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 15.0),
        //height: 120,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text("${widget.Order.AccountName}" , overflow: TextOverflow.ellipsis, style: headerTitleStyle),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${widget.Order.AddrType}", textAlign: TextAlign.right, style: headerSubTitleStyle),
                    Text("${widget.Order.Status}", textAlign: TextAlign.right, style: GoogleFonts.lato( textStyle:   TextStyle(color: widget.Order.Status == "OPEN" || widget.Order.Status == "WORK" ? Colors.green.shade900: Colors.deepOrange )))
                  ],),
              ),


            ]),
      ),
    );
    body.add(
      getFieldTile(
          Text("Order Date", overflow: TextOverflow.ellipsis, style: titleStyle),
          Text(strPoDate, overflow: TextOverflow.ellipsis, style: subTitleStyle)
      ),
    );
    body.add(div);
    if(strSchDate.isNotEmpty){
      body.add(getFieldTile(
          Text("Scheduled Date", overflow: TextOverflow.ellipsis, style: titleStyle),
          Text(strSchDate, overflow: TextOverflow.ellipsis, style: subTitleStyle)
      ));
      body.add(div);
    }
    if(strExpDate.isNotEmpty){
      body.add(getFieldTile(
          Text("Expiration Date", overflow: TextOverflow.ellipsis, style: titleStyle),
          Text(strExpDate, overflow: TextOverflow.ellipsis, style: subTitleStyle)
      ));
      body.add(div);
    }

    body.add(getFieldTile(
      Text("Reference", overflow: TextOverflow.ellipsis, style: titleStyle),
      Text(widget.Order.Reference, overflow: TextOverflow.ellipsis, style: subTitleStyle)
    ));
    body.add(div);
    body.add(getFieldTile(
      Text("Payment Terms", overflow: TextOverflow.ellipsis, style: titleStyle),
      Text(widget.Order.Terms, overflow: TextOverflow.ellipsis, style: subTitleStyle)
    ));
    body.add(div);
    body.add(getFieldTile(
      Text("Shipping Terms", overflow: TextOverflow.ellipsis, style: titleStyle),
      Text(widget.Order.PriceBasis, overflow: TextOverflow.ellipsis, style: subTitleStyle)
    ));
    body.add(div);
    body.add(getFieldTile(
      Text("Ship Via", overflow: TextOverflow.ellipsis, style: titleStyle),
      Text(widget.Order.ShipVia, overflow: TextOverflow.ellipsis, style: subTitleStyle)
    ));
    body.add(div);
    body.add(getFieldTile(
        Text("Sales Rep", overflow: TextOverflow.ellipsis, style: titleStyle),
        Text(widget.Order.RepName1, overflow: TextOverflow.ellipsis, style: subTitleStyle)
    ));
    body.add(div);
    body.add(
      Container(
        padding: EdgeInsets.only(left: 16, top: 10, bottom: 10, right: 20),
        height: 130,
        child:
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SHIP TO", style: detailSubSubTitleStyle,),
              Expanded(child: Text(widget.Order.ShipToAddress, style: subTitleStyle, ))
            ]
        ),
      ),
    );
    body.add(
      Container(
        decoration: BoxDecoration(color: greyBackground, border: const Border(top: BorderSide(width: 1, color: Color(0xFFE3E3E3)))),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 5.0),
      ),
    );
    body.add(Column(children: details,));

    //Return Page
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
              tooltip: "Edit Order",
              onPressed: ()=>{
                if((widget.Order.Source == "SO" && globals.SOEdit == "0") || (widget.Order.Source == "PO" && globals.POEdit == "0") ) {
                  PopUp(context, "Permissions Restriction", "User does not have permission to edit ${widget.Order.Source == "SO" ? "Sales Orders" : "Purchase Orders"}.")
                } else if(globals.SOEdit == "2" && widget.Order.UserID != globals.cieTradeUserID) {
                  PopUp(context, "Permissions Restriction", "User only has permission to edit their own orders.")
                }
                else {
                  Navigator.of(context).push(MaterialPageRoute(
                      settings:   RouteSettings(name: "OrderEdit_${widget.Order.PONumber}"),
                      builder: (context) => FixFont(context, OrderEditPage(refresh: (){}, Order: widget.Order,)))
                  )
                }

              },
              icon: Icon(Icons.edit_outlined, color: Colors.blue,)),
              IconButton(
              tooltip: "Send Email",
              onPressed: ()=>{
                if((widget.Order.Source == "SO" && globals.SOEmail == "0") || (widget.Order.Source == "PO" && globals.POEmail == "0") ) {
                  PopUp(context, "Permissions Restriction", "User does not have permission to email ${widget.Order.Source == "SO" ? "Sales Orders" : "Purchase Orders"} documents.")
                }
                else {
                  SendDoc(widget.Order.RemitEmail)
                }

              },  //showEmailDialog(context)},
              icon: Icon(Icons.attach_email_outlined, color: Colors.blue,)),
/*
          TextButton(
              onPressed: ()=>{
                Navigator.of(context).push(MaterialPageRoute(
                  settings:   RouteSettings(name: "OrderEdit_${widget.Order.PONumber}"),
                    builder: (context) => OrderEditPage(Order: widget.Order,))
                )
              },
              child:  Text("Edit", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.blue))),
          )*/
        ],
        title:  Text("${widget.Order.Source.trim()}# ${widget.Order.PONumber}", style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
          leadingWidth: MediaQuery.of(context).size.width/4,
          leading: TextButton(
            onPressed: widget.popOnBack ? Navigator.of(context).pop :  widget.onBack,
            child: Align(alignment: Alignment.centerLeft,
                child:  Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_back_ios_rounded, color: Colors.blue,), SizedBox(width: 2),
                    Text("Back", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.lightBlue))),
                  ],
                )),
          )
      ),
      body: ListView(children: body,),
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 20),
          height: 65,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          color: greyBackground,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text("Total Order Value ${widget.Order.Details.isNotEmpty ? widget.Order.Details[0].CurrencyCd : ""}", style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text("${ NumberFormat("###,##0.00").format(cnvDouble(widget.Order.TotalAmt.replaceAll(",", "")))}", textAlign: TextAlign.right, style: totalValueStyle,),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text("Total Quantity ${getUOM(widget.Order.Details.length > 0 ? widget.Order.Details[0].WeightUOM : widget.Order.MinMaxUOM)}", style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(fWt.format(cnvDouble(widget.Order.TotalWt.replaceAll(",", ""))), textAlign: TextAlign.right, style: totalValueStyle,),
                  )
                ],
              )

            ],
          ),
        )
    );
  }
  void SendDoc(String email ) async {
    Response rep = await get(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileSendOrderEmail?User=${globals.userID}&Pswd=${globals.userPswd}&PONo=${widget.Order.PONumber}&Source=${widget.Order.Source}&Emails=${Email}"));
    if(rep.statusCode != 200){
      PopUp(context, "Error", "Document generation failed");
    } else {
      var body = jsonDecode(rep.body);
      String FileNm = body["FileNm"] == null ? "" : body["FileNm"].toString();
      String FileData = body["FileData"] == null ? "" : body["FileData"].toString();
      PdfDocument pdf = PdfDocument.fromBase64String(FileData);
      List<int> bytes =await pdf.save();
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String path = appDocDirectory.path;
      File('${path}/${FileNm}').writeAsBytes(bytes);
      final Email emailObj = Email(
        body: '',
        subject: FileNm,
        recipients: [email],
        cc: [''],
        bcc: [''],
        attachmentPaths: ['${path}/${FileNm}'],
        isHTML: false,
      );
      try{
        await FlutterEmailSender.send(emailObj);
      } catch(e){
        PopUp(context, "Error", e.toString());
      }

    }
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

      return OrderPage(Order: Order, onBack:  (){ Navigator.of(context).pop();},);
    }
    return OrderPage(Order: globals.Order(Details: []), onBack: (){ Navigator.of(context).pop();},);
  }

}