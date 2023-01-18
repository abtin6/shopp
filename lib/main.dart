import 'package:flutter/material.dart';
import 'package:shopapp/pages/shipping/cart.dart';
import 'package:shopapp/pages/profile/createAccount.dart';
import 'package:shopapp/pages/profile/forgotPassword.dart';
import 'package:shopapp/pages/profile/profile.dart';
import 'package:shopapp/pages/profile/setPassword.dart';
import 'package:shopapp/pages/settings.dart';
import 'home.dart';
import 'pages/profile/login.dart';
import 'pages/splashScreen.dart';
import 'package:flutter/services.dart';
import 'package:shopapp/constants.dart' as Const;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async{
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();

}
class MyAppState extends State<MyApp> {

  FirebaseMessaging _firebaseMessaging;
  //final fcmToken = FirebaseMessaging.instance.getToken();
  String messageList = '';


  void registerNotification() async {
    // 1. Initialize the Firebase app : need to install firebase_core
    await Firebase.initializeApp();
    // 2.
    _firebaseMessaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //print('User granted permission');
      // TODO: handle the received notifications
      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
    } else {
      print('User declined or has not accepted permission');
    }
  }
  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.getInitialMessage();
  }
  // This widget is the root of your application.
  @override
  void initState() {
    // TODO: implement initStat
    checkForInitialMessage();
    super.initState();
    registerNotification();
    // For handling notification when the app is in background
    // but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    /*final ColorScheme colorScheme = ColorScheme(
        primary: Const.LayoutColor,
        primaryVariant: Const.LayoutColor,
        secondary: Const.AccentColor,
        secondaryVariant: Const.AccentColor
    );*/
    return MaterialApp(
      title: Const.ApplicationTitle,
      theme: ThemeData(
          primaryColor: Const.LayoutColor,
          appBarTheme: AppBarTheme(
            color: Const.LayoutColor,
          ),
          //colorScheme: colorScheme,
          fontFamily: 'Vazir'
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child,
        );
      },
      routes: {
        '/' : (context) => SplashScreen(),
        '/home' : (context) => ShopAppHome(),
        '/login' : (context) => LoginScreen(),
        '/profile' : (context) => ProfileScreen(),
        '/CreateAccount' : (context) => CreateAccount(),
        '/ForgotPassword' : (context) => ForgotPassword(),
        '/setPassword' : (context) => SetPassword(),
        '/cart' : (context) => CartScreen(),
        '/setting' : (context) => SettingScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}