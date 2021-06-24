import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing/driver/screens/carDetails.dart';
import 'package:ride_sharing/services/auth.dart';
import 'package:ride_sharing/services/formValidation.dart';

import 'login.dart';

class RegistrationScreen extends StatefulWidget {
  // Tracking current screen
  static const String idScreen = "register";

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController firstNameController = TextEditingController();

  TextEditingController lastNameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  final FormValidation validation = FormValidation();
  bool isSwitched = false;
  String buttonText = "Register";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                Text(
                  "Register",
                  style: TextStyle(fontSize: 24.0),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: firstNameController,
                        decoration: InputDecoration(hintText: "First Name", hintStyle: TextStyle(color: Colors.grey)),
                      ),
                      TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(hintText: "Last Name", hintStyle: TextStyle(color: Colors.grey)),
                      ),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(hintText: "Email", hintStyle: TextStyle(color: Colors.grey)),
                      ),
                      TextField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Phone Number", hintStyle: TextStyle(color: Colors.grey)),
                      ),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Confirm Password",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Rider"),
                          Switch(
                            value: isSwitched,
                            onChanged: (value) {
                              setState(() {
                                isSwitched = value;
                                !isSwitched ? buttonText = "Next" : buttonText = "Register";
                              });
                            },
                            activeTrackColor: Colors.grey,
                            activeColor: Colors.black,
                          ),
                          Text("Driver")
                        ],
                      ),
                      RaisedButton(
                        color: Colors.black,
                        textColor: Colors.white,
                        child: Center(
                          child: Text(
                            "Register",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        onPressed: () {
                          registerUser();
                        },
                      ),
                      FlatButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                          },
                          child: Text("Already have an account? here"))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void registerUser() {
    String validateEmail = validation.validateEmail(emailController.text);
    String validatePassword = validation.validatePassword(passwordController.text);
    if (validateEmail == "Valid" &&
        validatePassword == "Valid" &&
        confirmPasswordController.text == passwordController.text) {
      !isSwitched
          ? register(firstNameController.text, lastNameController.text, emailController.text,
          phoneNumberController.text, passwordController.text, "", "", "", context, isSwitched)
          : Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CarDetailsScreen(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            email: emailController.text,
            phone: phoneNumberController.text,
            password: passwordController.text,
            isDriver: isSwitched,
          ),
        ),
      );
    }
  }
}
