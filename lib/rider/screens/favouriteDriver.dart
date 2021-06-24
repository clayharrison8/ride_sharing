import 'package:flutter/material.dart';
import 'package:ride_sharing/rider/model/favouriteDrivers.dart';
import 'package:ride_sharing/driver/model/history.dart';

import '../../widgets/historyInfo.dart';

class FavouriteDriverScreen extends StatelessWidget {
  final FavouriteDriver favouriteDriver;
  final List<History> favDriverHistory;

  FavouriteDriverScreen({this.favouriteDriver, this.favDriverHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip History"),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.black,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CircleAvatar(backgroundImage: AssetImage('images/profile.png'), radius: 60),
                    SizedBox(height: 10),
                    Text(
                      favouriteDriver.name,
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Total Trips",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              favDriverHistory.length.toString(),
                              style: TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              "Rating",
                              style: TextStyle(color: Colors.white),
                            ),
                            Row(
                              children: [
                                Text(
                                  favouriteDriver.rating,
                                  style: TextStyle(color: Colors.white, fontSize: 25),
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 25,
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Your Trip History",
              style: TextStyle(fontSize: 20),
            ),
            Divider(color: Colors.black),
            ListView.separated(
                itemBuilder: (context, index) {
                  return HistoryInfo(
                    historyInfo: favDriverHistory[index],
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey),
                itemCount: favDriverHistory.length,
                physics: ClampingScrollPhysics(),
                shrinkWrap: true),
          ],
        ),
      ),
    );
  }
}
