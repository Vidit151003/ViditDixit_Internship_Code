import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:letzrentnew/Screens/tabs_screen.dart';
import 'package:letzrentnew/Services/auth_services.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/screens/documents_upload.dart';
import 'package:letzrentnew/screens/home_page.dart';
import '../Utils/functions.dart';
import 'FAQs.dart';
import 'profile_details.dart';

class UserProfile extends StatefulWidget {
  static const routeName = '/User-profile';

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  User? get user => Auth().getCurrentUser();

  void alertLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          icon: const Icon(Icons.info, color: Colors.black),
          title: Text("Are you sure you want to log out?"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    backgroundColor: Colors.black87),
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () {
                  Auth().signOut().then((value) =>
                      CommonFunctions.navigateTo(context, TabScreen()));
                },
                child: Text("Log Out"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(user);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: appBarGradient,
        ),
        body: user == null
            ? NoUserError(
                message: 'Log in to view your bookings',
                onLogin: () => setState(() {}),
              )
            : SingleChildScrollView(
                child: Column(
                children: <Widget>[
                  // SizedBox(height: .02.sh),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //   child: Text(user.phoneNumber ?? '',
                  //       style: const TextStyle(
                  //         fontSize: 19,
                  //         fontWeight: FontWeight.bold,
                  //       )),
                  // ),
                  Container(
                    height: MediaQuery.of(context).size.height * .3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                    ),
                    width: double.infinity,
                    child: Image.asset(
                      'dev_assets/new_logo_trans.png',
                    ),
                  ),
                  // SizedBox(
                  //   height: .02.sh,
                  // ),
                  // ProfileTile(
                  //   icon: FontAwesomeIcons.bagShopping,
                  //   function: () =>
                  //       Navigator.of(context).pushNamed(MyBookings.routeName),
                  //   title: 'My Orders',
                  // ),
                  // ProfileTile(
                  //   icon: FontAwesomeIcons.trophy,
                  //   function: () => Navigator.of(context).pushNamed(
                  //     RewardsScreen.routeName,
                  //   ),
                  //   title: 'Rewards',
                  // ),
                  ProfileTile(
                    icon: FontAwesomeIcons.addressBook,
                    function: () =>
                        CommonFunctions.navigateTo(context, ProfileDetails()),
                    title: 'Profile',
                  ),
                  ProfileTile(
                    icon: FontAwesomeIcons.passport,
                    function: () => Navigator.of(context)
                        .pushNamed(DocumentsUpload.routeNmae),
                    title: 'My Documents',
                  ),

                  // ProfileTile(
                  //   icon: FontAwesomeIcons.tag,
                  //   function: () => Navigator.pushNamed(context, OfferPage.routeName),
                  //   title: 'Offers',
                  // ),
                  // ProfileTile(
                  //   icon: FontAwesomeIcons.moneyBill,
                  //   function: () => Navigator.of(context)
                  //       .push(MaterialPageRoute(builder: (context) {
                  //     FlutterBranchSdk.trackContentWithoutBuo(
                  //         branchEvent:
                  //             BranchEvent.customEvent('Refer a friend page opened'));
                  //     return const ReferralScreen();
                  //   })),
                  //   title: 'Refer and Win',
                  // ),
                  // ProfileTile(
                  //   icon: FontAwesomeIcons.sliders,
                  //   function: () => Navigator.of(context).push(MaterialPageRoute(
                  //       builder: (context) => const SettingsPage())),
                  //   title: 'Settings',
                  // ),
                  ProfileTile(
                    icon: FontAwesomeIcons.circleQuestion,
                    function: () =>
                        Navigator.of(context).pushNamed(Help.routeName),
                    title: 'Help',
                  ),
                  ProfileTile(
                    icon: FontAwesomeIcons.trash,
                    function: () => CommonFunctions.deleteAccount(context),
                    title: 'Delete Account',
                  ),
                  InkWell(
                    onTap: () => alertLogoutDialog(context),
                    child: SizedBox(
                      width: 1.sw,
                      height: .08.sh,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                          Text('Log Out',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ),
                ],
              )),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final Function function;
  final String title;
  const ProfileTile({
    super.key,
    required this.icon,
    required this.function,
    this.title='',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: .4)),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        leading: Icon(icon),
        minLeadingWidth: 10,
        onTap: () => function(),
        title: Text(
          title,
        ),
        trailing: const Icon(
          Icons.navigate_next,
        ),
      ),
    );
  }
}
