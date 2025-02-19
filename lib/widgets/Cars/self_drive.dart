import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letzrentnew/Services/car_functions.dart';
import 'package:letzrentnew/Services/car_services.dart';
import 'package:letzrentnew/Utils/widgets.dart';
import 'package:letzrentnew/models/car_model.dart';
import 'package:letzrentnew/Utils/constants.dart';
import 'package:letzrentnew/providers/car_provider.dart';
import 'package:letzrentnew/providers/home_provider.dart';
import 'package:provider/provider.dart';

class SelfDrive extends StatelessWidget {
  static const routeName = 'Self Drive Cars';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(SelfDrive.routeName),
        ),
        body: SingleChildScrollView(
          child: Consumer<CarProvider>(
            builder: (BuildContext context, value, _) => Column(
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Image.asset(
                      'assets/images/onboarding_images/earn.jpeg',
                      height: 0.25.sh,
                    ),
                  ),
                ),
                SizedBox(height: 0.02.sh),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: durationPicker(context, value),
                        ),
                      ),
                      SizedBox(height: 0.01.sh),
                      PickLocationWidget(),
                      SizedBox(height: 0.01.sh),
                      TripDurationWidget(duration: value.getTripDuration()),
                    ],
                  ),
                ),
                SizedBox(height: 0.02.sh),
                SizedBox(
                  height: 0.06.sh,
                  child: value.isLoading
                      ? CircularProgressIndicator()
                      : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: AppButton(
                      title: 'Search',
                      screenHeight: 1.sh,
                      function: () => CarFunctions.selfDriveNavigate(context), textSize:12, color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 0.01.sh),
                RecentSearches(provider: value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class RecentSearches extends StatelessWidget {
  final CarProvider provider;

  const RecentSearches({super.key, required this.provider});
  @override
  Widget build(BuildContext context) {
    final HomeProvider value =
        Provider.of<HomeProvider>(context, listen: false);
    return FutureBuilder<DriveModel>(
        future: value.getRecentSearch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }
          final DriveModel model = snapshot.data!;
          return Container(
            width: double.infinity,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: InkWell(
                onTap: () => setDateAndTime(model, context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Recent Search: ${model.remainingDuration}',
                        style: bigHeadingStyle,
                      ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // Text(
                      //   '${model.remainingDuration}',
                      //   style: headingStyle,
                      // ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        CarServices.getDurationText(
                            DriveTypes.SD,
                            model.startDate,
                            model.endDate,
                            model.starttime,
                            model.endtime,
                            5),
                        style: contentStyle,
                      ),
                      Text(
                        'Tap to search',
                        style: titleStyle,
                      ),
                    ],
                  ),
                ),
              ),
              // elevation: 5,
              // child: ListTile(
              //     onTap: () => setDateAndTime(model, context),
              //     contentPadding:
              //         EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              //     title:
              //         Text('Recent Search: ${model.remainingDuration}'),
              //     subtitle: Text(CarServices.getDurationText(
              //         DriveTypes.SD,
              //         model.startDate,
              //         model.endDate,
              //         model.starttime,
              //         model.endtime,
              //         5)),
              //     trailing: Icon(Icons.arrow_right)),
            ),
          );
          return Container();
        });
  }

  void setDateAndTime(DriveModel model, BuildContext context) {
    try {
      provider.setStartAndEndDate(dateFormatter.parse(model.startDate),
          dateFormatter.parse(model.endDate));
      provider.setStartTime(
          TimeOfDay.fromDateTime(timeFormat.parse(model.starttime)));
      provider.setEndTime(
          TimeOfDay.fromDateTime(timeFormat.parse(model.endtime)));
      CarFunctions.selfDriveNavigate(context);
    } catch (e) {
      mixpanel.track('duration', properties: {'issue': e});
    }
  }
}
