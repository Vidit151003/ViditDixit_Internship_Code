class UserModel {
  late String name;
  late String username;
  late String prefix;
  late String email;
  late String phoneNumber;
  late String uid;
  late String panNumber;
  late String street1;
  late String street2;
  late String city;
  late String zipcode;
  late String dob;
  late String aadhaarNumber;
  late String frontLicense;
  late String backLicense;
  late String frontAadhaar;
  late String backAadhaar;

  UserModel(
      {required this.name,
      required this.email,
      required this.phoneNumber,
      required this.prefix,
      required this.username,
      required this.dob,
      required this.aadhaarNumber,
      required this.street1,
      this.street2 = '',
      required this.city,
      required this.zipcode,
      required this.frontLicense,
      required this.backLicense,
      required this.frontAadhaar,
      required this.backAadhaar});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['firstname'] ??
        json['FirstName'] ??
        json['name'] ??
        json['username'];
    prefix = json['prefix'];
    email = json['email'] ?? json['Email'];
    username = json['username'];
    phoneNumber = json['mobileNumber'] ?? json['PhoneNumber'];
    street1 = json['street1'] ?? json['Street1'];
    street2 = json['street2'] ?? json['Street2'];
    city = json['city'] ?? json['City'];
    zipcode = json['zipcode'] ?? json['Zipcode'];
    dob = json['DateOfBirth'];
    frontLicense = json['front_page_driving_license'];
    backLicense = json['back_page_driving_license'];
    aadhaarNumber = json['aadhaarNumber'];
    panNumber = json['panNumber'];
    frontAadhaar = json['front_page_aadhaar_card'];
    backAadhaar = json['back_page_aadhaar_card'];
    }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstname'] = name;
    data['aadhaarNumber'] = aadhaarNumber;
    data['panNumber'] = panNumber;
    data['email'] = email;
    data['mobileNumber'] = phoneNumber;
    data['street1'] = street1;
    data['street2'] = street2;
    data['city'] = city;
    data['zipcode'] = zipcode;
    data['DateOfBirth'] = dob;
    return data;
  }
}
