import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_sharing/driver/screens/home.dart';
import 'package:ride_sharing/data/updateVariables.dart';
import 'package:ride_sharing/rider/screens/home.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/screens/login.dart';
import 'package:ride_sharing/screens/registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  firebaseUser = FirebaseAuth.instance.currentUser;

  runApp(MyApp());
}

DatabaseReference usersReference = FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversReference = FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference rideRequestReference = driversReference.child(firebaseUser.uid).child("newRide");
DatabaseReference requestReference = driversReference.child(firebaseUser.uid).child("requests");
DatabaseReference newRequestReference = FirebaseDatabase.instance.reference().child("Ride Requests");

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UpdateVariables(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : HomeScreen.idScreen,
        // initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : DriverHomeScreen.idScreen,

        initialRoute: LoginScreen.idScreen,


        routes: {
          LoginScreen.idScreen: (context) => LoginScreen(),
          RegistrationScreen.idScreen: (context) => RegistrationScreen(),
          HomeScreen.idScreen: (context) => HomeScreen(),
          DriverHomeScreen.idScreen: (context) => DriverHomeScreen(),
        },
      ),
    );
  }
}
