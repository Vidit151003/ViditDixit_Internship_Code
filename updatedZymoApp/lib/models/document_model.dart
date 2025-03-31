class DocumentModel {
  late String aadhaarFront;
  late String aadhaarBack;
  late String licenseFront;
  late String licenseBack;

  DocumentModel(
      {required this.aadhaarFront,
      required this.aadhaarBack,
      required this.licenseFront,
      required this.licenseBack});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    licenseFront = json['front_page_driving_license'];
    licenseBack = json['back_page_driving_license'];
    aadhaarFront = json['front_page_aadhaar_card'];
    aadhaarBack = json['back_page_aadhaar_card'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['aadhaarFront'] = aadhaarFront;
    data['aadhaarBack'] = aadhaarBack;
    data['LicenseFront'] = licenseFront;
    data['LicenseBack'] = licenseBack;
    return data;
  }
}
