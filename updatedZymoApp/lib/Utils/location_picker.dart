import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:letzrentnew/Services/location_services.dart';
import 'package:letzrentnew/Utils/app_data.dart';
import 'package:letzrentnew/Utils/functions.dart';
import 'package:letzrentnew/models/user_location_model.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Services/http_services.dart';
import '../providers/home_provider.dart';
import 'constants.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  /// Result returned after user completes selection
  late LocationResult locationResult;
  List<RichSuggestion> suggestions = [];

  /// Overlay to display autocomplete suggestions

  late Timer debouncer;

  bool hasSearchTerm = false;

  String previousSearchTerm = '';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Consumer<HomeProvider>(
      builder: (BuildContext context, value, Widget? child) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Location Selection'), // You can customize the title
        ),
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select your location', style: bigTitleStyle),
              SizedBox(
                height: .03.sh,
              ),
              // Search TextField with onChanged functionality
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                  labelText: 'Search',
                ),
                onChanged: (val) {
                  value.setSearchString(val);
                  onSearchInputChange(val, value);
                },
              ),
              SizedBox(
                height: 10,
              ),
              // Location service button
              value.isLocationLoading
                  ? Container()
                  : InkWell(
                onTap: () async {
                  value.toggleLocationLoading(true);
                  try {
                    final position = await LocationService.determinePosition();
                    reverseGeocode(LatLng(position.latitude, position.longitude));
                  } catch (e) {
                    CommonFunctions.showSnackbar(context, e.toString());
                  }
                  value.toggleLocationLoading(false);
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.my_location_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Select current location',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Expanded response widget to display location data
              Expanded(
                child: SingleChildScrollView(  // Ensure content is scrollable
                  child: responseWidget(value),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget responseWidget(value) {
    if (value.isLocationLoading)
      return Center(child: spinkit);
    else if (suggestions.isNotEmpty &&
        suggestions.first.autoCompleteItem.text!.isEmpty &&
        hasSearchTerm)
      return Center(
          child: Text(
        'No results found',
        style: contentStyle,
      ));
    else
      return value.isLocationLoading
          ? spinkit
          : ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: ((context, index) => suggestions[index]));
  }

  Future<void> setLocation(HomeProvider value, BuildContext context) async {
    try {
      value.toggleLocationLoading(true);
      final String location = '${value.address}';
      final LatLng? latLng = await HttpServices.getLatLng(location);

      final UserLocationModel userLocationModel = UserLocationModel(location: location, latLng: latLng as LatLng,)
        ..location = location
        ..latLng = latLng!;

      await value.setUserLocation(userLocationModel);
      Navigator.pop(context);
        } catch (e) {
      await warningPopUp(context, oops, 'Something went wrong. $e');
    }
    value.toggleLocationLoading(false);
    }

  Future autoCompleteSearch(String place, HomeProvider value) async {
    try {
      place = place.replaceAll(" ", "+");

      String endpoint =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
          "key=$GoogleApiKey&"
          "input={$place}"
          "&components=country:in"
          //"&types=sublocality"
          ;

      endpoint += "&location=${this.locationResult.latLng?.latitude}," +
          "${this.locationResult.latLng?.longitude}";
    
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['predictions'] == null) {
        throw Error();
      }

      List<dynamic> predictions = responseJson['predictions'];

      if (predictions.isEmpty) {
        AutoCompleteItem aci = AutoCompleteItem()
          ..offset = 0
          ..text = ''
          ..length = 0;

        suggestions.add(RichSuggestion(aci, () {}));
      } else {
        for (dynamic t in predictions) {
          final aci = AutoCompleteItem()
            ..id = t['place_id']
            ..text = t['description']
            ..offset = t['matched_substrings'][0]['offset']
            ..length = t['matched_substrings'][0]['length'];

          suggestions.add(RichSuggestion(aci, () {
            setLocationFunction(aci.text ?? 'No Description`');
            //  decodeAndSelectPlace(aci);
          }));
        }
      }
      value.toggleLocationLoading(false);
      return suggestions;
      // displayAutoCompleteSuggestions(suggestions);
    } catch (e) {
      print(e);
    }
  }

  void setLocationFunction(String aci) {
    FocusScope.of(context).requestFocus(FocusNode());
    final HomeProvider value =
        Provider.of<HomeProvider>(context, listen: false);
    value.setAddress(aci);
    setLocation(value, context);
  }

  void searchPlace(String place, HomeProvider value) {
    // on keyboard dismissal, the search was being triggered again
    // this is to cap that.
    if (place == this.previousSearchTerm) {
      return;
    }

    previousSearchTerm = place;

    value.toggleLocationLoading(true);
    suggestions = [];
    hasSearchTerm = place.length > 0;

    if (place.length < 1) {
      return;
    }

    autoCompleteSearch(place, value);
  }

  void onSearchInputChange(String val, value) {
    if (val.isEmpty) {
      this.debouncer.cancel();
      searchPlace(val, value);
      return;
    }

    if (this.debouncer.isActive ?? false) {
      this.debouncer.cancel();
    }

    this.debouncer = Timer(Duration(milliseconds: 500), () {
      searchPlace(val, value);
    });
  }

  void reverseGeocode(LatLng latLng) async {
    try {
      final url = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?"
          "latlng=${latLng.latitude},${latLng.longitude}&"
          //      "language=${widget.localizationItem.languageCode}&"
          "key=$GoogleApiKey");

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Error();
      }

      final responseJson = jsonDecode(response.body);

      if (responseJson['results'] == null) {
        throw Error();
      }

      final result = responseJson['results'][0];
      setLocationFunction(result['formatted_address']);
    } catch (e) {
      print(e);
    }
  }
}

// class FavouriteLocationsWidget extends StatelessWidget {
//   const FavouriteLocationsWidget({Key key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final HomeProvider value =
//         Provider.of<HomeProvider>(context, listen: false);
//     return FutureBuilder<UserLocationModel>(
//         future: value.getRecentLocation(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData &&
//               snapshot.connectionState == ConnectionState.waiting) {
//             return Container();
//           }

//           return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(children: [
//                 Text('Recent search', style: const TextStyle(fontSize: 17)),
//                 Card(
//                   elevation: 5,
//                   child: ListTile(
//                       onTap: () => value.setUserLocation(snapshot.data),
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//                       title: Text('${value.city}, ${value.state}'),
//                       subtitle: Text(snapshot.data.country),
//                       trailing: Icon(Icons.arrow_right)),
//                 ),
//               ]));
//         });
//   }
// }
