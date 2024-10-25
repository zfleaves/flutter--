import 'package:flutter/material.dart';
import 'package:flutter_jingdong/provider/Cart.dart';
import 'package:flutter_jingdong/provider/CheckOut.dart';
import 'package:flutter_jingdong/provider/Collect.dart';
import 'package:flutter_jingdong/provider/Counter.dart';
import 'package:provider/provider.dart';

//引入路由配置文件
import 'routers/router.dart';

void main() {
  // Add this line
  // await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Counter()),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => CheckOut()),
        ChangeNotifierProvider(create: (_) => Collect())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        // home: Text('sddssd'),
        initialRoute: '/',
        onGenerateRoute: onGenerateRoute,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.lightBlue[800],
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14, fontFamily: 'Hind'),
          )
        ),
      ),
    );
  }
}