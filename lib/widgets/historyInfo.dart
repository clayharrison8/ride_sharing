
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing/driver/model/history.dart';

import '../assist/assistant.dart';

class HistoryInfo extends StatelessWidget {
  final History historyInfo;
  HistoryInfo({this.historyInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    Icon(Icons.home, color: Colors.black, size: 20.0),
                    SizedBox(width: 18),
                    Expanded(
                      child: Container(
                        child: Text(
                          historyInfo.pickupAddress,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[30]),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "\$" + historyInfo.fares,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.location_pin, color: Colors.black, size: 20.0),
                  SizedBox(width: 11),
                  Flexible(child: Text(historyInfo.dropOffAddress, overflow: TextOverflow.clip)),
                ],
              ),
              SizedBox(height: 15),
              Text(Assistant.formatDate(historyInfo.created), style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
