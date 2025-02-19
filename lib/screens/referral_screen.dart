import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letzrentnew/Services/dynamic_links_service.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/functions.dart';
// import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});
  static const String routeName = 'ReferralScreen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Refer & Earn'),
        ),
        body: FutureBuilder<String?>(
          future: DynamicLinksService().createDynamicLink(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: spinkit);
            } else if (snapshot.hasError || !snapshot.hasData) {
              print(snapshot.error);
              return Center(
                child: Text(
                  'Log In to continue...',
                  style: largeBlackStyle,
                ),
              );
            } else {
              final referralText = /*getReferralText(snapshot.data ??*/ "Default Referral Text";/*);*/
              return SizedBox(
                width: 1.sw,
                height: 1.sh,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Refer $appName to a friend',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: .01.sh),
                      Text(
                        'And you both win vouchers worth Rs.$referralAmount!',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15),
                      ),
                      SizedBox(height: .06.sh),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(.5),
                            foregroundColor: Theme.of(context).primaryColor,
                            radius: .07.sw,
                            child: Text('1',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ),
                          SizedBox(width: 20),
                          Text('Invite using link', style: headingStyle),
                        ],
                      ),
                      SizedBox(height: .03.sh),
                      InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              )),
                        ),
                        child: Text(snapshot.data!, style: TextStyle(color: Colors.black54)),
                      ),
                      SizedBox(height: .03.sh),
                      Row(
                        children: [
                          Tiles(
                            color: Colors.green,
                            icon: FontAwesomeIcons.whatsapp,
                            text: "WhatsApp",
                            func: () => CommonFunctions.whatsappFunction(referralText),
                          ),
                          Tiles(
                            color: Colors.blue,
                            icon: FontAwesomeIcons.copy,
                            text: "Copy Link",
                            func: () => Clipboard.setData(ClipboardData(text: snapshot.data!))
                                .then((_) => CommonFunctions.showSnackbar(context, 'Copied to clipboard')),
                          ),
                          Tiles(
                            color: Colors.green,
                            icon: FontAwesomeIcons.shareFromSquare,
                            text: "More",
                            func: null,
                          ),
                        ],
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {}, // => Share.share(referralText),
                        child: Text("Share Link"),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}


class Tiles extends StatelessWidget {
  final Function? func;
  final IconData icon;
  final Color color;
  final String text;
  const Tiles({
    super.key,
    required this.func,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: (){func;},
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
            ),
            SizedBox(
              height: 8,
            ),
            Text(text)
          ],
        ),
      ),
    );
  }
}
