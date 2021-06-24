import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ride_sharing/assist/assistant.dart';
import 'package:ride_sharing/driver/screens/home.dart';
import 'package:ride_sharing/model/users.dart';
import 'package:ride_sharing/rider/screens/home.dart';

import '../appVariables.dart';
import '../main.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");

void login(String email, String password, BuildContext context, bool isDriver) async {
  // Gets user with email and password entered
  final User logInUser =
      (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password).catchError((errmsg) {
    displayToastMessage("Error: " + errmsg.toString(), context);
  }))
          .user;

  // If user exists, redirect to main screen, else sign out
  if (logInUser != null) {
    if (isDriver == true) {
      driversReference.child(logInUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(context, DriverHomeScreen.idScreen, (route) => false);
          displayToastMessage("Success", context);
        } else {
          displayToastMessage("You're not registered as a driver", context);
        }
      });
    } else {
      usersRef.child(logInUser.uid).once().then((DataSnapshot snap) async {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.idScreen, (route) => false);
          displayToastMessage("Success", context);
        } else {
          displayToastMessage("You're not registered as a rider", context);
        }
      });
    }
  } else {
    displayToastMessage("User has not been created", context);
  }
}

void register(String firstName, String lastName, String email, String phone, String password, String carModel,
    String carNumber, String carColour, BuildContext context, bool isDriver) async {
  final User registerUser =
      (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).catchError((errmsg) {
    displayToastMessage("Error: " + errmsg.toString(), context);
  }))
          .user;

  if (registerUser != null) {
    if (isDriver == true) {
      Map carDetailsMap = {"car_colour": carColour, "car_number": carNumber, "car_model": carModel};

      Map userDataMap = {
        "First Name": firstName,
        "Last Name": lastName,
        "Email": email,
        "Phone Number": phone,
        "car_details": carDetailsMap,
        "rating": "0.00"
      };

      // Add new driver to database and go to car details screen
      driversReference.child(registerUser.uid).set(userDataMap);
      firebaseUser = registerUser;
      Navigator.pushNamedAndRemoveUntil(context, DriverHomeScreen.idScreen, (route) => false);

      displayToastMessage("User added", context);
    } else {
      // Saving user data to database
      usersRef.child(registerUser.uid);

      Map userDataMap = {
        "First Name": firstName,
        "Last Name": lastName,
        "Email": email,
        "Phone Number": phone,
        "rating": "0.00"
      };

      usersRef.child(registerUser.uid).set(userDataMap);

      displayToastMessage("User added", context);

      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.idScreen, (route) => false);
    }
  } else {
    displayToastMessage("User has not been created", context);
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
