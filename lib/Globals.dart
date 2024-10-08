library my_prj.globals;

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'dart:convert';

import 'package:path/path.dart';

import 'HelperFunctions.dart';



String dBUserID = "";
String userID = "";
String userPswd = "";
String userName = "";
String userEmail = "";
String lastDB = "";
String serverNm = "";
String dBNm = "";
String cieTradeUserID = "";
String dBID = "";
String serverAddr = "";
String serverToken = "";
String serverPswd = "";
String http = "https";
String driver = "";
String warehouseID = "";
String warehouseNm = "";
bool isDotNet = false;
bool isDriver = false;
bool isAdmin = false;
int openTab = 0;
String SOEdit= "0";
String SOCreate= "0";
String SOViewAll = "0";
String SOEmail= "0";
String POEdit= "0";
String POCreate= "0";
String POViewAll = "0";
String POEmail= "0";
String PODel = "0";
String SODel = "0";
String WksViewAll= "0";
String WksViewUser = "0";
String WksViewReps= "0";
String OrderViewUser = "0";
String OrderViewReps= "0";
String DefDept= "";
String DefDeptNm = "";
String LockedDept= "0";
String DefRep= "";
String LockedRep = "";
String UOM = "L";
String version = "";
String isActive = "";
String ReqTradeType = "";

class cboItem{
  String Name = "";
  String Value = "";

  cboItem({String Name="", String Value=""}){
    this.Name = Name;
    this.Value = Value;
  }

  @override
  String toString() {
    return Name;
  }
}

class WksDetail{
  String ProductDesc = "";
  String UnitDesc = "";
  String PQuantityDesc = "";
  String PPrice = "";
  String PExtension = "";
  String SQuantityDesc = "";
  String SPrice = "";
  String SExtension = "";
  String Specifications = "";

  WksDetail( { String ProductDesc = "", String UnitDesc = "", String PQuantityDesc = "", String PPrice = "", String PExtension = "",
    String SQuantityDesc = "", String SPrice = "", String SExtension = "", Specifications = "" }){
    this.ProductDesc = ProductDesc;
    this.UnitDesc = UnitDesc;
    this.PQuantityDesc = PQuantityDesc;
    this.PPrice = PPrice;
    this.PExtension = PExtension;
    this.SQuantityDesc = SQuantityDesc;
    this.SPrice = SPrice;
    this.SExtension = SExtension;
    this.Specifications = Specifications;
  }
}

class Worksheet{
  String BuySellNo = "";
  String DeptNm = "";
  String TradeType = "";
  String PostingDt = "";
  String ShipDt = "";
  String OrderDt = "";
  String OrderRef = "";
  String ReleaseNo = "";
  String BookingNo = "";
  String EndUserNm = "";
  String SalesRepNm = "";
  String Delivery = "";
  String PaymentTerms = "";
  String DueDate = "";
  String SoldToCompany = "";
  String SoldToAddress = "";
  String SoldToAddrType= "";
  String ShipToCompany = "";
  String ShipToAddress = "";
  String SoldFromCompany = "";
  String SoldFromAddress = "";
  String SoldFromAddrType= "";
  String ShipFromCompany = "";
  String ShipFromAddress = "";
  String TaxCodeNm = "";
  String CurrencyCd = "";
  String FxInvoiceAmt = "";
  String FxTaxAmount = "";
  String FxInvoiceTotal = "";
  String FxPayments = "";
  String FxBalanceDue= "";
  String PickUpNo = "";
  String PO = "";
  String SO = "";
  String Status = "";
  String TotalWt = "";
  String TotalWtUOM = "";
  String Sales = "";
  String Purchases = "";
  String Expenses = "";
  String GrossProfit = "";
  String OrderDtLbl = "";
  List<WksDetail> Details = [];

