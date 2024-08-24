import 'package:flutter/material.dart';
import 'home_page.dart';
import 'watchlist_page.dart';

void main() {
  runApp(StonksApp());
}

class StonksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STONKS',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueGrey,
        hintColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/watchlist': (context) => WatchlistPage(),
      },
    );
  }
}
