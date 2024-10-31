import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'Login.dart';
import 'HomePage.dart';
import 'package:loader_overlay/loader_overlay.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cieLocation',
      theme: ThemeData(
        dialogTheme:  DialogTheme(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
        ),
        textTheme:  TextTheme(caption: GoogleFonts.openSans(textStyle: const TextStyle(color: Colors.black)) ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true, //<-- SEE HERE
          fillColor: Colors.white, //<-- SEE HERE
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          labelStyle: TextStyle(
            color: Colors.black,
            backgroundColor: Colors.white,
            fontSize: 18.0,
          ),
        ), colorScheme: ColorScheme.fromSeed(seedColor: Colors.white).copyWith(background: Colors.white),
      ),
      //home: const LoginPage(title: 'cieLocation'),
      routes: {
        '/': (context) => MediaQuery(child: LoginPage(title: 'cieLocation'), data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),),//const LoginPage(title: 'cieLocation'),
        '/Home': (context) => MediaQuery(child:  HomePage(), data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),),
      },

    );
  }
}
