import 'package:flutter/material.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/rider/screens/updateProfile.dart';

class RiderProfile extends StatefulWidget {
  @override
  _RiderProfileState createState() => _RiderProfileState();
}

class _RiderProfileState extends State<RiderProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topLeft,
              child: new IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
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
                  hintText: currentUser.firstName,
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
                  hintText: currentUser.lastName,
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
                  hintText: currentUser.email,
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
                  hintText: currentUser.phoneNumber,
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
          ],
        ),
      ),
    );
  }
}

void profileTextDisplayed(String string) {
  switch (string) {
    case "First Name":
      {
        profileString = currentUser.firstName;
      }
      break;

    case "Last Name":
      {
        profileString = currentUser.lastName;
      }
      break;
    case "Email":
      {
        profileString = currentUser.email;
      }
      break;
    case "Phone Number":
      {
        profileString = currentUser.phoneNumber;
      }
      break;
    case "Password":
      {
        profileString = "*********";
      }
      break;
  }
}

void updateProfile(String string, context) {
  profileClicked = string;
  profileTextDisplayed(profileClicked);
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdateRiderProfile()));
}