  Worksheet({  String BuySellNo = "", String DeptNm = "", String TradeType = "", String PostingDt = "", String ShipDt = "", String OrderRef = "",
  String ReleaseNo = "", String BookingNo = "", String EndUserNm = "", String SalesRepNm = "", String Delivery = "", String PaymentTerms = "",
  String DueDate = "", String SoldToCompany = "", String SoldToAddress = "", String ShipToCompany = "", String ShipToAddress = "", String TaxCodeNm = "",
  String CurrencyCd = "", String FxInvoiceAmt = "", String FxTaxAmount = "", String FxInvoiceTotal = "", String FxPayments = "", String FxBalanceDue= "",
    String SoldToAddrType= "", String SoldFromCompany = "", String SoldFromAddress = "", String SoldFromAddrType= "", String ShipFromCompany = "",
    String ShipFromAddress = "", String PickUpNo = "", String PO = "", String SO = "", String Status="", String TotalWt = "", String TotalWtUOM = "", String OrderDt = "",
    String Sales = "", String Purchases = "", String Expenses = "", String GrossProfit = "", String OrderDtLbl = "",
    required List<WksDetail> Details}){
    this.BuySellNo = BuySellNo;
    this.DeptNm = DeptNm;
    this.TradeType = TradeType;
    this.PostingDt = PostingDt;
    this.ShipDt = ShipDt;
    this.OrderRef = OrderRef;
    this.ReleaseNo = ReleaseNo;
    this.BookingNo = BookingNo;
    this.EndUserNm = EndUserNm;
    this.SalesRepNm = SalesRepNm;
    this.Delivery = Delivery;
    this.PaymentTerms = PaymentTerms;
    this.DueDate = DueDate;
    this.SoldToCompany = SoldToCompany;
    this.SoldToAddress = SoldToAddress;
    this.ShipToCompany = ShipToCompany;
    this.ShipToAddress = ShipToAddress;
    this.TaxCodeNm = TaxCodeNm;
    this.CurrencyCd = CurrencyCd;
    this.FxInvoiceAmt = FxInvoiceAmt;
    this.FxTaxAmount = FxTaxAmount;
    this.FxInvoiceTotal = FxInvoiceTotal;
    this.FxPayments = FxPayments;
    this.FxBalanceDue= FxBalanceDue;
    this.Details = Details;
    this.SoldToAddrType= SoldToAddrType;
    this.SoldFromCompany = SoldFromCompany;
    this.SoldFromAddress = SoldFromAddress;
    this.SoldFromAddrType= SoldFromAddrType;
    this.ShipFromCompany = ShipFromCompany;
    this.ShipFromAddress = ShipFromAddress;
    this.PickUpNo = PickUpNo;
    this.PO = PO;
    this.SO = SO;
    this.Status = Status;
    this.TotalWt = TotalWt;
    this.TotalWtUOM = TotalWtUOM;
    this.OrderDt = OrderDt;
    this.Sales = Sales;
    this.Purchases = Purchases;
    this.Expenses = Expenses;
    this.GrossProfit = GrossProfit;
    this.OrderDtLbl = OrderDtLbl;
  }
}
 class OrderDetail {
   String PODetailID ="";
   String GradeID ="";
   String GradeNm ="";
   String OrderNo ="";
   String PODesc ="";
   String Specifications ="";
   String Weight ="";
   String WeightUOM ="";
   String Packaging ="";
   String UnitTypeID ="";
   String Units ="";
   String Price ="";
   String PriceUOM ="";
   String FxAmount ="";
   String CurrencyCd ="";
   String Amount ="";
   String Ordered = "";
   String Shipped="";
   String Opened="";
   String LinkedWks="";
   OrderDetail({  String PODetailID ="", String GradeID ="", String GradeNm ="", String OrderNo ="", String PODesc ="",
   String Specifications ="", String Weight ="0", String WeightUOM ="L", String Packaging ="", String UnitTypeID ="",
   String Units ="0", String Price ="0", String PriceUOM ="L", String FxAmount ="0", String CurrencyCd ="USD", String Amount ="0",
     String Ordered = "0", String Shipped="0", String Opened="0", String LinkedWks = "" }){
     this.PODetailID =PODetailID;
     this.GradeID =GradeID;
     this.GradeNm =GradeNm;
     this.OrderNo =OrderNo;
     this.PODesc =PODesc;
     this.Specifications =Specifications;
     this.Weight =Weight;
     this.WeightUOM =WeightUOM;
     this.Packaging =Packaging;
     this.UnitTypeID =UnitTypeID;
     this.Units = Units;
     this.Price = Price;
     this.PriceUOM =PriceUOM;
     this.FxAmount =FxAmount;
     this.CurrencyCd =CurrencyCd;
     this.Amount =Amount;
     this.Ordered = Ordered;
     this.Shipped = Shipped;
     this.Opened = Opened;
     this.LinkedWks = LinkedWks;
  }
}

