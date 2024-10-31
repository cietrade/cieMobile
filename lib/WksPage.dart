import 'dart:ui';

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


class WksPage extends StatefulWidget{
  final globals.Worksheet wks;
  final Function() onBack;
  final String wksType;
  final String header;
  WksPage({Key? key, required this.wks, required this.onBack,  required this.wksType, required this.header}) : super(key: key);

  @override
  State<WksPage> createState() => _WksPageState();
}

class _WksPageState extends State<WksPage> {
  EdgeInsets tilePadding = const EdgeInsets.only(top: 2, bottom: 2, left: 18, right: 10);
  Widget div = const Padding( padding: EdgeInsets.only(left: 16), child: Divider(height: 1.2, color: Color(0xFFCBCBCF),));
  Widget detailDiv = const Divider(height: 1.2, color: Color(0xFFCBCBCF),);
  Color greyFont = const Color(0xFF61676E);
  Color greyBackground = Color(0xFFE3E3E3);
  TextStyle titleStyle = const TextStyle( fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF4A5059));
  TextStyle subTitleStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  TextStyle detailTitleStyle = const TextStyle( fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF343F4B));
  TextStyle detailSubTitleStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF5A6978));
  TextStyle statusStyle =  GoogleFonts.lato( textStyle:  const TextStyle( fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF61676E)));
  TextStyle soldToStyle = GoogleFonts.lato( textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.deepOrange));
  TextStyle purchFromStyle = GoogleFonts.lato( textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green.shade900));
  TextStyle headerTitleStyle = GoogleFonts.lato( textStyle:  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500));
  TextStyle headerSubTitleStyle = GoogleFonts.lato( textStyle:  const TextStyle( fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF4A5059)));
  TextStyle totalLabelStyle = GoogleFonts.lato(textStyle:  const TextStyle( fontSize: 15, color: Color(0xFF535355)));
  TextStyle totalValueStyle = GoogleFonts.lato(textStyle:  const TextStyle( fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF343F4B)));
  TextStyle orderNoStyle =  GoogleFonts.lato(textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF61676E)));



  @override
  Widget build(BuildContext context) {
    List<Widget> header = [];
    List<Widget> body = [];
    List<Widget> footer = [];
    Container headerTile;
    String shipDateStr = "";
    String dueDateStr = "";
    String postDateStr = "";
    String orderDateStr = "";
    String strPO = "";
    String strSO = "";
    String custLbl = "SOLD TO";
    String suppLbl = "PURCHASED FROM";
    String shipDtLbl = "Ship Date";
    double FooterHeight = 0;

    //Format Date Strs
    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(widget.wks.ShipDt) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(widget.wks.ShipDt);
      shipDateStr = "${DateFormat("MMM, d yyyy").format(dt)}";
    }

    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(widget.wks.DueDate) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(widget.wks.DueDate);
      dueDateStr = "${DateFormat("MMM, d yyyy").format(dt)}";
    }

    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(widget.wks.PostingDt) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(widget.wks.PostingDt);
      postDateStr = "${DateFormat("MMM, d yyyy").format(dt)}";
    }

    if(DateFormat("yyyy-MM-ddTh:m:s").tryParse(widget.wks.OrderDt) != null) {
      DateTime dt = DateFormat("yyyy-MM-ddTh:m:s").parse(widget.wks.OrderDt);
      orderDateStr = "${DateFormat("MMM, d yyyy").format(dt)}";
    }

    //SET PO STRINGS
    if(widget.wks.PO.isNotEmpty){strPO = "PO#${widget.wks.PO}";}
    if(widget.wks.SO.isNotEmpty){strSO = "SO#${widget.wks.SO}";}

    //SET FILED LABELS
    if(widget.wksType == "INVOICE"){
      shipDtLbl = "Invoice Date";
    } else if(widget.wks.SoldToCompany == "(INVENTORY)"){
      shipDtLbl = "Received Date";
    }

    if(widget.wks.SoldToCompany == "(INVENTORY)"){
      custLbl = "RECEIVING WAREHOUSE";
      suppLbl = "SUPPLIER";
      if(widget.wks.Status == "INVOICED"){widget.wks.Status = "POSTED";}
    }
    else if(widget.wksType == "OPENSHIP"){
      custLbl = "SHIP TO";
    }

    if(widget.wks.SoldFromCompany == "(INVENTORY)"){
      suppLbl = "WAREHOUSE";
    }

    //BUILD HEADER
    if(["INVOICE", "OPENSHIP", "SALE", ""].contains(widget.wksType)){
      header.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(custLbl, style: soldToStyle,) ,
              ),
              Expanded(
                  flex: 1,
                  child: Text(widget.wks.Status, textAlign: TextAlign.right, style: statusStyle)
              )
            ],
          ));

      header.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(widget.wks.SoldToCompany == "(INVENTORY)" ?  widget.wks.SoldToAddrType : widget.wks.SoldToCompany , overflow: TextOverflow.ellipsis, style: headerTitleStyle),
            )
          ],
        ));
      header.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(widget.wks.SoldToCompany == "(INVENTORY)" ? "" : widget.wks.SoldToAddrType , overflow: TextOverflow.ellipsis, style: headerSubTitleStyle),
              ),
              Expanded(
                  flex: 1,
                  child: Text( widget.wksType == "" ? strSO : "", textAlign: TextAlign.right, style: orderNoStyle)
              )
            ],
          )
      );
    }

    if(widget.wksType == ""){header.add( Container(height: 10,));}

    if(["PURCHASE", ""].contains(widget.wksType)){
      header.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(suppLbl, style: purchFromStyle,)
              ),
              Expanded(
                  flex: 1,
                  child: Text(widget.wksType == "" ? "" : widget.wks.Status, textAlign: TextAlign.right, style: statusStyle)
              )
            ],
          ));
      header.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(widget.wks.SoldFromCompany == "(INVENTORY)" ? widget.wks.SoldFromAddrType :  widget.wks.SoldFromCompany , overflow: TextOverflow.ellipsis, style: headerTitleStyle),
            )
          ],
        ),
      );
      header.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(widget.wks.SoldFromCompany == "(INVENTORY)" ? "" : widget.wks.SoldFromAddrType , overflow: TextOverflow.ellipsis, style: headerSubTitleStyle),
              ),
              Expanded(
                  flex: 1,
                  child: Text(widget.wksType == "" ? strPO : "", textAlign: TextAlign.right, style: orderNoStyle)
              )
            ],
          )
      );
    }

    headerTile = Container(
      decoration: BoxDecoration(color: greyBackground, border: const Border(top: BorderSide(width: 1, color: Color(0xFFD4D4D4)))),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 20.0),
      //height: 120,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  header
      ),
    );

    //BUILD BODY
      body.add(
        getFieldTile(
            Text(shipDtLbl, overflow: TextOverflow.ellipsis, style: titleStyle),
            Text(shipDateStr, overflow: TextOverflow.ellipsis, style: subTitleStyle)
        ),
      );
      body.add(div);

      if(!["PURCHASE"].contains(widget.wksType) && widget.wks.SoldToCompany != "(INVENTORY)" ){
        body.add(
          getFieldTile(
              Text("Due Date", overflow: TextOverflow.ellipsis, style: titleStyle),
              Text(dueDateStr, overflow: TextOverflow.ellipsis, style: subTitleStyle)
          ),
        );
        body.add(div);
      }
     if(widget.wksType == ""){
       body.add(
         getFieldTile(
             Text(widget.wks.OrderDtLbl, overflow: TextOverflow.ellipsis, style: titleStyle),
             Text(orderDateStr, overflow: TextOverflow.ellipsis, style: subTitleStyle)
         ),
       );
       body.add(div);
     }

      body.add(
        getFieldTile(
            Text("Post Date", overflow: TextOverflow.ellipsis, style: titleStyle),
            Text(postDateStr, overflow: TextOverflow.ellipsis, style: subTitleStyle)
        ),
      );
      body.add(div);

      if(widget.wks.OrderRef.isNotEmpty){
        body.add(
          getFieldTile(
              Text("Order#", overflow: TextOverflow.ellipsis, style: titleStyle),
              Text(widget.wks.OrderRef, overflow: TextOverflow.ellipsis, style: subTitleStyle)
          ),
        );
        body.add(div);
      }

    if(widget.wks.ReleaseNo.isNotEmpty) {
      body.add(
        getFieldTile(
            Text("Release#", overflow: TextOverflow.ellipsis, style: titleStyle),
            Text(widget.wks.ReleaseNo, overflow: TextOverflow.ellipsis, style: subTitleStyle)
        ),
      );
      body.add(div);
    }
    if(widget.wks.BookingNo.isNotEmpty) {
      body.add(
        getFieldTile(
            Text("Booking#", overflow: TextOverflow.ellipsis, style: titleStyle),
            Text(widget.wks.BookingNo, overflow: TextOverflow.ellipsis, style: subTitleStyle)
        ),
      );
      body.add(div);
    }
      /*body.add(
        getFieldTile(
            Text("Carrier", overflow: TextOverflow.ellipsis, style: titleStyle),
            Text(widget.wks.Delivery, overflow: TextOverflow.ellipsis, style: subTitleStyle)
        ),
      );
      body.add(div);*/

      if(!["OPENSHIP", "SALE"].contains(widget.wksType)){
        if(widget.wks.PickUpNo.isNotEmpty){
          body.add(
            getFieldTile(
                Text("Pickup#", overflow: TextOverflow.ellipsis, style: titleStyle),
                Text(widget.wks.PickUpNo, overflow: TextOverflow.ellipsis, style: subTitleStyle)
            ),
          );
          body.add(div);
        }

      }

      body.add(
        getFieldTile(
            Text("Department", overflow: TextOverflow.ellipsis, style: titleStyle),
            Text(widget.wks.DeptNm, overflow: TextOverflow.ellipsis, style: subTitleStyle)
        ),
      );
      body.add(div);

      body.add(
        getFieldTile(
            Text("Trade Type", overflow: TextOverflow.ellipsis, style: titleStyle),
            Text(widget.wks.TradeType, overflow: TextOverflow.ellipsis, style: subTitleStyle)
        ),
      );



    //BUILD DETAILS
    body.add(
        Container(
          decoration: BoxDecoration(color: greyBackground, border: Border(top: BorderSide(width: 1, color: Color(0xFFD4D4D4)))),
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 5.0),
        )
    );
    for(var i = 0; i < widget.wks.Details.length; i++){
      if(widget.wks.Details[i].ProductDesc.contains("TAX") && ["", "SALE", "INVOICE"].contains(widget.wksType)){
        body.add(
            ListTile(
              contentPadding: const EdgeInsets.only(top: 0, bottom: 5, left: 15, right: 20),
              dense: true,
              tileColor: Colors.white,
              title: Text("SALES TAX", style: detailTitleStyle, overflow: TextOverflow.ellipsis,),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Expanded(
                      flex: 1,
                      child: Text(widget.wks.TaxCodeNm, style: detailSubTitleStyle, textAlign: TextAlign.left, overflow: TextOverflow.ellipsis,)
                  ),
                  Expanded(
                      flex: 1,
                      child: Text(widget.wks.FxTaxAmount, style: detailSubTitleStyle, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis,)
                  ),
                ],
              ),

            )
        );
        body.add(detailDiv);
      } else {
        body.add(getDetailTile(widget.wks.Details[i]));
        body.add(detailDiv);
      }
    }


    //BUILD FOOTER
    if(widget.wksType == "INVOICE"){
      FooterHeight = 90;

      footer.add(
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text("Total Invoice Amount ", overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
            ),
            Expanded(
              flex: 2,
              child: Text("${ NumberFormat("###,###.00").format(cnvDouble(widget.wks.FxInvoiceAmt.replaceAll(",", "")))} ${widget.wks.CurrencyCd}", textAlign: TextAlign.right, style: totalValueStyle,),
            )
          ],
        ),
      );
      footer.add(
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text("Total Payments ", overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
            ),
            Expanded(
              flex: 2,
              child: Text("${ NumberFormat("###,###.00").format(cnvDouble(widget.wks.FxPayments.replaceAll(",", "")))} ${widget.wks.CurrencyCd}", textAlign: TextAlign.right, style: totalValueStyle,),
            )
          ],
        ),
      );
      footer.add(
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text("Balance Due ", overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
            ),
            Expanded(
              flex: 2,
              child: Text("${ NumberFormat("###,###.00").format(cnvDouble(widget.wks.FxBalanceDue.replaceAll(",", "")))} ${widget.wks.CurrencyCd}", textAlign: TextAlign.right, style: totalValueStyle,),
            )
          ],
        ),
      );
    } else if(widget.wksType == ""){
      FooterHeight = 137;

      footer.add(
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text("Sales ${widget.wks.CurrencyCd}  ", overflow: TextOverflow.ellipsis,  style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
            ),
            Expanded(
              flex: 2,
              child: Text("${ NumberFormat("###,##0.00").format(cnvDouble( widget.wks.Sales))} ", textAlign: TextAlign.right, style: totalLabelStyle,),
            )
          ],
        ),
      );
      footer.add(
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text("Purchases ${widget.wks.CurrencyCd}  ", overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
            ),
            Expanded(
              flex: 2,
              child: Text("${ NumberFormat("###,##0.00").format(cnvDouble(widget.wks.Purchases))} ", textAlign: TextAlign.right, style: totalLabelStyle,),
            )
          ],
        ),
      );
      footer.add(
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text("Expenses ${widget.wks.CurrencyCd}  ", overflow: TextOverflow.ellipsis,  style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
            ),
            Expanded(
              flex: 1,
              child: Text("${ NumberFormat("###,##0.00").format(cnvDouble(widget.wks.Expenses))} ", textAlign: TextAlign.right, style: totalLabelStyle,),
            )
          ],
        ),
      );
      footer.add(
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text("Gross Profit ${widget.wks.CurrencyCd}  ", overflow: TextOverflow.ellipsis,  style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
            ),
            Expanded(
              flex: 1,
              child: Text("${ NumberFormat("###,##0.00").format(cnvDouble(widget.wks.GrossProfit))} ", textAlign: TextAlign.right, style: totalLabelStyle,),
            )
          ],
        ),
      );
      footer.add(
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text("Total Quantity", overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(textStyle:  totalValueStyle,)),
            ),
            Expanded(
              flex: 1,
              child: Text("${ NumberFormat("###,###.##").format(cnvDouble(widget.wks.TotalWt))} ${getUOM(widget.wks.TotalWtUOM)}", textAlign: TextAlign.right, style: totalValueStyle,),
            )
          ],
        ),
      );
    } else {
      FooterHeight = 70;
      footer.add(
        Row(
          children: [
            Expanded(
              flex: 1,
              child:  Text("Total Value      ", overflow: TextOverflow.ellipsis, style: totalLabelStyle,),
            ),
            Expanded(
              flex: 2,
              child:  Text("${widget.wksType == "PURCHASE" ?  NumberFormat("###,##0.00").format(cnvDouble(widget.wks.Purchases)) :
              NumberFormat("###,##0.00").format(cnvDouble(widget.wks.FxInvoiceAmt.replaceAll(",", "")) + cnvDouble(widget.wks.FxTaxAmount.replaceAll(",", ""))) } ${widget.wks.CurrencyCd}", textAlign: TextAlign.right, style: totalValueStyle,),
            )

          ],
        ),
      );

      footer.add(
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Text("Total Weight", overflow: TextOverflow.ellipsis,  style: GoogleFonts.lato(textStyle:  totalLabelStyle,)),
            ),
            Expanded(
              flex: 2,
              child: Text("${ NumberFormat("###,###.##").format(cnvDouble(widget.wks.TotalWt))} ${getUOM(widget.wks.TotalWtUOM)}", textAlign: TextAlign.right,  style: totalValueStyle,),
            )
          ],
        ),
      );
    }



    //Return Page
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          centerTitle: true,
          actions: [
            widget.wksType == "INVOICE" ?
            TextButton(
              onPressed: ()=>{},
              child:  Text(""),
            )
                : const Text("")
          ],
          title:  Text(widget.header.replaceAll("Wks No.", "Wks#"), style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
          leadingWidth: MediaQuery.of(context).size.width/4,
          leading: TextButton(
            onPressed: widget.onBack,
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
        bottom: PreferredSize(preferredSize:   Size.fromHeight(widget.wksType == "" ? 175 : 100), child: headerTile,),
      ),

      body: ListView(
        children: body,
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 20),
        height: FooterHeight,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        color: greyBackground,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: footer,
        ),
      )
    );
  }

  Widget getDetailTile(globals.WksDetail Detail){
    if(["PAYMENT", "OFFSET"].contains(Detail.ProductDesc) ){
      String dateStr = "";
      if(DateFormat("MM/dd/yyyy").tryParse(Detail.SQuantityDesc) != null) {
        DateTime dt = DateFormat("MM/dd/yyyy").parse(Detail.SQuantityDesc);
        dateStr = "${DateFormat("MMM dd yyyy").format(dt)}";
      }
      return ListTile(
        contentPadding: const EdgeInsets.only(top: 0, bottom: 5, left: 15, right: 20),
        dense: true,
        tileColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 2,
                child: Text(Detail.ProductDesc, style: detailTitleStyle, overflow: TextOverflow.ellipsis,)
            ),
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dateStr, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,),
                Text(Detail.SPrice, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,),
                Text(Detail.SExtension, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,),
              ],
            ),


          ],
        ),
      );
    }


    if(["INVOICE", "OPENSHIP", "SALE"].contains(widget.wksType)){
      return ListTile(
        contentPadding: const EdgeInsets.only(top: 0, bottom: 5, left: 15, right: 20),
        dense: true,
        tileColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 2,
                child: Text(Detail.ProductDesc, style: detailTitleStyle, overflow: TextOverflow.ellipsis,)
            ),
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(Detail.UnitDesc, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,),
                        Text(Detail.Specifications, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,)
                      ],
                    )),

              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Detail.SQuantityDesc, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,),
                Text("${Detail.SPrice} ", style: detailSubTitleStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,),
                Text(Detail.SExtension, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,),
              ],
            ),


          ],
        ),
      );
    } else if(["PURCHASE"].contains(widget.wksType)){
      return ListTile(
        contentPadding: const EdgeInsets.only(top: 0, bottom: 5, left: 15, right: 20),
        dense: true,
        tileColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                flex: 2,
                child: Text(Detail.ProductDesc, style: detailTitleStyle, overflow: TextOverflow.ellipsis,)
            ),
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(Detail.UnitDesc, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,),
                        Text(" "),
                        Text(Detail.Specifications, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,)
                      ],
                    )),
                Expanded(child: Text("${Detail.PPrice} ${widget.wks.CurrencyCd}", style: detailSubTitleStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Detail.PQuantityDesc, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,),
                Text(Detail.PExtension, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,),
              ],
            ),


          ],
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.only(top: 0, bottom: 5, left: 15, right: 20),
      dense: true,
      tileColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 2,
              child: Text(Detail.ProductDesc, style: detailTitleStyle, overflow: TextOverflow.ellipsis,)
          ),

        ],
      ),
      subtitle: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(Detail.UnitDesc, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,),
                      Text(" "),
                      Text(Detail.Specifications, style: detailSubTitleStyle, overflow: TextOverflow.ellipsis,)
                    ],
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 2,
                  child: Text("${Detail.SPrice} ${widget.wks.CurrencyCd}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.deepOrange),)
              ),
              Expanded(
                  flex: 2,
                  child: Text(Detail.SQuantityDesc, style: detailSubTitleStyle,))
              ,
              Expanded(
                  flex: 2,
                  child: Text("${Detail.SExtension}", textAlign: TextAlign.right, style: detailSubTitleStyle,)
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 2,
                  child: Text("${Detail.PPrice} ${widget.wks.CurrencyCd}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.green),)
              ),
              Expanded(
                  flex: 2,
                  child: Text(Detail.PQuantityDesc, style: detailSubTitleStyle,)
              ),
              Expanded(
                  flex: 2,
                  child: Text("${Detail.PExtension}", textAlign: TextAlign.right, style: detailSubTitleStyle,)
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getFieldTile(Text title, Text value){
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 20),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [title, value],
      ),
    );
  }
}
