import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:letzrentnew/Services/firebase_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/providers/car_provider.dart';
import 'package:provider/provider.dart';

class RewardsScreen extends StatelessWidget {
  static const routeName = '/rewards-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          title: Text(
            'My Vouchers',
            style: TextStyle(fontFamily: 'Poppins-Bold'),
          )),
      body: VoucherWidget(),
    );
  }
}

class VoucherWidget extends StatelessWidget {
  final String type;

  VoucherWidget({super.key, this.type= ''});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseServices().getUserVouchers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: spinkit);
          }

          if ((snapshot.data?.docs.length ?? 0) == 0) {
            return Center(
              child: Text(
                'No Vouchers available.',
              ),
            );
          }

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data?.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final Map<String, dynamic>? doc = snapshot.data?.docs[index].data();
              return VoucherTile(
                  image: 'dev_assets/new_logo.jpeg',
                  amount: double.parse('${doc?['amount']}'),
                  validFor: doc?['validFor'],
                  validFrom: doc?['validFrom'],
                  validTill: doc?['validTill'],
                  id: snapshot.data!.docs[index].id,
                  type: type);
            },
          );
        });
  }
}

class VoucherTile extends StatelessWidget {
  final String id;
  final String image;
  final String validFrom;
  final double amount;
  final String validFor;
  final String type;
  final String validTill;
  const VoucherTile({
    super.key,
    required this.type,
    required this.id,
    this.image='',
    this.validFrom='',
    this.amount=0,
    this.validFor='',
    this.validTill='',
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime bookingDate =
        validFrom != null ? dateFormatter.parse(validFrom) : now;
    final DateTime? validT =
        validTill != null ? dateFormatter.parse(validTill) : null;
    final DateTime validTillDateTime =
        validT ?? bookingDate.add(Duration(days: 182));

    final String validFromDate = DateFormat('dd MMM, yyyy').format(bookingDate);
    final String validTillDate = DateFormat('dd MMM, yyyy')
        .format(validTillDateTime ?? DateTime.now().add(Duration(days: 182)));
    final bool isExpired =
        !DateTime.now().difference(validTillDateTime).isNegative;
    final bool isApplicable = (type == validFor || validFor == 'any' || validFor == 'all') &&
        !isExpired &&
        bookingDate.isBefore(now);

    return Container(
      height: 0.2.sh,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: InkWell(
          onTap: () =>
              isApplicable ? voucherFunction(amount, id, context) : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.black26,
                  backgroundImage: AssetImage(
                    image,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$rupeeSign${amount.toStringAsFixed(0)}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' OFF',
                          style: contentStyle,
                        )
                      ],
                    ),
                    Text(
                      'ON ${getBookingName(validFor).toUpperCase()}',
                      style: contentStyle,
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      'Valid from $validFromDate',
                      style: smallText,
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      'Valid till $validTillDate',
                      style: smallText,
                      textAlign: TextAlign.end,
                    ),
                    SizedBox(
                      height: .01.sh,
                    ),
                    if (isExpired)
                      const Chip(
                          label: Text('Expired'), backgroundColor: Colors.red)
                    else Align(
                      alignment: Alignment.bottomRight,
                      child: Chip(
                        label:
                            Text(isApplicable ? 'Apply' : 'Not applicable'),
                        backgroundColor:
                            isApplicable ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getBookingName(doc) {
    switch (doc) {
      case 'cars':
        return 'Car bookings';
        break;
      case 'coLiving':
        return 'CoLiving bookings';
        break;
      default:
        return 'All bookings';
    }
  }

  void voucherFunction(
      double discount, String voucherId, BuildContext context) async {
    final CarProvider promoprovider =
        Provider.of<CarProvider>(context, listen: false);
    promoprovider.promoCodeApply(discount);
    promoprovider.setVoucherId(voucherId);
    mixpanel.track('Voucher applied', properties: {'Discount': discount});
    Navigator.of(context).pop();

    voucherPopUp(context, 'Voucher applied successfully!',
        'You saved $rupeeSign ${promoprovider.discountPrice}!');
  }
}
