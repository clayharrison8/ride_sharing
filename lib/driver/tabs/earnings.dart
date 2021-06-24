import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ride_sharing/appVariables.dart';
import 'package:ride_sharing/data/updateVariables.dart';
import 'package:ride_sharing/widgets/historyInfo.dart';

class Earnings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  CircleAvatar(backgroundImage: AssetImage('images/profile.png'), radius: 60),
                  SizedBox(height: 10),
                  Text(
                    drivers.firstName,
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  Text(
                    drivers.carModel + " - " + drivers.carNumber,
                    style: TextStyle(color: Colors.white, fontSize: 15),
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
                            Provider.of<UpdateVariables>(context, listen: false).tripsNum.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),

                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "Total Earnings",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "\$${Provider.of<UpdateVariables>(context, listen: false).earnings}",
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
                                drivers.rating,
                                style: TextStyle(color: Colors.white, fontSize: 25),
                              ),
                              Icon(Icons.star, color: Colors.white, size: 25,)
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
          ListView.separated(
              itemBuilder: (context, index) {
                return HistoryInfo(
                  historyInfo: Provider.of<UpdateVariables>(context, listen: false).tripInfo[index],
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey),
              itemCount: Provider.of<UpdateVariables>(context, listen: false).tripInfo.length,
              physics: ClampingScrollPhysics(),
              shrinkWrap: true),
        ],
      ),
    );
  }
}
