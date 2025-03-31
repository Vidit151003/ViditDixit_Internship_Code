class MyChoizeModel {
  late var brandGroundLength;
  late int brandKey;
  late num brandLength;
  late bool isSoldOut;
  late String brandName;
  late String calcTypeDesc;
  late String couponCode;
  late int couponDiscount;
  late Null doorType;
  late int exKMRate;
  late String flex5;
  late String flex6;
  late String fuelType;
  late String fuelTypeCode;
  late int groupKey;
  late String groupName;
  late int locationKey;
  late String locationName;
  late int luggageCapacity;
  late int modelYear;
  late int perUnitCharges;
  late int rFTEngineCapacity;
  late String rFTEngineCapacityName;
  late String rateBasis;
  late String rateBasisDesc;
  late String rateTypeFlag;
  late int seatingCapacity;
  late int sortOrder;
  late String sortOrderFlag;
  late bool speedGoveronorFixed;
  late int tariffKey;
  late int totalAvailableVehicle;
  late int totalBookinCount;
  late int totalBookingHours;
  late int totalExpCharge;
  late String transMissionType;
  late String transMissionTypeCode;
  late String unitType;
  late String unitTypeDesc;
  late String vTRHybridFlag;
  late String vTRSUVFlag;
  late String vehicleBase64Image;
  late String vehicleBrandImageName;
  late Null vehicleImage;
  late int vehicleTypeKey;
  late String vehicleTypeName;
  late bool wiFiEnabled;

  MyChoizeModel(
      {this.brandGroundLength,
        required this.brandKey,
        required this.brandLength,
        required this.isSoldOut,
        required this.brandName,
        required this.calcTypeDesc,
        required  this.couponCode,
        required  this.couponDiscount,
        required  this.doorType,
        required  this.exKMRate,
        required   this.flex5,
        required this.flex6,
        required this.fuelType,
        required this.fuelTypeCode,
        required this.groupKey,
        required this.groupName,
        required this.locationKey,
        required this.locationName,
        required this.luggageCapacity,
        required this.modelYear,
        required this.perUnitCharges,
        required this.rFTEngineCapacity,
        required this.rFTEngineCapacityName,
        required this.rateBasis,
        required this.rateBasisDesc,
        required this.rateTypeFlag,
        required this.seatingCapacity,
        required this.sortOrder,
        required this.sortOrderFlag,
        required this.speedGoveronorFixed,
        required this.tariffKey,
        required this.totalAvailableVehicle,
        required this.totalBookinCount,
        required this.totalBookingHours,
        required this.totalExpCharge,
        required this.transMissionType,
        required this.transMissionTypeCode,
        required this.unitType,
        required this.unitTypeDesc,
        required this.vTRHybridFlag,
        required this.vTRSUVFlag,
        required this.vehicleBase64Image,
        required this.vehicleBrandImageName,
        required this.vehicleImage,
        required this.vehicleTypeKey,
        required this.vehicleTypeName,
        required this.wiFiEnabled});

  MyChoizeModel.fromJson(Map<String, dynamic> json) {
    brandGroundLength = json['BrandGroundLength'];
    brandKey = json['BrandKey'];
    brandLength = json['BrandLength'];
    brandName = json['BrandName'];
    calcTypeDesc = json['CalcTypeDesc'];
    couponCode = json['CouponCode'];
    couponDiscount = json['CouponDiscount'];
    doorType = json['DoorType'];
    exKMRate = json['ExKMRate'];
    flex5 = json['Flex_5'];
    flex6 = json['Flex_6'];
    fuelType = json['FuelType'];
    fuelTypeCode = json['FuelTypeCode'];
    groupKey = json['GroupKey'];
    groupName = json['GroupName'];
    locationKey = json['LocationKey'];
    locationName = json['LocationName'];
    luggageCapacity = json['LuggageCapacity'];
    modelYear = json['ModelYear'];
    perUnitCharges = json['PerUnitCharges'];
    rFTEngineCapacity = json['RFTEngineCapacity'];
    rFTEngineCapacityName = json['RFTEngineCapacityName'];
    rateBasis = json['RateBasis'];
    rateBasisDesc = json['RateBasisDesc'];
    rateTypeFlag = json['RateTypeFlag'];
    seatingCapacity = json['SeatingCapacity'];
    sortOrder = json['SortOrder'];
    sortOrderFlag = json['SortOrderFlag'];
    speedGoveronorFixed = json['SpeedGoveronorFixed'];
    tariffKey = json['TariffKey'];
    totalAvailableVehicle = json['TotalAvailableVehicle'];
    totalBookinCount = json['TotalBookinCount'];
    totalBookingHours = json['TotalBookingHours'];
    totalExpCharge = json['TotalExpCharge'];
    transMissionType = json['TransMissionType'];
    transMissionTypeCode = json['TransMissionTypeCode'];
    unitType = json['UnitType'];
    unitTypeDesc = json['UnitTypeDesc'];
    vTRHybridFlag = json['VTRHybridFlag'];
    vTRSUVFlag = json['VTRSUVFlag'];
    vehicleBase64Image = json['VehicleBase64Image'];
    vehicleBrandImageName = json['VehicleBrandImageName'];
    vehicleImage = json['VehicleImage'];
    vehicleTypeKey = json['VehicleTypeKey'];
    vehicleTypeName = json['VehicleTypeName'];
    wiFiEnabled = json['WiFiEnabled'];
    isSoldOut = (totalAvailableVehicle ?? 0) < 1;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['BrandGroundLength'] = this.brandGroundLength;
    data['BrandKey'] = this.brandKey;
    data['BrandLength'] = this.brandLength;
    data['BrandName'] = this.brandName;
    data['CalcTypeDesc'] = this.calcTypeDesc;
    data['CouponCode'] = this.couponCode;
    data['CouponDiscount'] = this.couponDiscount;
    data['DoorType'] = this.doorType;
    data['ExKMRate'] = this.exKMRate;
    data['Flex_5'] = this.flex5;
    data['Flex_6'] = this.flex6;
    data['FuelType'] = this.fuelType;
    data['FuelTypeCode'] = this.fuelTypeCode;
    data['GroupKey'] = this.groupKey;
    data['GroupName'] = this.groupName;
    data['LocationKey'] = this.locationKey;
    data['LocationName'] = this.locationName;
    data['LuggageCapacity'] = this.luggageCapacity;
    data['ModelYear'] = this.modelYear;
    data['PerUnitCharges'] = this.perUnitCharges;
    data['RFTEngineCapacity'] = this.rFTEngineCapacity;
    data['RFTEngineCapacityName'] = this.rFTEngineCapacityName;
    data['RateBasis'] = this.rateBasis;
    data['RateBasisDesc'] = this.rateBasisDesc;
    data['RateTypeFlag'] = this.rateTypeFlag;
    data['SeatingCapacity'] = this.seatingCapacity;
    data['SortOrder'] = this.sortOrder;
    data['SortOrderFlag'] = this.sortOrderFlag;
    data['SpeedGoveronorFixed'] = this.speedGoveronorFixed;
    data['TariffKey'] = this.tariffKey;
    data['TotalAvailableVehicle'] = this.totalAvailableVehicle;
    data['TotalBookinCount'] = this.totalBookinCount;
    data['TotalBookingHours'] = this.totalBookingHours;
    data['TotalExpCharge'] = this.totalExpCharge;
    data['TransMissionType'] = this.transMissionType;
    data['TransMissionTypeCode'] = this.transMissionTypeCode;
    data['UnitType'] = this.unitType;
    data['UnitTypeDesc'] = this.unitTypeDesc;
    data['VTRHybridFlag'] = this.vTRHybridFlag;
    data['VTRSUVFlag'] = this.vTRSUVFlag;
    data['VehicleBase64Image'] = this.vehicleBase64Image;
    data['VehicleBrandImageName'] = this.vehicleBrandImageName;
    data['VehicleImage'] = this.vehicleImage;
    data['VehicleTypeKey'] = this.vehicleTypeKey;
    data['VehicleTypeName'] = this.vehicleTypeName;
    data['WiFiEnabled'] = this.wiFiEnabled;
    return data;
  }
}
