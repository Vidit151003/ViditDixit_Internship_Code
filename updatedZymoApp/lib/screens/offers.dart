import 'package:flutter/material.dart';

import 'package:letzrentnew/Utils/constants.dart';

class OfferPage extends StatelessWidget {
  static const routeName = '/Offers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Offers'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "No Offers right now...",
              style: bigTitleStyle,
              textAlign: TextAlign.center,
            ),
            Text(
              "New Offers Coming Soon!",
              textAlign: TextAlign.center,

              // style: bigTitleStyle,
            ),
          ],
        ));
  }
}
