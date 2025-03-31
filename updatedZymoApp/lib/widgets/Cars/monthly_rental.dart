import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letzrentnew/Services/car_functions.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/Utils/widgets.dart';
import 'package:letzrentnew/providers/car_provider.dart';
import 'package:provider/provider.dart';

class MonthlyRental extends StatelessWidget {
  const MonthlyRental({Key? key}) : super(key: key);
  static const routeName = 'Monthly Car Rental';

  @override
  Widget build(BuildContext context) {
    // Ensure mixpanel is initialized properly
    mixpanel.track('Monthly rental page');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(MonthlyRental.routeName),
      ),
      body: Consumer<CarProvider>(
        builder: (BuildContext context, value, Widget? child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            children: [
              SizedBox(height: 0.07.sh),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Icon(
                  Icons.car_rental,
                  size: 0.15.sh,
                ),
              ),
              Text(
                'Select date and time',
                style: TextStyle(color: Colors.black45, fontSize: 19),
              ),
              SizedBox(height: 0.04.sh),
              atDurationPicker(context, value),
              SizedBox(height: 0.02.sh),
              TripDurationWidget(duration: '30 Days'),
              SizedBox(height: 0.02.sh),
              value.isLoading
                  ? CircularProgressIndicator() // Use a default loading widget
                  : AppButton(
                title: 'Search',
                screenWidth: 1.sw,
                screenHeight: 1.sh,
                function: () => CarFunctions().monthlyRentalNavigate(context), textSize: 12, color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
