import 'package:chatter_chatapp/Data/sevicies/service_locator.dart';
import 'package:chatter_chatapp/Presentation/screen/auth/login_screen.dart';
import 'package:chatter_chatapp/config/Theme/app_theme.dart';
import 'package:chatter_chatapp/router/app_router.dart';

import 'package:flutter/material.dart';



void main() async{
  await setupserviceLocator();                            // Initialize the service locator 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chatter_chatapp',
      navigatorKey: getIt<AppRouter>().navigatorKey,  // Set the navigator key for routing
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      home: const LoginScreen(),      // login screen
      );        
    
  }
}

