import 'package:flutter/cupertino.dart';
import 'package:letzrentnew/Screens/auth_screens/login_screen.dart';
import 'package:letzrentnew/Screens/contact_us.dart';
import 'package:letzrentnew/Screens/documents_upload.dart';
import 'package:letzrentnew/Screens/FAQs.dart';
import 'package:letzrentnew/Screens/my%20orders.dart';
import 'package:letzrentnew/Screens/offers.dart';
import 'package:letzrentnew/Screens/orders_screen.dart';
import 'package:letzrentnew/Screens/referral_screen.dart';
import 'package:letzrentnew/Screens/Rewards/vouchers_screen.dart';
import 'package:letzrentnew/Screens/submit_success_screen.dart';
import 'package:letzrentnew/Screens/tabs_screen.dart';
import 'package:letzrentnew/Screens/user_profile.dart';
import 'package:letzrentnew/Widgets/Cars/monthly_rental.dart';
import 'package:letzrentnew/Widgets/Cars/payment_fail.dart';
import 'package:letzrentnew/Widgets/Cars/payment_success.dart';
import 'package:letzrentnew/Widgets/Cars/self_drive.dart';
import 'package:letzrentnew/Widgets/Cars/user_booking_screen.dart';
class PageRoutes {
 static Map<String, WidgetBuilder> get routes {
    return {
      OrdersScreen.routeName: (ctx) => OrdersScreen(),
      SelfDrive.routeName: (ctx) => SelfDrive(),
      UserBookingScreen.routeName: (ctx) => UserBookingScreen(),
      TabScreen.routeName: (ctx) => TabScreen(),
      SubmitSuccessScreen.routeName: (ctx) => SubmitSuccessScreen(),
      SuccessPage.routeName: (ctx) => SuccessPage(),
      FailedPage.routeName: (ctx) => FailedPage(),
      MonthlyRental.routeName: (ctx) => MonthlyRental(),
      UserProfile.routeName: (ctx) => UserProfile(),
      DocumentsUpload.routeNmae: (ctx) => DocumentsUpload(),
      Help.routeName: (ctx) => Help(),
      ContactUs.routeName: (ctx) => ContactUs(),
      MyBookings.routeName: (ctx) => MyBookings(),
      // AircraftsFilterScreen.routeNmae: (ctx) => AircraftsFilterScreen(),
      // AircraftsGrid.routeName: (ctx) => AircraftsGrid(),
      // AircraftsBooking.routeName: (ctx) => AircraftsBooking(),
      // ConfirmAircraftsBooking.routeName: (ctx) => ConfirmAircraftsBooking(),
      // RentPay.routeNmae: (ctx) => RentPay(),
      RewardsScreen.routeName: (ctx) => RewardsScreen(),
      OfferPage.routeName: (ctx) => OfferPage(),
      LoginScreen.routeName: (ctx) => LoginScreen(),
      ReferralScreen.routeName: (ctx) => ReferralScreen(),
    };
  }
}
