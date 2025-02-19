import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'FAQs.dart';

class ContactUs extends StatelessWidget {
  static const routeName = '/contactus';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: 1.sw,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 70),
                child: Text(
                  'CONTACT US ',
                  style: bigTitleStyle,
                ),
              ),
              ContactUsTile(
                  function: () async =>
                      await CommonFunctions.callUsFunction(),
                  icon: Icons.phone,
                  title: '+91 8277998715 (10.00 AM to 10.00'),
              ContactUsTile(
                  function: () async =>
                      await canLaunchUrl(Uri.parse(openWhatsApp))
                          ? launchUrl(Uri.parse(openWhatsApp))
                          : print("No whatsapp"),
                  icon: FontAwesomeIcons.whatsapp,
                  title: 'WhatsApp'),
              // ContactUsTile(
              //     function: () async =>
              //         await launchUrl(Uri.parse("mailto:$EmailContact")),
              //     icon: Icons.email,
              //     title: '$EmailContact'),
              ContactUsTile(
                  function: () =>
                      Navigator.of(context).pushNamed(Help.routeName),
                  icon: Icons.info_outline,
                  title: 'Common FAQs'),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactUsTile extends StatelessWidget {
  const ContactUsTile({
    super.key,
    required this.icon,
    required this.function,
    required this.title,
  });

  final IconData icon;
  final Function function;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 9),
      height: .1.sh,
      width: .8.sw,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 9,
        child: InkWell(
          onTap: () => function(),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon),
                SizedBox(width: 55),
                Expanded(
                  child: Text(
                    '$title',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
