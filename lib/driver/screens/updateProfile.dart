import 'package:flutter/material.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/driver/tabs/profile.dart';
import 'package:ride_sharing/main.dart';
import 'package:ride_sharing/rider/screens/profile.dart';

class UpdateDriverProfile extends StatefulWidget {
  @override
  _UpdateDriverProfileState createState() => _UpdateDriverProfileState();
}

class _UpdateDriverProfileState extends State<UpdateDriverProfile> {
  var textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 30),
          Align(
            alignment: Alignment.topLeft,
            child: new IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 50),
                TextField(
                  controller: textEditingController,
                  obscureText: profileString == "Password" ? true : false,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: profileClicked,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: profileString,
                      hintStyle: TextStyle(fontSize: 16, color: Colors.black)),
                ),
                RaisedButton(
                  color: Colors.black,
                  textColor: Colors.white,
                  child: Center(
                    child: Text(
                      "Update " + profileClicked,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  onPressed: () {
                    updateProfile(textEditingController.text, context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void updateProfile(String newValue, context) {
  switch (profileClicked) {
    case "First Name":
      {
        driversReference.child(firebaseUser.uid).child("First Name").set(newValue);
        drivers.firstName = newValue;
      }
      break;

    case "Last Name":
      {
        driversReference.child(firebaseUser.uid).child("Last Name").set(newValue);
        drivers.lastName = newValue;
      }
      break;
    case "Phone Number":
      {
        driversReference.child(firebaseUser.uid).child("Phone Number").set(newValue);
        drivers.phoneNumber = newValue;
      }
      break;
    case "Email":
      {
        updateEmail(newValue);
        driversReference.child(firebaseUser.uid).child("Email").set(newValue);
        drivers.email = newValue;
      }
      break;
    case "Password":
      {
        var message;
        firebaseUser
            .updatePassword(newValue)
            .then(
              (value) => message = 'Success',
            )
            .catchError((onError) => message = 'error');
        return message;
      }
      break;
    case "Car Model":
      {
        driversReference.child(firebaseUser.uid).child("car_details").child("car_model").set(newValue);
        drivers.carModel = newValue;
      }
      break;
    case "Car Number":
      {
        driversReference.child(firebaseUser.uid).child("car_details").child("car_number").set(newValue);
        drivers.carNumber = newValue;
      }
      break;
    case "Car Colour":
      {
        driversReference.child(firebaseUser.uid).child("car_details").child("car_colour").set(newValue);
        drivers.carColour = newValue;
      }
      break;
  }

  Navigator.pop(context);
}

Future updateEmail(String newEmail) async {
  var message;
  firebaseUser
      .updateEmail(newEmail)
      .then(
        (value) => message = 'Success',
      )
      .catchError((onError) => message = 'error');
  return message;
}
