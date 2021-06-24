import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing/services/auth.dart';

// ignore: must_be_immutable
class CarDetailsScreen extends StatelessWidget {
  final String firstName, lastName, email, phone, password;
  final bool isDriver;

  CarDetailsScreen({this.firstName, this.lastName, this.email, this.phone, this.password, this.isDriver});

  static const String idScreen = "carInfo";

  TextEditingController carModelController = TextEditingController();
  TextEditingController carNumberController = TextEditingController();
  TextEditingController carColourController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 22),
              Padding(
                padding: EdgeInsets.fromLTRB(22, 22, 22, 32),
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    Text("Enter Car Details", style: TextStyle(fontSize: 22)),
                    SizedBox(height: 26),
                    TextField(
                      controller: carModelController,
                      decoration: InputDecoration(
                        hintText: "Car Model",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: carNumberController,
                      decoration: InputDecoration(
                        hintText: "Car Number",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: carColourController,
                      decoration: InputDecoration(
                        hintText: "Car Colour",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(height: 10),
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
                        if (carModelController.text.isEmpty) {
                          displayToastMessage("Car Model is empty", context);
                        } else if (carNumberController.text.isEmpty) {
                          displayToastMessage("Car Number is empty", context);
                        } else if (carColourController.text.isEmpty) {
                          displayToastMessage("Car Colour is empty", context);
                        } else {
                          saveDetails(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Saving car details to database
  void saveDetails(context) {
    register(firstName, lastName, email, phone, password, carModelController.text, carNumberController.text,
        carColourController.text, context, isDriver);
  }
}
