import 'package:flutter/material.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/constants.dart';

import 'orders_screen.dart';

class MyBookings extends StatelessWidget {
  static const routeName = '/different-orders';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: gradientColors)),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'My Bookings',
              style: bigWhiteTitleStyle,
            ),
            Spacer(),
            InkWell(
                onTap: () => Navigator.pushNamed(
                    context, OrdersScreen.routeName,
                    arguments: '${AppData.allCategories[0]['title']}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(AppData.allCategories[0]['image']!),
                )),
            Spacer(),
            InkWell(
              onTap: () => Navigator.pushNamed(context, OrdersScreen.routeName,
                  arguments: '${AppData.allCategories[1]['title']}'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(AppData.allCategories[1]['image']!),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            //  Expanded(
            //     child: GridView.builder(
            //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //             crossAxisCount: 2),
            //         itemCount: AppData.allCategories.length,
            //         itemBuilder: (context, index) {
            //           return Padding(
            //             padding: const EdgeInsets.all(8.0),
            //             child: AllCategoryWidget(
            //               title: AppData.allCategories[index]['title'],
            //               image: AppData.allCategories[index]['image'],
            //               function: () => Navigator.pushNamed(
            //                   context, OrdersScreen.routeName,
            //                   arguments:
            //                       '${AppData.allCategories[index]['title']}'),
            //               //  url: e['url'],
            //             ),
            //           );
            //         }),
            //   ),
          ],
        ),
      ),
    );
  }
}
