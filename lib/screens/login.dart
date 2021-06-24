import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:ride_sharing/services/formValidation.dart';
import 'package:ride_sharing/screens/registration.dart';
import 'package:ride_sharing/services/auth.dart';

class LoginScreen extends StatefulWidget {
  // Tracking current screen
  static const String idScreen = "login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FormValidation validation = FormValidation();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  bool isSwitched = false;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: TextStyle(fontSize: 24.0),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      key: Key("emailInput"),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      key: Key("passwordInput"),
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
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
                              print(value);
                              isSwitched = value;
                            });
                          },
                          activeTrackColor: Colors.grey,
                          activeColor: Colors.black,
                        ),
                        Text("Driver")
                      ],
                    ),

                    RaisedButton(
                      key: Key("loginButton"),
                      color: Colors.black,
                      textColor: Colors.white,
                      child: Center(
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () async {
                        String validateEmail = validation.validateEmail(emailController.text);
                        String validatePassword = validation.validatePassword(passwordController.text);
                        if (validateEmail == "Valid" && validatePassword == "Valid") {
                          setState(() {
                            showSpinner = true;
                          });
                          login(emailController.text, passwordController.text, context, isSwitched);
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      },
                    ),
                    FlatButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.idScreen, (route) => false);
                        },
                        child: Text("Do you not have an account? Register here"))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
