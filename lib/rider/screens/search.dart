import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_sharing/assist/request.dart';
import 'package:ride_sharing/data/updateVariables.dart';
import 'package:ride_sharing/model/address.dart';
import 'package:ride_sharing/rider/model/autocomplete.dart';
import 'package:ride_sharing/appVariables.dart';

class Search extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<Search> {
  List<AutoComplete> autoCompleteList = [];
  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropOffController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String address = Provider.of<UpdateVariables>(context).pickupAddress.name ?? "";
    pickUpController.text = address;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: 215.0,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                blurRadius: 6.0,
              ),
            ]),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Center()
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.home),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: TextField(
                              controller: pickUpController,
                              decoration: InputDecoration(
                                hintText: "Pickup Location",
                                fillColor: Colors.grey[200],
                                // filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_pin),
                      SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: TextField(
                              onChanged: (val) {
                                getPredictions(val);
                              },
                              controller: dropOffController,
                              decoration: InputDecoration(
                                hintText: "Where to?",
                                fillColor: Colors.grey[200],
                                // filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          (autoCompleteList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return AutoCompleteList(
                        autoComplete: autoCompleteList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.black),
                    itemCount: autoCompleteList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  // Getting predictions from google maps based on what user has typed
  void getPredictions(String name) async {
    if (name.length > 1) {
      // Making request to get predictions from Google
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$name&key=$key&sessiontoken=1234567890&components=country:usa";
      var response = await Request.makeRequest(url);

      if (response["status"] == "OK") {
        var predictions = response["predictions"];

        // Converting json request into list
        var predictionList = (predictions as List).map((e) => AutoComplete.fromJson(e)).toList();

        // Updating list displayed to user
        setState(() {
          autoCompleteList = predictionList;
        });
      } else {
        print("Failed");
      }
    }
  }
}

// Item to display each search result
class AutoCompleteList extends StatelessWidget {
  final AutoComplete autoComplete;

  AutoCompleteList({
    Key key,
    this.autoComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        getPlace(autoComplete.id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              width: 10,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        autoComplete.mainText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        autoComplete.secondaryText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Making request to google and getting info about drop off address
  void getPlace(String place, context) async {

    String url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$place&key=$key";

    var request = await Request.makeRequest(url);

    // Setting drop off address
    if (request["status"] == "OK") {
      String name = request["result"]["formatted_address"];
      double latitude = request["result"]["geometry"]["location"]["lat"];
      double longitude = request["result"]["geometry"]["location"]["lng"];

      Address address = Address(name, place, latitude, longitude);

      Provider.of<UpdateVariables>(context, listen: false).updateDropOffAddress(address);

      Navigator.pop(context, "getDirections");
    }
  }
}
