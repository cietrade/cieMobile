import 'package:ciemobile/HomePage.dart';
import 'package:ciemobile/OrderEditPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'Globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'HelperFunctions.dart' ;
import 'package:google_fonts/google_fonts.dart';
import 'HelperFunctions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class AccountPage extends StatefulWidget{
  final globals.Counterparty account;
  final Function() onBack;
  AccountPage({Key? key, required this.account, required this.onBack }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  TextStyle companyNmStyle = GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white));
  TextStyle infoTitle = GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF343F4B)));
  TextStyle infoValue = GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black));
  TextStyle infoEmail= GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.blue));
  TextStyle infoPhone= GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF343F4B)));
  TextStyle infoLinkLbl = GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black));
  TextStyle infoLinkDetail= GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF343F4B)));
  TextStyle infoLinkTime= GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w300, fontSize: 14, color: Color(0xFF343F4B)));
  TextStyle detailPageTitle = GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black));
  TextStyle actionSheetBtn = GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.blue));
  TextStyle contactLblStyle = const TextStyle( fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF969FAA));
  TextStyle contactValueStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
  InputDecoration contactFieldDec = InputDecoration( border: InputBorder.none,);
  ButtonStyle btnStyle = TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(50, 20), tapTargetSize: MaterialTapTargetSize.shrinkWrap, alignment: Alignment.centerLeft);
  BoxDecoration infoBoxDec = const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(width: 1, color: Colors.white)), borderRadius: BorderRadius.all(Radius.circular(10)));
  Widget div = const Padding( padding: EdgeInsets.only(left: 16), child: Divider(height: 1.2, color: Color(0xFFCBCBCF),));
  Color greyBackground = Color(0xFFE3E3E3);
  List<ListTile> Locations = [];
  List<String> cboRoleList = [];
  TextEditingController _txtLocSearch = TextEditingController();
  TextEditingController _txtName = TextEditingController();
  TextEditingController _txtFileAs = TextEditingController();
  TextEditingController _txtCompany = TextEditingController();
  TextEditingController _txtEmail= TextEditingController();
  TextEditingController _txtMobileNo = TextEditingController();
  TextEditingController _txtWorkNo = TextEditingController();
  TextEditingController _txtOtherNo = TextEditingController();
  TextEditingController _txtNotes = TextEditingController();
  TextEditingController _cboLocation= TextEditingController();
  TextEditingController _cboRole= TextEditingController();
  TextEditingController _txtAccountNotes = TextEditingController();
  bool isSaving = false;
  late globals.Contact curContact;

  //HELPER FUNCTIONS
  Future<void> _launchUrl(String _url) async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  String getRoleStr(List<String> Roles){
    String roles = "";
    for(var i = 0; i < Roles.length; i++){
      roles += "${Roles[i]}~";
    }
    return roles;
  }

  void Refresh(){
    setState(() {isSaving = true;});
    Future<AccountPage> page = GetAccount(widget.account.CpID);
    page.then((value) => {
    Navigator.pushReplacement(context,
      PageRouteBuilder(pageBuilder: (context, animation1, animation2) => FixFont(context, value),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        settings: RouteSettings(name: "AccountPage_${widget.account.CpID}"),
      ),
    )
    });
  }


  void openActionOrder(BuildContext context){
    String role = "";
    if(["C", "X"].contains(widget.account.Role)){role = "CUST";}
    if(["S", "V"].contains(widget.account.Role)){role = "SUP";}


    if(cnvDouble(widget.account.TotalSO) > 0){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context,HomePage( initReport: "OPENSO", initCpID: widget.account.CpID, initPageNm: widget.account.CompanyNm, popPage: true,)))).then((value) => Refresh());
    } else if(cnvDouble(widget.account.TotalPO) > 0){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context,HomePage( initReport: "OPENPO", initCpID: widget.account.CpID, initPageNm: widget.account.CompanyNm, popPage: true,)))).then((value) => Refresh());
    } else if(role == "CUST"){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context,HomePage( initReport: "OPENSO", initCpID: widget.account.CpID, initPageNm: widget.account.CompanyNm, popPage: true,)))).then((value) => Refresh());
    } else if(role == "SUP"){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context,HomePage( initReport: "OPENPO", initCpID: widget.account.CpID, initPageNm: widget.account.CompanyNm, popPage: true,)))).then((value) => Refresh());
    } else {
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                if(globals.SOCreate == "0"){
                  PopUp(context, "Permissions Restriction", "This user does not have permission to create Sales Orders.");
                } else {
                  getEmptyOrder("SO").then((value){
                    Navigator.of(context).push(MaterialPageRoute(
                        settings:   RouteSettings(name: "OrderPage_NEW"),
                        builder: (context) => FixFont(context, value)
                    )).then((value) => Refresh());
                  });
                }
              },
              child:  Text('New Sales Order', style: actionSheetBtn,),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                if(globals.POCreate == "0"){
                  PopUp(context, "Permissions Restriction", "This user does not have permission to create Purchase Orders.");
                } else {
                  getEmptyOrder("PO").then((value){
                    Navigator.of(context).push(MaterialPageRoute(
                        settings:   RouteSettings(name: "OrderPage_NEW"),
                        builder: (context) => FixFont(context, value)
                    )).then((value) => Refresh());
                  });
                }
              },
              child:   Text('New Purchase Order', style: actionSheetBtn,),
            ),
          ],)
      );
    }


  }
  void openActionSheetCon(BuildContext context, globals.Contact contact){
    List<Widget> btns = [];
    if(contact.Email.isNotEmpty){
      btns.add(
        CupertinoActionSheetAction(
          onPressed: () {_launchUrl("mailto:<${contact.Email}>?subject=<subject>&body=<body>");},
          child:  Text('Email', style: actionSheetBtn,),
        ),
      );
    }

    if(contact.PhoneBusiness.isNotEmpty){
      btns.add(
        CupertinoActionSheetAction(
          onPressed: () {_launchUrl("tel://${contact.PhoneBusiness}");},
          child:  Text('Call', style: actionSheetBtn,),
        ),
      );
    }

    btns.add(
      CupertinoActionSheetAction(
        onPressed: () {
          curContact = contact;
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, getContactEditPage())));
          },
        child:  Text('Edit Contact', style: actionSheetBtn,),
      ),
    );

    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(actions: btns,)
    );
  }

  void openActionSheetLoc(BuildContext context, String location, String addr, String notes){
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, getDetailsPage(getContacts(location), "Contacts"))));
              },
              child:  Text('Contacts', style: actionSheetBtn,),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                curContact = globals.Contact(CT_ID: "0", Location: location, Roles: []);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, getContactEditPage())));
              },
              child:  Text('Add Contact', style: actionSheetBtn,),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, getLocNotesPage(location, notes))));
              },
              child:  Text('Edit Notes', style: actionSheetBtn,),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                MapsLauncher.launchQuery(addr);
              },
              child:  Text('Map Location', style: actionSheetBtn,),
            ),
          ],
        )
    );
  }

  Widget getContactEditField(String label, TextEditingController _controller){
    return Padding(
        padding: const EdgeInsets.only(left: 16, top: 0, bottom: 0, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: contactLblStyle,),
            SizedBox(
              width: 3*MediaQuery.of(context).size.width/5,
              child:   TextField(controller: _controller,  decoration: contactFieldDec, textAlign: TextAlign.start, ),
            )

          ],
        ));
  }


  //SUB PAGES
  Widget getLocationSearch(){
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          leadingWidth: MediaQuery.of(context).size.width/4,
          scrolledUnderElevation: 0.0,
          leading:  TextButton(
          onPressed: (){Navigator.of(context).pop();},
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
          title: Text("Locations", style:  GoogleFonts.lato( textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),),

        ),
        body: ListView(scrollDirection: Axis.vertical, shrinkWrap: true, children: Locations)




    );
  }

  Widget getLocNotesPage(String Location, String Notes){
    TextEditingController _notes = TextEditingController();
    _notes.text = Notes;

    return  Scaffold(
      backgroundColor: Color(0xFFF2F4F7),
      appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          centerTitle: true,
          title:  Text("Account", style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
          leadingWidth: MediaQuery.of(context).size.width/4,
          leading: TextButton(
            onPressed:  (){
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
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
        actions: [
          TextButton(
            onPressed: () {
              saveLocNotes(Location, _notes.text);
              },
            child: Text("Save", style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.blue)),),
          )
        ],
      ),
      body: SingleChildScrollView(child:  Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xFF6285BC), border: Border(top: BorderSide(width: 1, color: Color(0xFF6285BC)))),
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
            //height: 120,
            child: Center( child:
            Text(Location, style: companyNmStyle,)
            ),
          ),
          Padding(
            padding:  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
            child: Text("Notes", style: detailPageTitle,),
          )  ,
          Padding(
            padding:  const EdgeInsets.only(left: 10.0, right: 10.0, top: 10),
            child:  SizedBox(
                height: 300.0,
                child:TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 30,
                    controller: _notes,
                    decoration:  InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(width: 0,style: BorderStyle.none,),),
                    )
                )
            ),
          )

        ]
      ))
      ,
    );
  }

  Widget getDetailsPage(Future<List<Widget>> data, String Title,  ){
    return FutureBuilder(
        future: data,
        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot){
          return  Scaffold(
            backgroundColor: Color(0xFFF2F4F7),
            appBar: AppBar(
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                centerTitle: true,
                title:  Text("Account", style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
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
                ),
                actions: [
                  Title == "Contacts" ?
                  IconButton(
                      onPressed: (){
                        curContact = globals.Contact(CT_ID: "0", CompanyNm: widget.account.CompanyNm,  Roles: []);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                          FixFont(context, getContactEditPage())
                      ));},
                      icon: Icon(Icons.add_outlined, color: Colors.blue,)
                  ) : Text(""),
              ],
            ),
            body: SingleChildScrollView(child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(color: Color(0xFF6285BC), border: Border(top: BorderSide(width: 1, color: Color(0xFF6285BC)))),
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
                  //height: 120,
                  child: Center( child:
                    Text(widget.account.CompanyNm, style: companyNmStyle,)
                  ),
                ),
                Padding(
                  padding:  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                  child: Text(Title, style: detailPageTitle,),
                )  ,
                Column( children: snapshot.hasData ? snapshot.data! :  [Center( child: CircularProgressIndicator.adaptive(),)],)
              ],
            ))
            ,
          );
        }
    );
  }

  Widget getContactEditPage({bool isReload = false}){
    List<Widget> body = [];
      _txtName.text = curContact.ContactNm;
      _txtFileAs.text = curContact.FileAs;
      _txtCompany.text = curContact.CompanyNm;
      _txtEmail.text = curContact.Email;
      _txtMobileNo.text = curContact.PhoneMobile;
      _txtWorkNo.text = curContact.PhoneBusiness;
      _txtNotes.text = curContact.Notes;
      _cboLocation.text = curContact.Location;
      _txtOtherNo.text = curContact.PhoneOther;
      _cboRole.text = cboRoleList[0];

    //Fill locations

    //Fill Roles
    List<Widget> roleRows = [];
    for(var i = 0; i < curContact.Roles.length; i++){
      roleRows.add(
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 0),
          child:  Text(curContact.Roles[i], style: contactValueStyle, textAlign: TextAlign.left,),
        )

      );
      roleRows.add(div);
    }

    roleRows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green,),
            onPressed: (){
              if(!curContact.Roles.contains(_cboRole.text) && _cboRole.text.isNotEmpty){
                setState(() {
                  curContact.Roles.add(_cboRole.text);
                  curContact.ContactNm = _txtName.text ;
                  curContact.FileAs = _txtFileAs.text ;
                  curContact.CompanyNm = _txtCompany.text ;
                  curContact.Email = _txtEmail.text ;
                  curContact.PhoneMobile = _txtMobileNo.text ;
                  curContact.PhoneBusiness = _txtWorkNo.text ;
                  curContact.Notes = _txtNotes.text ;
                  curContact.Location = _cboLocation.text ;
                  curContact.PhoneOther = _txtOtherNo.text ;
                });
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>
                    FixFont(context, getContactEditPage( isReload: true))
                ));
              }
            },
          ),
          DropdownMenu(
              inputDecorationTheme: InputDecorationTheme(border: InputBorder.none,),
              width: MediaQuery.of(context).size.width/2,
              controller: _cboRole,
              dropdownMenuEntries: cboRoleList.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(
                  value: value,
                  label: value,
                  style: MenuItemButton.styleFrom(
                    backgroundColor: Colors.white,
                    textStyle: contactValueStyle,
                  ),
                );
              }).toList(),
          )
        ],
      )
    );

    //BUILD FIELDS
    body.add(
        Padding(
            padding: const EdgeInsets.only(left: 16, top: 0, bottom: 0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Full Name", style: contactLblStyle,),
                SizedBox(
                  width: 3*MediaQuery.of(context).size.width/5,
                  child:   TextField(controller: _txtName,  decoration: contactFieldDec, textAlign: TextAlign.start, onChanged: (text){
                    if(text.split(" ").length == 2){
                      _txtFileAs.text = "${text.split(" ")[1]}, ${text.split(" ")[0]}";
                    } else {
                      _txtFileAs.text = text;
                    }

                  }, ),
                )

              ],
            ))
    );
    body.add(div);
    if(!globals.isDotNet){
      body.add(getContactEditField("File As", _txtFileAs),);
      body.add(div);
    };
    body.add(getContactEditField("Company", _txtCompany),);
    body.add(div);
    body.add(
        Padding(
            padding: const EdgeInsets.only(left: 16, top: 0, bottom: 0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Location", style: contactLblStyle,),
                SizedBox(
                  width:  3*MediaQuery.of(context).size.width/5,
                  child:
                  TextField(
                    controller: _cboLocation,  decoration: contactFieldDec, textAlign: TextAlign.start,
                    onTap: (){
                      setState(() {
                         curContact.ContactNm = _txtName.text ;
                         curContact.FileAs = _txtFileAs.text ;
                         curContact.CompanyNm = _txtCompany.text ;
                         curContact.Email = _txtEmail.text ;
                         curContact.PhoneMobile = _txtMobileNo.text ;
                         curContact.PhoneBusiness = _txtWorkNo.text ;
                         curContact.Notes = _txtNotes.text ;
                         curContact.Location = _cboLocation.text ;
                         curContact.PhoneOther = _txtOtherNo.text ;
                      });
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                          FixFont(context, getLocationSearch())
                      ));
                    },
                  ),
                )

              ],
            ))
    );
    body.add(div);
    body.add( getContactEditField("Email", _txtEmail),);
    body.add(div);
    body.add(getContactEditField("Mobile Phone", _txtMobileNo));
    body.add(div);
    body.add(getContactEditField("Work Phone", _txtWorkNo));
    if(!globals.isDotNet){
      body.add(div);
      body.add(getContactEditField("Other Phone", _txtOtherNo));
    }

    body.add(
      Container(
        decoration: BoxDecoration(color: greyBackground, border: Border(top: BorderSide(width: 1, color: Color(0xFFD4D4D4)))),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 5.0),
      ),
    );
    body.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: roleRows,
      ),
    );
    body.add(
      Container(
        decoration: BoxDecoration(color: greyBackground, border: Border(top: BorderSide(width: 1, color: Color(0xFFD4D4D4)))),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0, bottom: 5.0),
      ),
    );
    body.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:  const EdgeInsets.only(left: 20.0, right: 10.0, top: 10),
              child: Text("Notes", style: contactLblStyle,),
            ),
            Padding(
              padding:  const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
              child:  SizedBox(
                  height: 150.0,
                  child:TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 30,
                    controller: _txtNotes,
                    decoration: InputDecoration(
                        enabledBorder:  OutlineInputBorder(borderSide:  BorderSide(color: greyBackground, width: 1.0),),
                        focusedBorder: OutlineInputBorder(borderSide:  BorderSide(color: greyBackground, width: 1.0),)
                    ),

                  )
              ),
            )
          ],
        )
    );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: ()=>{
                saveContact(curContact.CT_ID, curContact.Roles),
              },
              child:  Text("Save", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.blue))),
            )
          ],
          title:  Text("Edit Contact", style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
          leadingWidth: MediaQuery.of(context).size.width/4,
          leading: TextButton(
            onPressed: (){
              //PopUpConfirm(context, "Warning", "Unsaved changes will be lost. Do you wish to proceed?");
              Navigator.of(context).pop();
              Navigator.of(context).pop();

            },
            child: Align(
                alignment: Alignment.centerLeft,
                child:  Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_back_ios_rounded, color: Colors.blue,), SizedBox(width: 2),
                    Text("Back", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.blue))),
                  ],
                )),
          ),

        ),

        body: SingleChildScrollView(child: Column(
          children: body,
        ),),
    );
  }


  //OVERIDES
  @override
  void initState(){
    super.initState();
    getLocationsCbo();
    getRoles();
  }

  @override
  Widget build(BuildContext context) {
    //Format Address
    String addr = "";
    String Roles= "";
    List<Widget> infoTab = [];

    //FORMAT ADDRESS
    if(widget.account.Addr1.isNotEmpty ){addr += "${widget.account.Addr1}\n";}
    if(widget.account.Addr2.isNotEmpty ){addr += "${widget.account.Addr2}\n";}
    if(widget.account.Addr3.isNotEmpty ){addr += "${widget.account.Addr3}\n";}
    if("${widget.account.City}, ${widget.account.Region} ${widget.account.PostalCd} ${widget.account.Country}".replaceAll(",", "").trim().isNotEmpty ){
      addr += "${widget.account.City}, ${widget.account.Region} ${widget.account.PostalCd} ${widget.account.Country}";
    }

    //FORMAT ROLES
    if(widget.account.Role.toUpperCase() == "A"){Roles = "Customer, Supplier, Expense";}
    if(widget.account.Role.toUpperCase() == "C"){Roles = "Customer";}
    if(widget.account.Role.toUpperCase() == "S"){Roles = "Supplier";}
    if(widget.account.Role.toUpperCase() == "D"){Roles = "Expense";}
    if(widget.account.Role.toUpperCase() == "P"){Roles = "Customer, Supplier";}
    if(widget.account.Role.toUpperCase() == "V"){Roles = "Supplier, Expense";}
    if(widget.account.Role.toUpperCase() == "X"){Roles = "Customer, Expense";}
    if(widget.account.IsIntercompany == "1"){Roles += ", InterCompany";}

    //ASSEMBLE INFO TAB
    infoTab.add(Text("role", style: infoTitle,));
    infoTab.add(SizedBox(height: 2));
    infoTab.add(Text(Roles, style: infoValue,));
    infoTab.add(SizedBox(height: 10));
    infoTab.add(Text("address", style: infoTitle,));
    infoTab.add(SizedBox(height: 2));
    if(addr.isNotEmpty){ infoTab.add(Text(addr, style: infoValue,));}
    infoTab.add(SizedBox(height: 10));
    infoTab.add(Text("contact", style: infoTitle,));
    infoTab.add(SizedBox(height: 2));
    if(widget.account.Contact.isNotEmpty){infoTab.add(Text(widget.account.Contact, style: infoValue,));}
    if(widget.account.Email.isNotEmpty) {
      infoTab.add(TextButton(
          child: Text(widget.account.Email, style: infoEmail),
          onPressed: () =>
          {
            FlutterEmailSender.send(
                Email(
                  body: " ",
                  subject: " ",
                  recipients: [widget.account.Email],
                  cc: [''],
                  bcc: [''],
                  isHTML: false,
                )
            )
          },
          style: btnStyle
      ));
    }
    if(widget.account.Telephone.isNotEmpty) {
      infoTab.add(TextButton(
          child: Text(widget.account.Telephone, style: infoPhone),
          onPressed: () => {_launchUrl("tel://${widget.account.Telephone}")},
          style: btnStyle
      ));
    }
    infoTab.add(SizedBox(height: 10));
    infoTab.add(Text("credit", style: infoTitle,));
    infoTab.add(Text("${NumberFormat("###,##0.##").format(cnvDouble(widget.account.CreditLimit))} ${widget.account.CurrCode}", style: infoValue,));

    //ASSEMBLE BODY SECTIONS
      List<Widget> body = [
        Container(
          decoration: const BoxDecoration(color: Color(0xFF6285BC), border: Border(top: BorderSide(width: 1, color: Color(0xFF6285BC)))),
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
          //height: 120,
          child: Center( child:
          Text(widget.account.CompanyNm, style: companyNmStyle,)
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
          decoration: infoBoxDec,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: infoTab
          ),
        ),

        GestureDetector(
          onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              FixFont(context, getDetailsPage(getContacts(""), "Contacts"))
          )
          );},
          child: Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
            decoration: infoBoxDec,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
            child: Text("Contacts", style: infoLinkLbl,),
          ),
        ),

        GestureDetector(
          onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
              FixFont(context, getDetailsPage(getLocations(), "Locations"))

          )
          );},
          child: Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 2),
            decoration: infoBoxDec,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
            child: Text("Locations", style: infoLinkLbl,),
          ),
        )
      ];


      body.add(
          GestureDetector(
            onTap: (){openActionOrder(context);},
            child: Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 2),
                decoration: infoBoxDec,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
                child: Row(children: [
                  Expanded(child:  Text("Orders", style: infoLinkLbl,),),
                  Expanded(child: Text("${widget.account.TotalSO != "0" ? widget.account.TotalSO : widget.account.TotalPO } Open", textAlign: TextAlign.right, style: infoLinkDetail,),)
                ],)
            ),
          )
      );


      if(cnvDouble( widget.account.TotalInvoices) != 0  ){
        body.add(
            GestureDetector(
              onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, HomePage( initReport: "OPENAR", initCpID: widget.account.CpID, initPageNm: widget.account.CompanyNm, popPage: true,))
              )).then((value) => Refresh());},
              child: Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 2),
                  decoration: infoBoxDec,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
                  child: Row(children: [
                    Expanded(child:  Text("Open Receivables", style: infoLinkLbl,),),
                    Expanded(child: Text("${ widget.account.TotalInvoices } Invoices", textAlign: TextAlign.right, style: infoLinkDetail,),)
                  ],)
              ),
            )
        );
      }

      if(cnvDouble(widget.account.TotalSales) != 0  ) {
        body.add(
            GestureDetector(
              onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context, HomePage( initReport: "SALES", initCpID: widget.account.CpID, initPageNm: widget.account.CompanyNm, popPage: true))
              )).then((value) => Refresh());},
              child: Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 2),
                  decoration: infoBoxDec,
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
                  child: Row(children: [
                    Expanded(flex: 2, child: Text("Sales", style: infoLinkLbl, overflow: TextOverflow.ellipsis,),),
                    Expanded(flex: 2, child: Text("Past 12 months", textAlign: TextAlign.left, style: infoLinkTime, overflow: TextOverflow.ellipsis, ),),
                    Expanded(flex: 2,
                      child: Text("${ widget.account.TotalSales } Shipments",
                        textAlign: TextAlign.right, style: infoLinkDetail, overflow: TextOverflow.ellipsis,),)
                  ],)
              ),
            )
        );
      }
      if(cnvDouble( widget.account.TotalPurch) != 0  ) {
        body.add(
            GestureDetector(
              onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                  FixFont(context,  HomePage( initReport: "PURCHASES", initCpID: widget.account.CpID, initPageNm: widget.account.CompanyNm, popPage: true))
              )).then((value) => Refresh());},
              child: Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 2),
                  decoration: infoBoxDec,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
                  child: Row(children: [
                    Expanded(flex: 3, child:  Text("Purchases", style: infoLinkLbl, overflow: TextOverflow.ellipsis,),),
                    Expanded(flex: 3, child: Text("Past 12 months", textAlign: TextAlign.left, style: infoLinkTime, overflow: TextOverflow.ellipsis,),),
                    Expanded(flex: 3, child: Text("${ widget.account.TotalPurch } Tickets", textAlign: TextAlign.right, style: infoLinkDetail, overflow: TextOverflow.ellipsis,),)
                  ],)
              ),
            )
        );
      }

      _txtAccountNotes.text = widget.account.Notes;
      body.add(
        Container(
          margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
          decoration: infoBoxDec,
          width: double.infinity,

          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("notes", style: infoTitle,),
              SizedBox(height: 5),
              SizedBox(
                  height: 150.0,
                  child:TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 30,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9 _.,!"/$]*'))
                    ],
                    controller: _txtAccountNotes,
                    decoration: InputDecoration(
                        enabledBorder:  OutlineInputBorder(borderSide:  BorderSide(color: greyBackground, width: 1.0),),
                        focusedBorder: OutlineInputBorder(borderSide:  BorderSide(color: greyBackground, width: 1.0),)
                    ),
                  )
              ),
            ],
          ),
        ),
      );


      return Scaffold(
        backgroundColor: Color(0xFFF2F4F7),
        appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            centerTitle: true,
            title:  Text("Account", style: GoogleFonts.lato( textStyle:TextStyle(fontWeight: FontWeight.bold, fontSize: 17),)),
            actions: [
              TextButton(
                onPressed: ()=>{saveAccountNotes(),},
                child: isSaving ? const Center(child: CircularProgressIndicator.adaptive()) : Text("Save", softWrap: false, style: GoogleFonts.lato( textStyle:const TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.blue))),
              )
            ],
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
            )
        ),
        body: SingleChildScrollView(child:  Column(
          children: body,
        ))
        ,
      );
    }


  //API CALLS
  Future<OrderEditPage> getEmptyOrder(String Source) async{
    List<Widget> data = [];
    Response rep = await get(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&COID=00&UserID=${globals.cieTradeUserID}&ReportType=OPENSO&CpID=${widget.account.CpID}&WksViewAll=${globals.isAdmin ? "1" : "0"}&OrderViewAll=${globals.isAdmin ? "1" : "0"}&UOM=${globals.UOM}&DetailsOnly=0"));
    if(rep.statusCode == 200){
      var body = jsonDecode(rep.body);
      String DefAddr = body[0]["DefAddr"] == null ? "" : body[0]["DefAddr"].toString();
      String DefCurr = body[0]["DefCurr"] == null ? "" : body[0]["DefCurr"].toString();
      String DefDeptNm = body[0]["DefDeptNm"] == null ? "" : body[0]["DefDeptNm"].toString();
      String DefTerms = body[0]["DefTerms"] == null ? "" : body[0]["DefTerms"].toString();
      String FxRate = body[0]["FxRate"] == null ? "" : body[0]["FxRate"].toString();
      return OrderEditPage(
        refresh: (){},
        Order:globals.Order(
          AccountName: widget.account.CompanyNm,
          CpID: widget.account.CpID,
          Status: "WORK",
          DeptID: "00",
          DeptNm: DefDeptNm,
          AddrType: DefAddr,
          Terms: DefTerms,
          Currency: DefCurr,
          FxRate: FxRate,
          OrderType: "0",
          MinWt: "0",
          MaxWt: "0",
          MinMaxUOM: "L",
          PODate: DateFormat("yyyy-MM-ddT00:00:00").format(DateTime.now()),
          Details: [],
          Source: Source));

    } else {
      return OrderEditPage(refresh: (){}, Order:globals.Order(Details: []));
    }
  }


  Future<List<Widget>> getLocations({String filter = ""}) async{
    List<Widget> data = [];
    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=LOCATION&ObjID=${widget.account.CpID}"));
    if(rep.statusCode == 200){
      var body = jsonDecode(rep.body);
      for(var i = 0; i < body.length; i++){
        globals.Location item = globals.Location(
          Type: body[i]["Type"] == null ? "" : body[i]["Type"].toString(),
          Addr: body[i]["Addr"] == null ? "" : body[i]["Addr"].toString(),
          IsPrimary: body[i]["IsPrimary"] == null ? "" : body[i]["IsPrimary"].toString(),
          Notes: body[i]["Notes"] == null ? "" : body[i]["Notes"].toString(),
        );
        if(item.Type.startsWith(filter) || filter == ""){
          data.add(
              Container(
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                  decoration: infoBoxDec,
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 0.0, bottom: 0.0),
                  child: ListTile(
                    minLeadingWidth: 20,
                    contentPadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                    tileColor: Colors.white,
                    leading: item.IsPrimary == "Y" ?
                    Container( margin: EdgeInsets.only(left: 10),  height: 15, width: 15, decoration: new BoxDecoration(color: Colors.red, shape: BoxShape.circle),)
                        : Text(""),
                    title:  Text(item.Type, overflow: TextOverflow.ellipsis, style: infoLinkLbl,),
                    subtitle: Text(item.Addr, style: infoTitle,),
                    onTap: (){openActionSheetLoc(context, item.Type, item.Addr, item.Notes);},
                  ))
          );
        }

      }
      return data;

    } else {
      return [];
    }
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
      return  AccountPage(account: cp, onBack: Navigator.of(context).pop);
    }
    return  AccountPage(account: new globals.Counterparty(), onBack: Navigator.of(context).pop,);
  }

  void saveAccountNotes() async{
    widget.account.Notes = _txtAccountNotes.text;
    setState(() {isSaving = true;});
    Response rep = await post(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileUpdateCreate?User=${globals.userID}&Pswd=${globals.userPswd}&CpID=${widget.account.CpID}&Notes=${_txtAccountNotes.text}&UpdateType=COUNTERPARTY"));
    if(rep.statusCode != 200){
      PopUp(context, "Error", "Save failed");
    }
    setState(() {isSaving = false;});
  }

  void saveLocNotes(String Location, String Notes) async{
    Response rep = await post(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileUpdateCreate?User=${globals.userID}&Pswd=${globals.userPswd}&Location=${Location}&CpID=${widget.account.CpID}&Notes=${Notes}&UpdateType=LOCATION"));
    if(rep.statusCode != 200){
      PopUp(context, "Error", "Save failed");
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('AccountPage_${widget.account.CpID}'));
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, getDetailsPage(getLocations(), "Locations"))));
    }
  }

  void saveContact(String CT_ID, List<String> Roles) async{
    String notValid = "";
    RegExp phoneReg = new RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)');
    RegExp emailReg = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if(_txtName.text.isEmpty){notValid += "Name, ";}
    if(!phoneReg.hasMatch(_txtMobileNo.text) && _txtMobileNo.text.isNotEmpty){notValid += "Mobile Phone, ";}
    if(!phoneReg.hasMatch(_txtWorkNo.text) && _txtWorkNo.text.isNotEmpty){notValid += "Work Phone, ";}
    if(!emailReg.hasMatch(_txtEmail.text) && _txtEmail.text.isNotEmpty){notValid += "Email, ";}
    if(notValid.isNotEmpty){
      notValid = notValid.substring(0, notValid.length - 2);
      PopUp(context, "Save Failed", "Must enter valid ${notValid}");
      return;
    }
    Response rep = await post(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileUpdateCreate?User=${globals.userID}&Pswd=${globals.userPswd}&UpdateType=CONTACT&Location=${_cboLocation.text}&Notes=${_txtNotes.text}&Email=${_txtEmail.text}&PhoneBusiness=${_txtWorkNo.text}&PhoneMobile=${_txtMobileNo.text}&CT_ID=${CT_ID}&Roles=${getRoleStr(Roles)}&ContactNm=${_txtName.text}&PhoneOther=${_txtOtherNo.text}&FileAs=${_txtFileAs.text}&CpID=${widget.account.CpID}&CompanyNm=${_txtCompany.text}"));
    if(rep.statusCode != 200){
      PopUp(context, "Error", "Save failed");
    } else {
      Navigator.of(context).popUntil(ModalRoute.withName('AccountPage_${widget.account.CpID}'));
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => FixFont(context, getDetailsPage(getContacts(""), "Contacts"))));
    }
  }

  Future<List<Widget>> getContacts(String Location) async{
    List<Widget> data = [];

    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=CONTACT&ObjID=${widget.account.CpID}&ObjID2=${Location}"));
    if(rep.statusCode == 200){
      var body = jsonDecode(rep.body);
      for(var i = 0; i < body.length; i++){
        List<String> roles = [];
        globals.Contact item = globals.Contact(
          CT_ID: body[i]["CT_ID"] == null ? "" : body[i]["CT_ID"].toString(),
          ContactNm: body[i]["ContactNm"] == null ? "" : body[i]["ContactNm"].toString(),
          Location: body[i]["Location"] == null ? "" : body[i]["Location"].toString(),
          Email: body[i]["Email"] == null ? "" : body[i]["Email"].toString(),
          PhoneBusiness: body[i]["PhoneBusiness"] == null ? "" : body[i]["PhoneBusiness"].toString(),
          PhoneMobile: body[i]["PhoneMobile"] == null ? "" : body[i]["PhoneMobile"].toString(),
          PhoneOther: body[i]["PhoneOther"] == null ? "" : body[i]["PhoneOther"].toString(),
          CompanyNm: body[i]["CompanyNm"] == null ? "" : body[i]["CompanyNm"].toString(),
          FileAs: body[i]["FileAs"] == null ? "" : body[i]["FileAs"].toString(),
          Notes: body[i]["Notes"] == null ? "" : body[i]["Notes"].toString(),
          CpID: widget.account.CpID,
          Roles: []
        );

        for(var r = 0; r <  body[i]["Roles"].length; r++){
          roles.add(body[i]["Roles"][r].toString());
        }
        item.Roles = roles;

        data.add(
            Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10),
                decoration: infoBoxDec,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 0.0, bottom: 0.0),
                child: ListTile(
                    onTap: (){openActionSheetCon(context, item);},
                    tileColor: Colors.white,
                    title: Text(item.ContactNm, overflow: TextOverflow.ellipsis, style: infoLinkLbl,),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.Location,  overflow: TextOverflow.ellipsis, style: infoLinkTime,),
                        Text(item.Email, overflow: TextOverflow.ellipsis, style: infoLinkTime,),
                        Text(item.PhoneBusiness, overflow: TextOverflow.ellipsis, style: infoLinkTime,)
                      ],
                    )

                )
            )
        );
      }
      return data;

    } else {
      return [];
    }
  }

  void getLocationsCbo( {String filter = ""}) async{
    Border tileBorder = const Border(
      top: BorderSide(color: Color(0xFFDEDEDE), width: 0.5),
      bottom: BorderSide(color: Color(0xFFDEDEDE), width: 0),
      left: BorderSide(color: Color(0xFFDEDEDE), width: 1),
      right: BorderSide(color: Color(0xFFDEDEDE), width: 1),
    );
    List<ListTile> data = [];

    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=LOCATION&ObjID=${widget.account.CpID}"));
    if(rep.statusCode == 200){
      var body = jsonDecode(rep.body);
      data.add(
          ListTile(
            visualDensity: VisualDensity(vertical: -3),
            tileColor: Colors.white,
            title: Text("", overflow: TextOverflow.ellipsis, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),),
            onTap: () {
              setState(() {
                _cboLocation.text = "";
              });
              Navigator.of(context).pop();
            },
            shape: tileBorder,
          )
      );

      for(var i = 0; i < body.length; i++){
        String type = body[i]["Type"] == null ? "" : body[i]["Type"].toString().trim();
        if(filter == "" || type.startsWith(filter)){
          data.add(
              ListTile(
                visualDensity: VisualDensity(vertical: -3),
                tileColor: Colors.white,
                title: Text(type, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato( textStyle:const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),),
                onTap: () {
                  _cboLocation.text = type;
                  setState(() {curContact.Location = type;});
                  Navigator.of(context).pop();
                  },
                shape: tileBorder,
              )
          );
        }
      }
      setState(() {
        Locations = data;
      });
    }
  }
  void getRoles() async{
    List<String> data = [];
    Response rep = await patch(Uri.parse("${globals.http}://app.cietrade.com/cieAppREST/api/cieMobileDashboard?User=${globals.userID}&Pswd=${globals.userPswd}&objType=CONTACT_ROLES"));
    if(rep.statusCode == 200){
      var body = jsonDecode(rep.body);
      data.add("");
      for(var i = 0; i < body.length; i++){
        data.add(body[i]["ObjID"] == null ? "" : body[i]["ObjID"].toString());
      }
      setState(() {
        cboRoleList = data;
      });
    }
  }

}