import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/driver/screens/updateProfile.dart';
import 'package:ride_sharing/main.dart';
import 'package:ride_sharing/screens/login.dart';

class DriverProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                "Edit account",
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
              ),
              SizedBox(height: 30),
              CircleAvatar(backgroundImage: AssetImage('images/profile.png'), radius: 60),
              SizedBox(height: 30),
              TextField(
                onTap: () {
                  updateProfile("First Name", context);
                },
                readOnly: true,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    labelText: "First Name",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: drivers.firstName,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              TextField(
                onTap: () {
                  updateProfile("Last Name", context);
                },
                readOnly: true,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    labelText: "Last Name",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: drivers.lastName,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              TextField(
                onTap: () {
                  updateProfile("Email", context);
                },
                readOnly: true,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    labelText: "Email",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: drivers.email,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              TextField(
                onTap: () {
                  updateProfile("Phone Number", context);
                },
                readOnly: true,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    labelText: "Phone Number",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: drivers.phoneNumber,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              TextField(
                onTap: () {
                  updateProfile("Car Number", context);
                },
                readOnly: true,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    labelText: "Car Number",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: drivers.carNumber,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              TextField(
                onTap: () {
                  updateProfile("Car Model", context);
                },
                readOnly: true,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    labelText: "Car Model",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: drivers.carModel,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              TextField(
                onTap: () {
                  updateProfile("Car Colour", context);
                },
                readOnly: true,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    labelText: "Car Colour",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: drivers.carColour,
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              TextField(
                onTap: () {
                  updateProfile("Password", context);
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    labelText: "Password",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "*********",
                    hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),

              GestureDetector(
                onTap: () {
                  Geofire.removeLocation(firebaseUser.uid);
                  rideRequestReference.onDisconnect();
                  rideRequestReference.remove();
                  rideRequestReference = null;

                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child: Card(
                  color: Colors.black,
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 110),
                  child: ListTile(
                    title: Text(
                      "Sign out",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

void profileTextDisplayed(String string) {
  switch (string) {
    case "First Name":
      {
        profileString = drivers.firstName;
      }
      break;

    case "Last Name":
      {
        profileString = drivers.lastName;
      }
      break;
    case "Email":
      {
        profileString = drivers.email;
      }
      break;
    case "Phone Number":
      {
        profileString = drivers.phoneNumber;
      }
      break;
    case "Password":
      {
        profileString = "*********";
      }
      break;
    case "Car Model":
      {
        profileString = drivers.carModel;
      }
      break;
    case "Car Number":
      {
        profileString = drivers.carNumber;
      }
      break;
    case "Car Colour":
      {
        profileString = drivers.carColour;
      }
      break;

  }
}

void updateProfile(String string, context) {
  profileClicked = string;
  profileTextDisplayed(profileClicked);
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateDriverProfile()));
}