class Order{
  String PONumber ="";
  String UserID ="";
  String UserNm ="";
  String Source ="";
  String Reference ="";
  String DeptID ="";
  String DeptNm = "";
  String TradeType ="";
  String PODate ="";
  String Status ="";
  String CpID ="";
  String AccountName ="";
  String AddrType ="";
  String RepName1 ="";
  String RepID1 ="";
  String RepName2 ="";
  String RepID2 ="";
  String ShipToType ="";
  String ShipAddrType ="";
  String ShipToAddress ="";
  String ShipAddrID ="";
  String DestCountry ="";
  String DestCountryNm ="";
  String Terms ="";
  String PriceBasis ="";
  String ShipVia ="";
  String FxRate ="";
  String Instructions ="";
  String PrimaryLoc ="";
  String RemitEmail ="";
  String ScheduleDt="";
  String ExpirationDt = "";
  String TotalAmt = "";
  String TotalWt="";
  String Currency = "";
  String MinWt = "";
  String MaxWt = "";
  String MinMaxUOM = "";
  String OrderType = "";
  List<OrderDetail> Details = [];

  Order({  String PONumber ="", String UserID ="", String UserNm ="", String Source ="", String Reference ="", String DeptID ="", String DeptNm="",
    String TradeType ="", String PODate ="", String Status ="", String CpID ="", String AccountName ="", String AddrType ="", String RepName1 ="",
    String RepID1 ="", String RepName2 ="", String RepID2 ="", String ShipToType ="", String ShipAddrType ="", String ShipToAddress ="",
    String ShipAddrID ="", String DestCountry ="", String DestCountryNm ="", String Terms ="", String PriceBasis ="", String ShipVia ="", String FxRate ="", String Currency = "",
    String Instructions ="", String PrimaryLoc ="", String RemitEmail ="",  String ScheduleDt="", String ExpirationDt = "", String TotalAmt = "", String TotalWt="",
    String MinWt = "", String MaxWt = "", String MinMaxUOM = "", String OrderType = "", required List<OrderDetail> Details }){
      this.PONumber =PONumber;
      this.UserID =UserID;
      this.UserNm =UserNm;
      this.Source =Source;
      this.Reference =Reference;
      this.DeptID =DeptID;
      this.DeptNm =DeptNm;
      this.TradeType =TradeType;
      this.PODate =PODate;
      this.Status =Status;
      this.CpID =CpID;
      this.AccountName =AccountName;
      this.AddrType =AddrType;
      this.RepName1 =RepName1;
      this.RepID1 =RepID1;
      this.RepName2 =RepName2;
      this.RepID2 =RepID2;
      this.ShipToType =ShipToType;
      this.ShipAddrType =ShipAddrType;
      this.ShipToAddress =ShipToAddress;
      this.ShipAddrID =ShipAddrID;
      this.DestCountry =DestCountry;
      this.DestCountryNm =DestCountryNm;
      this.Terms =Terms;
      this.PriceBasis =PriceBasis;
      this.ShipVia =ShipVia;
      this.FxRate =FxRate;
      this.Instructions =Instructions;
      this.PrimaryLoc =PrimaryLoc;
      this.RemitEmail =RemitEmail;
      this.Details = Details;
      this.ScheduleDt = ScheduleDt;
      this.ExpirationDt = ExpirationDt;
      this.TotalWt = TotalWt;
      this.TotalAmt = TotalAmt;
      this.Currency = Currency;
      this.MinWt = MinWt;
      this.MaxWt = MaxWt;
      this.MinMaxUOM = MinMaxUOM;
      this.OrderType = OrderType;
  }
}

class Counterparty{
  String CompanyNm ="";
  String CpID ="";
  String Role ="";
  String VendorNo ="";
  String CurrCode ="";
  String GroupNm ="";
  String ActiveStatus = "";
  String Addr1 ="";
  String Addr2 ="";
  String Addr3 ="";
  String City ="";
  String Region ="";
  String PostalCd ="";
  String Country ="";
  String Contact ="";
  String Telephone ="";
  String Email ="";
  String WebSite ="";
  String CreditLimit ="";
  String OnHold ="";
  String ActiveCreditProtocolID ="";
  String APContact ="";
  String APVoiceNo ="";
  String Terms ="";
  String SupplierGL ="";
  String VendorGL ="";
  String ReverseBilling ="";
  String CycleName ="";
  String BillOn ="";
  String StatementType ="";
  String UserDefined1 ="";
  String UserDefined2 ="";
  String UserDefined3 ="";
  String UserDefined4 ="";
  String IndustryNm ="";
  String SCAC ="";
  String DistributionMode ="";
  String SalesRep ="";
  String DefSalesRep ="";
  String Notes ="";
  String TotalInvoices ="";
  String TotalSales ="";
  String TotalPurch ="";
  String TotalSO ="";
  String TotalPO="";
  String OrderType="";
  String IsIntercompany = "";

