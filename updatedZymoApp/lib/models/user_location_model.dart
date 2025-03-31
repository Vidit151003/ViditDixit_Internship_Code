import 'package:place_picker/place_picker.dart';

class UserLocationModel {
  late String location;
  late LatLng latLng;

  late String state;


  UserLocationModel({required this.location, required this.latLng, this.state=''});

  UserLocationModel.fromJson(Map<String, dynamic> json) {
    location = json['location'];
    latLng = LatLng.fromJson(json['latLng'])!;

    state = json['state'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['location'] = this.location;
    data['latLng'] = [this.latLng.latitude, this.latLng.longitude];
  
    data['state'] = this.state;
    return data;
  }
}
