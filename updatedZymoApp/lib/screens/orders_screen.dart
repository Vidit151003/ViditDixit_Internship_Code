import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letzrentnew/Services/auth_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Screens/order_widget.dart';
import 'package:letzrentnew/models/booking_model.dart';
import 'package:letzrentnew/screens/home_page.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = 'MyOrders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  User? get user => Auth().getCurrentUser();

  Stream<QuerySnapshot> getStream(String collectionName) {
    return FirebaseFirestore.instance
        .collection(collectionName)
        .where("userId", isEqualTo: user?.uid) // Ensure filtering by user
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        ModalRoute.of(context)?.settings.arguments as String? ?? "Your";

    return Scaffold(
      appBar: AppBar(
        title: Text('$title Orders'),
      ),
      body: user == null
          ? NoUserError(
              message: "Log in to see your profile",
              onLogin: () => setState(() {}),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: getStream(title),
              builder: (ctx, chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting &&
                    !chatSnapshot.hasData) {
                  return Center(
                    child: spinkit,
                  );
                }

                final List<QueryDocumentSnapshot<Object?>> docs =
                    chatSnapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.magnifyingGlass),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'No past orders found.',
                            textAlign: TextAlign.center,
                            style: headingStyle,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, title),
                          child: Text('Checkout $title'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColor,
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  // ✅ Sorting Orders by DateOfBooking
                  docs.sort((a, b) {
                    final Timestamp? aTimestamp = a.data() != null
                        ? (a['DateOfBooking'] as Timestamp?)
                        : null;
                    final Timestamp? bTimestamp = b.data() != null
                        ? (b['DateOfBooking'] as Timestamp?)
                        : null;

                    if (aTimestamp != null && bTimestamp != null) {
                      return bTimestamp.toDate().compareTo(aTimestamp.toDate());
                    } else {
                      return 0;
                    }
                  });

                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (ctx, index) {
                      final Map<String, dynamic> data =
                          docs[index].data() as Map<String, dynamic>;
                      final BookingModel model = BookingModel.fromJson(data);
                      final String id = docs[index].id;

                      return OrderTile(documentId: id, bookingModel: model);
                    },
                  );
                }
              },
            ),
    );
  }
}

Stream getStream(String title) {
  final String? uid = Auth().getCurrentUser()?.uid;
  switch (title) {
    case 'Self Drive Cars':
      return FirebaseFirestore.instance
          .collection(carsPaymentSuccessDetails)
          .where('UserId', isEqualTo: uid)
          .where('Drive', isEqualTo: 'Sd')
          .snapshots();
      break;
    case 'Rent Pay':
      return FirebaseFirestore.instance
          .collection('RentPayPaymentSuccessDetails')
          .where('userid', isEqualTo: uid)
          .snapshots();
      break;
    case 'Monthly Car Rental':
      return FirebaseFirestore.instance
          .collection(carsPaymentSuccessDetails)
          .where('UserId', isEqualTo: uid)
          .where('Drive', isEqualTo: 'subscription')
          .snapshots();
      break;
    default:
      return FirebaseFirestore.instance
          .collection(carsPaymentSuccessDetails)
          .where('UserId', isEqualTo: uid)
          .snapshots();
  }
}
