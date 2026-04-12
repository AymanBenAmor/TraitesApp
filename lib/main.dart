import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'HomePage.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        locale: const Locale('fr'), // force French
  supportedLocales: const [
    Locale('fr'),
    Locale('en'),
  ],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  
      title: 'Traites App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false, // ✅ HERE (correct place)
      home: HomePage(),
      navigatorObservers: [routeObserver], // add the observer here
    );
  }
}
