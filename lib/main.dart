import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // var prefs = await SharedPreferences.getInstance();
  // prefs.clear();
  await read();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        accentColor: Color(0xff434346),
        scaffoldBackgroundColor: Color(0xffE8EAED),
        primaryColor: Colors.white,
        appBarTheme: AppBarTheme(color: Color(0xffE8EAED)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xff393B43),
        accentColor: Color(0xffE8EAED),
        checkboxTheme: CheckboxThemeData( fillColor: MaterialStateProperty.all(Color(0xff303137))),
        scaffoldBackgroundColor: Color(0xff303137),
        appBarTheme: AppBarTheme(color: Color(0xff303137)),
      ),
      home: HomePage(),
    );
  }
}