  Counterparty({  String CompanyNm ="", String CpID ="", String Role ="", String VendorNo ="", String CurrCode ="", String GroupNm ="", String ActiveStatus = "",
  String Addr1 ="", String Addr2 ="", String Addr3 ="", String City ="", String Region ="", String PostalCd ="", String Country ="", String Contact ="", String Telephone ="",
  String Email ="", String WebSite ="", String CreditLimit ="", String OnHold ="", String ActiveCreditProtocolID ="", String APContact ="", String APVoiceNo ="",
  String Terms ="", String SupplierGL ="", String VendorGL ="", String ReverseBilling ="", String CycleName ="", String BillOn ="", String StatementType ="",
  String UserDefined1 ="", String UserDefined2 ="", String UserDefined3 ="", String UserDefined4 ="", String IndustryNm ="", String SCAC ="", String DistributionMode ="",
  String SalesRep ="", String DefSalesRep ="", String Notes ="", String TotalInvoices ="", String TotalSales ="", String TotalPurch ="", String TotalSO ="", String TotalPO="",
  String IsIntercompany =""}){
    this.CompanyNm =CompanyNm;
    this.CpID =CpID;
    this.Role =Role;
    this.VendorNo =VendorNo;
    this.CurrCode =CurrCode;
    this.GroupNm =GroupNm;
    this.ActiveStatus = ActiveStatus;
    this.Addr1 =Addr1;
    this.Addr2 =Addr2;
    this.Addr3 =Addr3;
    this.City =City;
    this.Region =Region;
    this.PostalCd =PostalCd;
    this.Country =Country;
    this.Contact =Contact;
    this.Telephone =Telephone;
    this.Email =Email;
    this.WebSite =WebSite;
    this.CreditLimit =CreditLimit;
    this.OnHold =OnHold;
    this.ActiveCreditProtocolID =ActiveCreditProtocolID;
    this.APContact =APContact;
    this.APVoiceNo =APVoiceNo;
    this.Terms =Terms;
    this.SupplierGL =SupplierGL;
    this.VendorGL =VendorGL;
    this.ReverseBilling =ReverseBilling;
    this.CycleName =CycleName;
    this.BillOn =BillOn;
    this.StatementType =StatementType;
    this.UserDefined1 =UserDefined1;
    this.UserDefined2 =UserDefined2;
    this.UserDefined3 =UserDefined3;
    this.UserDefined4 =UserDefined4;
    this.IndustryNm =IndustryNm;
    this.SCAC =SCAC;
    this.DistributionMode =DistributionMode;
    this.SalesRep =SalesRep;
    this.DefSalesRep =DefSalesRep;
    this.Notes =Notes;
    this.TotalInvoices =TotalInvoices;
    this.TotalSales =TotalSales;
    this.TotalPurch =TotalPurch;
    this.TotalSO =TotalSO;
    this.TotalPO=TotalPO;
    this.OrderType=cnvDouble(TotalPO) > cnvDouble(TotalSO) ? "PO" : "SO";
    this.IsIntercompany = IsIntercompany;
  }
}

class SearchItem{
  String title = "";
  String subTitle = "";
  String objID = "";

  SearchItem({String title = "", String subTitle = "", String objID = ""}){
    this.title = title;
    this.subTitle = subTitle;
    this.objID = objID;
  }

  @override
  String toString() {
    return title;
  }
}

class Location{
  String Type = "";
  String Addr = "";
  String IsPrimary = "";
  String Notes = "";

  Location({String Type = "", String Addr = "", String IsPrimary = "", String Notes = ""}){
    this.Type = Type;
    this.Addr = Addr;
    this.IsPrimary = IsPrimary;
    this.Notes = Notes;
  }
}

class Contact{
  String CT_ID = "";
  String ContactNm = "";
  String Location = "";
  String Email = "";
  String PhoneBusiness = "";
  String FileAs = "";
  String CompanyNm = "";
  String PhoneMobile = "";
  String PhoneOther = "";
  String Notes = "";
  String CpID = "";
  List<String> Roles = [];
  Contact({String CT_ID = "", String ContactNm = "", String Location = "", String Email = "", String PhoneBusiness = "",
    String FileAs = "", String CompanyNm = "", String PhoneMobile = "", String Notes = "", String CpID = "", String PhoneOther = "",
    required List<String> Roles,}){
    this.CT_ID = CT_ID;
    this.ContactNm = ContactNm;
    this.Location = Location;
    this.Email = Email;
    this.PhoneBusiness = PhoneBusiness;
    this.FileAs = FileAs;
    this.CompanyNm = CompanyNm;
    this.PhoneMobile = PhoneMobile;
    this.Notes = Notes;
    this.Roles = Roles;
    this.PhoneOther = PhoneOther;
  }
}




