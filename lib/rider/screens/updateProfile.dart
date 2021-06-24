import 'package:flutter/material.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/main.dart';
import 'package:ride_sharing/rider/screens/profile.dart';

class UpdateRiderProfile extends StatefulWidget {
  @override
  _UpdateRiderProfileState createState() => _UpdateRiderProfileState();
}

class _UpdateRiderProfileState extends State<UpdateRiderProfile> {
  var textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
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
                obscureText: profileClicked == "Password" ? true : false,
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
      ],)
    );
  }
}

void updateProfile(String newValue, context) {
  switch (profileClicked) {
    case "First Name":
      {
        usersReference.child(firebaseUser.uid).child("First Name").set(newValue);
        currentUser.firstName = newValue;
      }
      break;

    case "Last Name":
      {
        usersReference.child(firebaseUser.uid).child("Last Name").set(newValue);
        currentUser.lastName = newValue;
      }
      break;
    case "Email":
      {
        updateEmail(newValue);
        usersReference.child(firebaseUser.uid).child("Email").set(newValue);
        currentUser.email = newValue;
      }
      break;
    case "Phone Number":
      {
        usersReference.child(firebaseUser.uid).child("Phone Number").set(newValue);
        currentUser.phoneNumber = newValue;
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
  }

  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RiderProfile()));
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


