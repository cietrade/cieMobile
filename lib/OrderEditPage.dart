import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'Globals.dart';
import 'HelperFunctions.dart' ;
import 'package:google_fonts/google_fonts.dart';
import 'HelperFunctions.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'HomePage.dart';
import 'SearchPageCbo.dart';
import 'OrderPage.dart';
import 'dart:math';
import 'package:flutter_slidable/flutter_slidable.dart';

class OrderEditPage extends StatefulWidget{
  final globals.Order Order;
  final Function refresh;
  OrderEditPage({Key? key, required this.Order, required this.refresh, }) : super(key: key);

  @override
  State<OrderEditPage> createState() => _OrderEditPageState();
}



class _OrderEditPageState extends State<OrderEditPage> {
  late globals.OrderDetail curDetail;
  late globals.Order curOrder;
  bool isSaving = false;
  List<String> Status = ["CANCELED", "OPEN", "REVIEW", "WORK"];
  List<String> OrderTypes = ["SPOT", "CONTRACT"];
  List<String> UOM = ["LB", "ST", "MT", "KG", "EA"];
  var fWt = NumberFormat("###,###.####", "en_US");
  var fCur = NumberFormat("###,##0.00", "en_US");
  var fUnit = NumberFormat("###,###.##", "en_US");
  EdgeInsets tilePadding = const EdgeInsets.only(left: 16, top: 0, bottom: 0, right: 10);
  EdgeInsets lblPadding = const EdgeInsets.only(top: 2, );
  Widget div = const Padding( padding: EdgeInsets.only(left: 16), child: Divider(height: 1.2, color: Color(0xFFCBCBCF),));
  Widget detailDiv = const Divider(height: 1.2, color: Color(0xFFCBCBCF),);
  Color greyFont = const Color(0xFF61676E);
  Color greyBackground = Color(0xFFE3E3E3);
  TextStyle detailSubSubTitleStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF969FAA));
  TextStyle titleStyle = const TextStyle( fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xFF4A5059));
  TextStyle subTitleStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF0F519F));
  TextStyle subTitleStyleGray = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.blueGrey);
  TextStyle detailTitleStyle = const TextStyle( fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF343F4B));
  TextStyle detailSubTitleStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF5A6978));
  TextStyle statusStyle =  GoogleFonts.lato( textStyle:  const TextStyle( fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF61676E)));
  TextStyle soldToStyle = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.deepOrange));
  TextStyle purchFromStyle = GoogleFonts.lato( textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green));
  TextStyle headerTitleStyle = GoogleFonts.lato( textStyle:  const TextStyle(fontSize: 19, fontWeight: FontWeight.w600));
  TextStyle headerSubTitleStyle = GoogleFonts.lato( textStyle:  const TextStyle( fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF5A6978)));
  TextStyle totalLabelStyle = GoogleFonts.lato(textStyle:  const TextStyle( fontSize: 15, color: Color(0xFF676769)));
  TextStyle totalValueStyle = GoogleFonts.lato(textStyle:  const TextStyle( fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF343F4B)));
  TextStyle orderNoStyle =  GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF61676E)));
  InputDecoration txtFieldDec = InputDecoration( border: InputBorder.none, );

  TextEditingController _txtLocation = TextEditingController();
  TextEditingController _txtOrderDt= TextEditingController();
  TextEditingController _txtScheduledDt= TextEditingController();
  TextEditingController _txtExpDt= TextEditingController();
  TextEditingController _txtRef= TextEditingController();
  TextEditingController _txtPayTerms= TextEditingController();
  TextEditingController _txtShipTerms= TextEditingController();
  TextEditingController _txtDept= TextEditingController();
  TextEditingController _txtTradeType= TextEditingController();
  TextEditingController _txtCurrency= TextEditingController();
  TextEditingController _txtStatus= TextEditingController();
  TextEditingController _txtShipVia= TextEditingController();
  TextEditingController _txtShipTo = TextEditingController();
  TextEditingController _txtOrderType= TextEditingController();
  TextEditingController _txtMinWt= TextEditingController();
  TextEditingController _txtMaxWt = TextEditingController();
  TextEditingController _txtMinMaxUOM = TextEditingController();
  TextEditingController _txtDestCountry = TextEditingController();

  @override
  void initState(){
    curOrder = widget.Order;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> body = [];
    List<Widget> details = [];
    String strPoDate = "";
    String strSchDate = "";
    String strExpDate = "";

    //Format Date Str
    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(curOrder.PODate) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(curOrder.PODate);
      strPoDate = "${DateFormat("MMM, d yyyy").format(dt)}";
    }
    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(curOrder.ScheduleDt) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(curOrder.ScheduleDt);
      strSchDate = "${DateFormat("MMM, d yyyy").format(dt)}";
    }
    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(curOrder.ExpirationDt) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(curOrder.ExpirationDt);
      strExpDate = "${DateFormat("MMM, d yyyy").format(dt)}";
    }
    _txtLocation.text = curOrder.AddrType;
    _txtOrderDt.text = strPoDate;
    _txtScheduledDt.text = strSchDate;
    _txtExpDt.text = strExpDate;
    _txtRef.text = curOrder.Reference;
    _txtPayTerms.text = curOrder.Terms;
    _txtShipTerms.text = curOrder.PriceBasis;
    _txtDept.text = curOrder.DeptNm;
    _txtTradeType.text = curOrder.TradeType;
    _txtCurrency.text = curOrder.Currency;
    _txtStatus.text = curOrder.Status;
    _txtShipVia.text = curOrder.ShipVia;
    _txtShipTo.text = curOrder.ShipToAddress;
    _txtMaxWt.text = cnvDouble(curOrder.MaxWt.replaceAll(",", "")) == 0 ? "" : fWt.format( cnvDouble(curOrder.MaxWt.replaceAll(",", "")));
    _txtMinWt.text = cnvDouble(curOrder.MinWt.replaceAll(",", "")) == 0 ? "" : fWt.format( cnvDouble(curOrder.MinWt.replaceAll(",", "")));
    _txtMinMaxUOM.text = getUOM(curOrder.MinMaxUOM) ;
    _txtOrderType.text = curOrder.OrderType == "0" ? "SPOT" : "CONTRACT";
    _txtDestCountry.text = curOrder.DestCountryNm;
    if(curOrder.PONumber.isEmpty && curOrder.ShipToAddress.isEmpty){
      getShipTo();
    }
    //Create PO Detail tiles
    for(var i = 0; i < curOrder.Details.length; i++){
      details.add(
          Slidable(
            child: getDetailTile(curOrder.Details[i]),
            endActionPane:  ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  // An action can be bigger than the others.
                  flex: 2,
                  onPressed: (BuildContext context){ deleteDetail(curOrder.Details[i]);},
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Delete',
                ),
              ],

            ),
          )
      );

      details.add(detailDiv);
    }
    details.add(
      Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green,),
            onPressed: (){
              curDetail = globals.OrderDetail(CurrencyCd: curOrder.Currency, WeightUOM: curOrder.MinMaxUOM, PriceUOM: curOrder.MinMaxUOM, PODetailID: "NEW_${Random().nextInt(10000)}");
              Navigator.of(context).push(MaterialPageRoute(
                  settings:   RouteSettings(name: "OrderDetailEdit"),
                  builder: (context) => FixFont(context, getDetailPage()))
              );
            },
          ),
          Text("add order item", style: detailSubTitleStyle,)
        ],
      )
    );



    //Return Page
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            centerTitle: true,
            actions: [
              isSaving ? const Center( child: CircularProgressIndicator.adaptive(),) :
              TextButton(
                onPressed: ()=>{saveOrder()},
                child: Text("Save", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.lightBlue))),
              ),
            ],
            title:  Text(
                curOrder.PONumber.isEmpty ? "New ${curOrder.Source.trim()}" : "${curOrder.Source.trim()}# ${curOrder.PONumber}",
                style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)
            ),
            leadingWidth: MediaQuery.of(context).size.width/4,
            leading: TextButton(
              onPressed: Navigator.of(context).pop,
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
        body: ListView(
          children: [
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
                          child: Text("${curOrder.AccountName}" , overflow: TextOverflow.ellipsis, style: headerTitleStyle),
                        ),
                      ],
                    ),
                  ]),
            ),
            getFieldTile("Location", _txtLocation, true,  (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, SearchPageCbo(objType: "LOCATION_OBJ", objID: curOrder.CpID, showSearch: true, title: "Locations", setList: [], onClick: setLocation, addBlank: false)))
              );
            }),
            div,
            getFieldTile("Order Date", _txtOrderDt, true, (){
              DateTime? dt = DateFormat("yyyy-MM-ddTh:m:s").tryParse(curOrder.PODate);
              DatePicker.showDatePicker(context,
                  currentTime: dt ?? DateTime.now(),
                  showTitleActions: true,
                  locale: LocaleType.en,
                  onConfirm: (date){
                  setState(() {
                    _txtOrderDt.text = "${DateFormat("MMM, d yyyy").format(date)}";
                    curOrder.PODate = "${DateFormat("yyyy-MM-ddT00:00:00").format(date)}";
                  });

                  }
              );
            }),
            div,
            getFieldTile("Scheduled", _txtScheduledDt, true,  (){
              DateTime? dt = DateFormat("yyyy-MM-ddTh:m:s").tryParse(curOrder.ScheduleDt);
              DatePicker.showDatePicker(context,
                  currentTime: dt ?? DateTime.now(),
                  showTitleActions: true,
                  locale: LocaleType.en,
                  onConfirm: (date){
                  setState(() {
                    curOrder.ScheduleDt = "${DateFormat("yyyy-MM-ddT00:00:00").format(date)}";
                    _txtScheduledDt.text = "${DateFormat("MMM, d yyyy").format(date)}";
                  });

                  }
              );
            }),
            div,
            getFieldTile("Expiration", _txtExpDt, true, (){
              DateTime? dt = DateFormat("yyyy-MM-ddTh:m:s").tryParse(curOrder.ExpirationDt);
              DatePicker.showDatePicker(context,
                  currentTime: dt ?? DateTime.now(),
                  showTitleActions: true,
                  locale: LocaleType.en,
                  onConfirm: (date){
                  setState(() {
                    curOrder.ExpirationDt = "${DateFormat("yyyy-MM-ddT00:00:00").format(date)}";
                    _txtExpDt.text = "${DateFormat("MMM, d yyyy").format(date)}";
                  });

                  }
              );
            }),
            div,
            Padding(
              padding: tilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                      padding: lblPadding,
                      child: Text("Reference", style: titleStyle, overflow: TextOverflow.ellipsis,),
                      )
                    ),
                    Expanded(
                      flex: 8,
                      child: TextFormField(controller: _txtRef, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle, onChanged: (text){
                        setState(() {
                          curOrder.Reference = text;
                        });

                      },)
                    ),
                    Expanded(flex: 1, child: Text("")
                    )
                ],
              )
            ),
            div,
            getFieldTile("Shipping", _txtShipTerms, true,   (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, SearchPageCbo(objType: "SHIPPING_TERM", objID: "", showSearch: true, title: "Shipping", setList: [], onClick: setShipping)))
              );
            }),
            div,
            getFieldTile("Pay Terms", _txtPayTerms, true,   (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, SearchPageCbo(objType: "BILLING_TERM", objID: "", showSearch: true, title: "Shipping", setList: [], onClick: setPayTerms)))
              );
            }),
            div,
            Padding(
              padding: tilePadding,
              child: GestureDetector(
              onTap: (){
                if(globals.LockedDept == "0"){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                      FixFont(context, SearchPageCbo(objType: "DEPT", objID: "", showSearch: true, title: "Departments", setList: [], onClick: setDept, addBlank: false,)))
                  );
                }

              },
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: lblPadding,
                          child: Text("Dept", style: titleStyle, overflow: TextOverflow.ellipsis,),
                        )
                      ),
                      Expanded(
                        flex: 8,
                        child:TextFormField(controller: _txtDept, decoration: txtFieldDec, textAlign: TextAlign.start, style: globals.LockedDept == "0" ?  subTitleStyle : subTitleStyleGray, readOnly: true , onTap: (){
                          if(globals.LockedDept == "0"){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                                FixFont(context, SearchPageCbo(objType: "DEPT", objID: "", showSearch: true, title: "Departments", setList: [], onClick: setDept, addBlank: false,)))
                            );
                          }
                        },  )
                      ),
                      Expanded(flex: 1, child: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18, ))
                    ],
                  ),
                )
              ),
              /*
              getFieldTile("Dept", _txtDept, true,  (){
                if(globals.LockedDept == "0"){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                      FixFont(context, SearchPageCbo(objType: "DEPT", objID: "", showSearch: true, title: "Departments", setList: [], onClick: setDept, addBlank: false,)))
                  );
                } else {
                  PopUp(context, "Permissions Restriction", "Department is locked for this user.");
                }

              }),
*/
            div,
            getFieldTile("Trade-Type", _txtTradeType, true,  (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, SearchPageCbo(objType: "TRADE_TYPE", objID: "", showSearch: true, title: "Trade Type", setList: [], onClick: setTradeType)))
              );
            }),
            div,
            getFieldTile("Order-Type", _txtOrderType, true,  (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, SearchPageCbo(objType: "TRADE_TYPE", objID: "", showSearch: false, title: "Order Type", setList: OrderTypes, onClick: setOrderType)))
              );
            }),
            div,
            getFieldTile("Dest Port", _txtDestCountry, true,  (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context,  SearchPageCbo(objType: "PORT", objID: "", showSearch: false, title: "Destination Ports", setList: [], onClick: setDestCountry)))
              );
            }),
            div,
            Padding(
                padding: tilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 4,
                        child: Padding(
                          padding: lblPadding,
                          child: Text("Min Weight", style: titleStyle, overflow: TextOverflow.ellipsis,),
                        )
                    ),
                    Expanded(
                        flex: 8,
                        child: TextFormField(controller: _txtMinWt, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle, keyboardType: TextInputType.number, onChanged: (text){
                          setState(() {
                            curOrder.MinWt = text.isEmpty ? "0" : text;
                          });
                        },)
                    ),
                    Expanded(flex: 1, child: Text("")
                    )
                  ],
                )
            ),
            div,
            Padding(
                padding: tilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Padding(
                          padding: lblPadding,
                          child: Text("Max Weight", style: titleStyle, overflow: TextOverflow.ellipsis,),
                        )
                    ),
                    Expanded(
                        flex: 6,
                        child: TextFormField(controller: _txtMaxWt, decoration: txtFieldDec, textAlign: TextAlign.start, keyboardType: TextInputType.number, style: subTitleStyle, onChanged: (text){
                          setState(() {
                            curOrder.MaxWt = text.isEmpty ? "0" : text;
                          });

                        },)
                    ),
                    Expanded(flex: 1, child: Text("")
                    )
                  ],
                )
            ),
            div,
            getFieldTile("UOM", _txtMinMaxUOM, true,  (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, SearchPageCbo(objType: "PORT", objID: "", showSearch: false, title: "Min/Max Weight UOM", setList: UOM, onClick: setMinMaxUOM)))
              );
            }),
            div,
            /*getFieldTile("Currency", _txtCurrency, true,  (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  SearchPageCbo(objType: "CURRENCY", objID: "", showSearch: true, title: "Currency", setList: [], onClick: globals.isDotNet ? (){} : setCurrency))
              );
            }),*/
            Padding(
                padding: tilePadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 4,
                        child: Padding(
                          padding: lblPadding,
                          child: Text("Currency", style: titleStyle, overflow: TextOverflow.ellipsis,),
                        )
                    ),
                    Expanded(
                        flex: 8,
                        child: TextFormField(controller: _txtCurrency, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyleGray, readOnly: true,)
                    ),
                    Expanded(flex: 1, child: Text("")
                    )
                  ],
                )
            ),
            div,
            getFieldTile("Status", _txtStatus, true,  (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, SearchPageCbo(objType: "", objID: "", showSearch: false, title: "Status", setList: Status, onClick: setStatus)))
              );
            }),
            div,
            getFieldTile("Ship Via", _txtShipVia, true,  (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, SearchPageCbo(objType: "SHIP_VIA", objID: "", showSearch: false, title: "Ship Via", setList: [], onClick: setShipVia)))
              );
            }),
            div,
             Padding(
              padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10, right: 10),
                child:
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ship To", style: titleStyle,),
                      SizedBox(height: 5),
                      SizedBox(
                          height: 150.0,
                          child:TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: 30,
                            controller: _txtShipTo,
                            decoration: InputDecoration(
                                enabledBorder:  OutlineInputBorder(borderSide:  BorderSide(color: greyBackground, width: 0.0),),
                                focusedBorder: OutlineInputBorder(borderSide:  BorderSide(color: greyBackground, width: 1.0),)
                            ),
                            onTapOutside: (PointerDownEvent){
                              setState(() {
                                curOrder.ShipToAddress = _txtShipTo.text;
                              });
                            },

                          )
                      ),
                    ],
                )),
            Container(
              decoration: BoxDecoration(color: greyBackground, border: const Border(top: BorderSide(width: 1, color: Color(0xFFE3E3E3)))),
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 5.0),
            ),

            Column(children: details,),
          ],
        ),

    );
  }

  //SUB WIDGET FUNCTIONS
  Widget getDetailTile(globals.OrderDetail Detail){

    String UnitStr = "";
    if(Detail.Packaging.isNotEmpty){
      UnitStr = "${Detail.Packaging}-${fUnit.format(double.parse(Detail.Units))}";
    }

    return ListTile(
        contentPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 15, right: 20),
        dense: true,
        tileColor: Colors.white,
        title:  Text("${Detail.PODesc.isEmpty ? Detail.GradeNm : Detail.PODesc} ${Detail.Specifications.isEmpty ? "" : "- ${Detail.Specifications}"}", style: detailTitleStyle,),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("${fWt.format(cnvDouble(Detail.Weight))} ${getUOM(Detail.WeightUOM)}", style: detailSubTitleStyle,),
                Text("${fCur.format(cnvDouble(Detail.Amount))}", style: detailSubTitleStyle,),
              ],
            ),
            Column(
              children: [
                Text("${fWt.format(cnvDouble(Detail.Price))}/${getUOM(Detail.PriceUOM)} ${Detail.CurrencyCd}", style: detailTitleStyle,),
              ],
            )
          ],
        ),
      onTap: (){
          setState(() {curDetail = Detail;});
        Navigator.of(context).push(MaterialPageRoute(
            settings:   RouteSettings(name: "OrderDetailEdit"),
            builder: (context) => FixFont(context, getDetailPage()))
        );
      },
    );
  }

  Widget getFieldTile(String title, TextEditingController _controller, bool isClick, VoidCallback onTap ){
    return  Padding(
        padding: tilePadding,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 4,
                  child: Padding(
                    padding: lblPadding,
                    child: Text(title, style: titleStyle, overflow: TextOverflow.ellipsis,),
                  )
              ),
              Expanded(
                  flex: 8,
                  child: isClick ?
                  TextFormField(controller: _controller, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle, readOnly: true, onTap: onTap, )
                      : TextFormField(controller: _controller, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle,)
              ),
              Expanded(flex: 1, child:
              isClick ? Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18, ) : Text("")
              )
            ],
          ),
        )
        );
  }

  Widget getDetailPage(){

    TextEditingController _txtDetailGrade = TextEditingController();
    TextEditingController _txtDetailPrice= TextEditingController();
    TextEditingController _txtDetailPriceUOM= TextEditingController();
    TextEditingController _txtDetailWt= TextEditingController();
    TextEditingController _txtDetailWtUOM= TextEditingController();
    TextEditingController _txtDetailAmt= TextEditingController();
    TextEditingController _txtDetailCurrency= TextEditingController();
    TextEditingController _txtDetailUnits= TextEditingController();
    TextEditingController _txtDetailUnitType= TextEditingController();
    TextEditingController _txtDetailSpecifications= TextEditingController();
    TextEditingController _txtDetailPODesc= TextEditingController();

    _txtDetailGrade.text = curDetail.GradeNm;
    _txtDetailPrice.text = NumberFormat("##0.##", "en_US").format(cnvDouble(curDetail.Price));
    _txtDetailPriceUOM.text = getUOM(curDetail.PriceUOM);
    _txtDetailWt.text = NumberFormat("##0.##", "en_US").format(cnvDouble(curDetail.Weight));
    _txtDetailWtUOM.text = getUOM(curDetail.WeightUOM);
    _txtDetailAmt.text =  fCur.format(cnvDouble(curDetail.FxAmount));
    _txtDetailUnits.text = fUnit.format(cnvDouble(curDetail.Units));
    _txtDetailUnitType.text = curDetail.Packaging;
    _txtDetailSpecifications.text = curDetail.Specifications;
    _txtDetailPODesc.text = curDetail.PODesc;

    if(_txtDetailPrice.text == "0") _txtDetailPrice.text = "";
    if(_txtDetailWt.text == "0") _txtDetailWt.text = "";
    if(_txtDetailUnits.text == "0") _txtDetailUnits.text = "";
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: ()=>{saveDetail(curDetail)},
              child: Text(curDetail.PODetailID.isEmpty ? "Add" : "Save", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.blue))),
            )
          ],
          title:  Text(curDetail.PODetailID.isEmpty ? "Add Item" : "Edit Item", style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
          leadingWidth: MediaQuery.of(context).size.width/4,
          leading: TextButton(
            onPressed: Navigator.of(context).pop,
            child: Align(alignment: Alignment.centerLeft,
              child:  Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_back_ios_rounded, color: Colors.blue,), SizedBox(width: 2),
                  Text("Back", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.lightBlue))),
                ],
              )
            ),
          )
      ),
      body: ListView(
        children: [
          div,
          getFieldTile("Grade", _txtDetailGrade, true, (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                FixFont(context, SearchPageCbo(objType: "GRADE", objID: curOrder.CpID, showSearch: true, title: "Grades", setList: [], onClick: (globals.SearchItem item){
                  Navigator.of(context).popUntil(ModalRoute.withName('OrderDetailEdit'));
                  setState(() {
                    curDetail.GradeNm = item.title;
                    curDetail.GradeID = item.objID;
                    _txtDetailGrade.text = item.title;
                  });
                })))
            );
          }),
          div,
          Padding(
            padding: tilePadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 3,
                    child: Padding(
                      padding: lblPadding,
                      child: Text("Alt Name", style: titleStyle, overflow: TextOverflow.ellipsis,),
                    )
                ),
                Expanded(
                    flex: 6,
                    child: TextFormField(controller: _txtDetailPODesc, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle,
                      onChanged: (text){
                        setState(() {curDetail.PODesc = _txtDetailPODesc.text;});
                      },
                    )
                ),
                Expanded(flex: 1, child: Text("")
                )
              ],
            ),
          ),
          div,
          Padding(
              padding: tilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: lblPadding,
                        child: Text("Price", style: titleStyle, overflow: TextOverflow.ellipsis,),
                      )
                  ),
                  Expanded(
                      flex: 5,
                      child: TextFormField(controller: _txtDetailPrice, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle, keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (text){
                          double amt = calcValue(cnvDouble(_txtDetailPrice.text), getUOMID(_txtDetailPriceUOM.text), cnvDouble(_txtDetailWt.text), getUOMID(_txtDetailWtUOM.text));
                          _txtDetailAmt.text = fCur.format(amt);
                          setState(() {
                            curDetail.Amount = (amt/double.parse(curOrder.FxRate)).toString();
                            curDetail.FxAmount = amt.toString();
                            curDetail.Price = _txtDetailPrice.text;
                          });

                        },
                      )
                  ),
                  Expanded(flex: 2, child: TextFormField(controller: _txtDetailPriceUOM, decoration: txtFieldDec, textAlign: TextAlign.start, readOnly: true, style: subTitleStyle, keyboardType: TextInputType.number,
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                          FixFont(context,  SearchPageCbo(objType: "GRADE", objID: curOrder.CpID, showSearch: true, title: "Price UOM", setList: UOM, onClick: (item){
                            _txtDetailPriceUOM.text = item.title;
                            setState(() {
                              curDetail.PriceUOM = getUOMID(item.objID);
                              double amt = calcValue(cnvDouble(_txtDetailPrice.text), getUOMID(_txtDetailPriceUOM.text), cnvDouble(_txtDetailWt.text), getUOMID(_txtDetailWtUOM.text));
                              _txtDetailAmt.text = fCur.format(amt);
                              curDetail.Amount = (amt/double.parse(curOrder.FxRate)).toString();
                              curDetail.FxAmount = amt.toString();
                            });

                            Navigator.of(context).popUntil(ModalRoute.withName('OrderDetailEdit'));
                          })))
                      );
                    },
                  )
                  )
                ],
              )
          ),
          div,
          Padding(
              padding: tilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: lblPadding,
                        child: Text("Weight", style: titleStyle, overflow: TextOverflow.ellipsis,),
                      )
                  ),
                  Expanded(
                      flex: 5,
                      child: TextFormField(controller: _txtDetailWt, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle, keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (text){
                          double amt = calcValue(cnvDouble(_txtDetailPrice.text), getUOMID(_txtDetailPriceUOM.text), cnvDouble(_txtDetailWt.text), getUOMID(_txtDetailWtUOM.text));
                          _txtDetailAmt.text = fCur.format(amt);
                          setState(() {
                            curDetail.Amount = (amt/double.parse(curOrder.FxRate)).toString();
                            curDetail.FxAmount = amt.toString();
                            curDetail.Weight = _txtDetailWt.text;
                          });

                        },
                      )
                  ),
                  Expanded(flex: 2, child: TextFormField(controller: _txtDetailWtUOM, decoration: txtFieldDec, textAlign: TextAlign.start, readOnly: true, style: subTitleStyle, keyboardType: TextInputType.number,
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                          FixFont(context, SearchPageCbo(objType: "GRADE", objID: curOrder.CpID, showSearch: true, title: "Weight UOM", setList: UOM, onClick: (item){
                            _txtDetailWtUOM.text = item.title;
                            setState(() {
                              curDetail.WeightUOM = getUOMID(item.objID);
                              double amt = calcValue(cnvDouble(_txtDetailPrice.text), getUOMID(_txtDetailPriceUOM.text), cnvDouble(_txtDetailWt.text), getUOMID(_txtDetailWtUOM.text));
                              _txtDetailAmt.text = fCur.format(amt);
                              curDetail.Amount = (amt/double.parse(curOrder.FxRate)).toString();
                              curDetail.FxAmount = amt.toString();
                            });

                            Navigator.of(context).popUntil(ModalRoute.withName('OrderDetailEdit'));
                          })))
                      );
                    },
                  )
                  ),

                ],
              )
          ),

          div,
          Padding(
              padding: tilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: lblPadding,
                        child: Text("Amount", style: titleStyle, overflow: TextOverflow.ellipsis,),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: TextFormField(controller: _txtDetailAmt, decoration: txtFieldDec, textAlign: TextAlign.start, readOnly: true, style: subTitleStyle, keyboardType: TextInputType.number,)
                  ),
                  Expanded(flex: 1, child: Text("")
                  )
                ],
              )
          ),
          div,
          Padding(
              padding: tilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: lblPadding,
                        child: Text("Units", style: titleStyle, overflow: TextOverflow.ellipsis,),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: TextFormField(controller: _txtDetailUnits, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle, keyboardType: TextInputType.number,
                        onChanged: (text){
                          setState(() {curDetail.Units = _txtDetailUnits.text;});
                        },
                      )
                  ),
                  Expanded(flex: 1, child: Text("")
                  )
                ],
              )
          ),
          div,
          getFieldTile("Packaging", _txtDetailUnitType, true, (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                FixFont(context, SearchPageCbo(objType: "UNITTYPE", objID: curOrder.CpID, showSearch: true, title: "Unit Type", setList: [], onClick: (item){
                  setState(() {
                    curDetail.UnitTypeID = item.objID;
                    curDetail.Packaging = item.title;
                  });

                  _txtDetailUnitType.text = item.title;
                  Navigator.of(context).popUntil(ModalRoute.withName('OrderDetailEdit'));
                })))
            );
          }),
          div,
          Padding(
              padding: tilePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: Padding(
                        padding: lblPadding,
                        child: Text("Specs", style: titleStyle, overflow: TextOverflow.ellipsis,),
                      )
                  ),
                  Expanded(
                      flex: 6,
                      child: TextFormField(controller: _txtDetailSpecifications, decoration: txtFieldDec, textAlign: TextAlign.start, style: subTitleStyle,
                        onChanged: (text){
                          setState(() {curDetail.Specifications = _txtDetailSpecifications.text;});
                        },
                      )
                  ),
                  Expanded(flex: 1, child: Text("")
                  )
                ],
              ),
          ),

        ],
      ),
    );
  }

  //SETTER FUNCTIONS
  void setLocation(globals.SearchItem item){
    setState(() {
      curOrder.AddrType = item.objID;
      _txtLocation.text = item.title;
    });

    getShipTo();
    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setShipping(globals.SearchItem item){
    setState(() {
      curOrder.PriceBasis = item.objID;
      _txtShipTerms.text = item.objID;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setPayTerms(globals.SearchItem item){
    setState(() {
      curOrder.Terms = item.title;
      _txtPayTerms.text = item.title;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setDept(globals.SearchItem item){
    setState(() {
      curOrder.DeptID = item.objID;
      curOrder.DeptNm = item.title;
      _txtDept.text = item.title;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setTradeType(globals.SearchItem item){
    setState(() {
      curOrder.TradeType = item.title;
      _txtTradeType.text = item.title;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setCurrency(globals.SearchItem item){
    setState(() {
      curOrder.Currency = item.title;
      curOrder.FxRate = item.objID;
    });

    _txtCurrency.text = item.title;
    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setStatus(globals.SearchItem item){
    setState(() {
      curOrder.Status = item.title;
      _txtStatus.text = item.title;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setOrderType(globals.SearchItem item){
    setState(() {
      curOrder.OrderType = item.title == "SPOT" ? "0" : "1";
      _txtOrderType.text = item.title;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setDestCountry(globals.SearchItem item){
    setState(() {
      curOrder.DestCountryNm = item.title;
      curOrder.DestCountry = item.objID;
      _txtDestCountry.text = item.title;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setMinMaxUOM(globals.SearchItem item){
    setState(() {
      curOrder.MinMaxUOM= getUOMID(item.title) ;
      _txtMinMaxUOM.text = item.title;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  void setShipVia(globals.SearchItem item){
    setState(() {
      curOrder.ShipVia = item.title;
      _txtShipVia.text = item.title;
    });

    if(curOrder.PONumber.isEmpty){
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('OrderEdit_${curOrder.PONumber}'));
    }
  }

  //HELPER FUNCTIONS

  void goHome(){
    Navigator.of(context).popUntil(ModalRoute.withName('/Home'));
  }

  void goBack(){
    Navigator.of(context).pop();
  }

  void deleteDetail(globals.OrderDetail detail){
    if(detail.LinkedWks.isNotEmpty){
      PopUp(context, "Delete Failed", "Order item is linked to a worksheet detail on Wks ${detail.LinkedWks}");
      return;
    }
    for(int i = 0; i < curOrder.Details.length; i++){
      if(curOrder.Details[i].PODetailID == detail.PODetailID){
        curOrder.Details.remove(curOrder.Details[i]);
      }
    }

    Navigator.pushReplacement(context, MaterialPageRoute(
        settings:   RouteSettings(name: "OrderEdit_${curOrder.PONumber}"),
        builder: (BuildContext context) => FixFont(context, OrderEditPage(refresh: widget.refresh, Order:curOrder)))
    );
  }

  void saveDetail(globals.OrderDetail detail){
    bool updated = false;
    for(int i = 0; i < curOrder.Details.length; i++){
      if(curOrder.Details[i].PODetailID == detail.PODetailID){
        curOrder.Details[i] = detail;
        updated = true;
      }
    }
    if(curDetail.PODetailID.contains("NEW") && !updated){
      curOrder.Details.add(detail);
    }
    Navigator.of(context).pop();
    Navigator.pushReplacement(context, MaterialPageRoute(
        settings:   RouteSettings(name: "OrderEdit_${curOrder.PONumber}"),
        builder: (BuildContext context) => FixFont(context, OrderEditPage(refresh: widget.refresh, Order:curOrder)))
    );
  }

  void deleteConfirm(){
    AlertDialog alert = AlertDialog(
      title: Text("Confirm delete", style: GoogleFonts.lato(fontSize: 23, fontWeight: FontWeight.w700, color: Color(0xFF676769))),
      content: Text("Are you sure you want to delete this order?", style: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF676769))),
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
            deleteOrder();

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

  //API CALLS
  void getShipTo() async{
    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=SHIPTO&ObjID=${curOrder.CpID}&ObjID2=${_txtLocation.text}&UserID=${globals.cieTradeUserID}"));
    if(rep.statusCode == 200){
      var body = jsonDecode(rep.body);
      var ShipTo = body["ObjID"] == null ? "" : body["ObjID"].toString();
      setState(() {
        curOrder.ShipToAddress = ShipTo;
        _txtShipTo.text = ShipTo;
      });

    }
  }

void deleteOrder() async{
  var url = Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileUpdateCreate");

  Map data = {
    "User":"${globals.userID}",
    "Pswd":"${globals.userPswd}",
    "PONumber":curOrder.PONumber,
    "UserID":"${globals.cieTradeUserID}",
    "Source": curOrder.Source,
    "POReference":curOrder.Reference,
    "COID":curOrder.DeptID,
    "TradeType": curOrder.TradeType,
    "PODate": curOrder.PODate.replaceAll("T12:0:0", "").replaceAll("T00:00:00", ""),
    "Status":curOrder.Status,
    "CpID":curOrder.CpID,
    "AddrType": curOrder.AddrType,
    "ShipAddrType": curOrder.ShipAddrType,
    "ShipTo":_txtShipTo.text,
    "ShipAddrID": curOrder.ShipAddrID,
    "Terms": curOrder.Terms,
    "PriceBasis": curOrder.PriceBasis,
    "FxRate":curOrder.FxRate,
    "Currency": curOrder.Currency,
    "ScheduleDt": curOrder.ScheduleDt.replaceAll("T12:0:0", "").replaceAll("T00:00:00", ""),
    "ExpirationDt": curOrder.ExpirationDt.replaceAll("T12:0:0", "").replaceAll("T00:00:00", ""),
    "Instructions": curOrder.Instructions.trim(),
    "ShipVia": curOrder.ShipVia,
    "DestPort": curOrder.DestCountry,
    "OrderType": curOrder.OrderType,
    "MinWt": curOrder.MinWt.replaceAll(",", ""),
    "MaxWt": curOrder.MaxWt.replaceAll(",", ""),
    "MinMaxUOM": curOrder.MinMaxUOM,
    "Details": []
  };

  Response rep = await delete(url, headers: {"Content-Type": "application/json"}, body: json.encode(data));

  if(rep.statusCode != 200){
    PopUp(context, "Delete Failed", jsonDecode(rep.body)["Message"]);
  } else {
    Navigator.of(context).pop();
    Navigator.of(context).pop();

  }
}

  void saveOrder() async{
    if(curOrder.TradeType.isEmpty && globals.ReqTradeType == "1"){
      PopUp(context, "Save Error", "Must set Trade Type");
      return;
    }
    setState(() {isSaving = true;});
    var url = Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileUpdateCreate");
     List<Map> details = [];
     for(int i = 0; i < curOrder.Details.length; i++){
       details.add(
         {
           "PPO_ID": curOrder.Details[i].PODetailID.contains("NEW") ? "0" : curOrder.Details[i].PODetailID,
           "GradeID":curOrder.Details[i].GradeID,
           "PONumber":curOrder.PONumber,
           "PODesc":curOrder.Details[i].PODesc,
           "Specifications":curOrder.Details[i].Specifications,
           "Weight":curOrder.Details[i].Weight,
           "WeightUOM":curOrder.Details[i].WeightUOM,
           "UnitTypeID":curOrder.Details[i].UnitTypeID,
           "Units":fUnit.format(double.parse(curOrder.Details[i].Units)),
           "Price":curOrder.Details[i].Price,
           "PriceUOM":curOrder.Details[i].PriceUOM,
           "FxAmount":round(curOrder.Details[i].FxAmount,2),
           "Amount":round(curOrder.Details[i].Amount,2),
           "CurrencyCd":curOrder.Details[i].CurrencyCd,
           "SPo": curOrder.Details[i].OrderNo,
         }

       );
     }

    Map data = {
      "User":"${globals.userID}",
      "Pswd":"${globals.userPswd}",
      "PONumber":curOrder.PONumber,
      "UserID":"${globals.cieTradeUserID}",
      "Source": curOrder.Source,
      "POReference":curOrder.Reference,
      "COID":curOrder.DeptID,
      "TradeType": curOrder.TradeType,
      "PODate": curOrder.PODate.replaceAll("T12:0:0", "").replaceAll("T00:00:00", ""),
      "Status":curOrder.Status,
      "CpID":curOrder.CpID,
      "AddrType": curOrder.AddrType,
      "ShipAddrType": curOrder.ShipAddrType,
      "ShipTo":_txtShipTo.text,
      "ShipAddrID": curOrder.ShipAddrID,
      "Terms": curOrder.Terms,
      "PriceBasis": curOrder.PriceBasis,
      "FxRate":curOrder.FxRate,
      "Currency": curOrder.Currency,
      "ScheduleDt": curOrder.ScheduleDt.replaceAll("T12:0:0", "").replaceAll("T00:00:00", ""),
      "ExpirationDt": curOrder.ExpirationDt.replaceAll("T12:0:0", "").replaceAll("T00:00:00", ""),
      "Instructions": curOrder.Instructions.trim(),
      "ShipVia": curOrder.ShipVia,
      "DestPort": curOrder.DestCountry,
      "OrderType": curOrder.OrderType,
      "MinWt": curOrder.MinWt.replaceAll(",", ""),
      "MaxWt": curOrder.MaxWt.replaceAll(",", ""),
      "MinMaxUOM": curOrder.MinMaxUOM,
      "Details": details
    };

    Response rep = await patch(url, headers: {"Content-Type": "application/json"}, body: json.encode(data));

    if(rep.statusCode != 200){
      setState(() {isSaving = false;});
      PopUp(context, "Error", "Save failed");
    } else {
      widget.refresh();
      String PONumber = jsonDecode(rep.body);
      GetOrder(PONumber).then((value){
        setState(() {isSaving = false;});
        //Navigator.of(context).popUntil(ModalRoute.withName('/Home'));
        if(curOrder.PONumber.isNotEmpty) {Navigator.of(context).pop();}
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            settings:   RouteSettings(name: "OrderPage_$PONumber"),
            builder: (context) => FixFont(context, value))
        );
      });


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

      return OrderPage(Order: Order, onBack:  goBack, popOnBack: true,);
    }
    return OrderPage(Order: globals.Order(Details: []), onBack: goBack, popOnBack: true);
  }
}