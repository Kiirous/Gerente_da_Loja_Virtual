import 'package:flutter/material.dart';
import 'package:gerente_loja/screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
//teste commit MARCOS
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerente BeeCake',
      theme: ThemeData(
        primaryColor: Color(0xFFF2C063),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
