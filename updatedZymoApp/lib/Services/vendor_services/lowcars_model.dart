class LowCarsModel {
  late String carName;
  late String carPic;
  late String carType;
  late String seats;
  late String fuelType;
  late String gasVolume;
  late String carId;
  late String offer;
  late int offerPrice;
  late String weekdayCharge;
  late String weekendCharge;
  late String peakCharge;
  late int fare;
  late int kmFree;
  late String freeKmHr;
  late String excessCharge;
  late int hrs;
  late List<Fleets> fleets;
  late String available;

  LowCarsModel(

      {this.carName='No name',
      this.carPic='No pic',
      this.carType='No type',
      this.seats='No',
      this.fuelType='No type',
      this.gasVolume='No type',
      this.carId='No id',
      this.offer='No offer',
      required this.offerPrice,
      this.weekdayCharge='No weekdayCharge',
      this.weekendCharge='No weekendCharge',
      this.peakCharge='No peakCharge',
      required this.fare,
      this.kmFree= 0,
      this.freeKmHr= '',
      this.excessCharge= '',
      this.hrs= 0,
      required this.fleets,
      required this.available});

  LowCarsModel.fromJson(Map<String, dynamic> json) {
    carName = json['car_name'];
    carPic = json['car_pic'];
    carType = json['car_type'];
    seats = json['seats'];
    fuelType = json['fuel_type'];
    gasVolume = json['gas_volume'];
    carId = json['car_id'];
    offer = json['offer'];
    offerPrice = json['offer_price'];
    weekdayCharge = json['weekday_charge'];
    weekendCharge = json['weekend_charge'];
    peakCharge = json['peak_charge'];
    fare = json['fare'];
    kmFree = json['km_free'];
    freeKmHr = json['free_km_hr'];
    excessCharge = json['excess_charge'];
    hrs = json['hrs'];
    if (json['fleets'] != null) {
      fleets = <Fleets>[];
      json['fleets'].forEach((v) {
        fleets.add(new Fleets.fromJson(v));
      });
    }
    available = json['available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['car_name'] = this.carName;
    data['car_pic'] = this.carPic;
    data['car_type'] = this.carType;
    data['seats'] = this.seats;
    data['fuel_type'] = this.fuelType;
    data['gas_volume'] = this.gasVolume;
    data['car_id'] = this.carId;
    data['offer'] = this.offer;
    data['offer_price'] = this.offerPrice;
    data['weekday_charge'] = this.weekdayCharge;
    data['weekend_charge'] = this.weekendCharge;
    data['peak_charge'] = this.peakCharge;
    data['fare'] = this.fare;
    data['km_free'] = this.kmFree;
    data['free_km_hr'] = this.freeKmHr;
    data['excess_charge'] = this.excessCharge;
    data['hrs'] = this.hrs;
    data['fleets'] = this.fleets.map((v) => v.toJson()).toList();
      data['available'] = this.available;
    return data;
  }
}

class Fleets {

  Fleets({required this.fleetName, required this.fleetId });
  late String fleetName;
  late String fleetId;

  Fleets.fromJson(Map<String, dynamic> json) {
    fleetName = json['fleet_name'];
    fleetId = json['fleet_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fleet_name'] = this.fleetName;
    data['fleet_id'] = this.fleetId;
    return data;
  }
}

class LowCarsCityModel {
  late String id;
  late String cityName;
  late String stateId;
  late String status;
  late String cityLogo;
  late String cityBanner;
  late String url;
  late String security;
  late String base;
  late String medium;
  late String large;
  late String unlimited;

  LowCarsCityModel(
      {required this.id,
      required this.cityName,
      required this.stateId,
      required this.status,
      required this.cityLogo,
      required this.cityBanner,
      required this.url,
      required this.security,
      required this.base,
      required this.medium,
      required this.large,
      required this.unlimited});

  LowCarsCityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cityName = json['city_name'];
    stateId = json['state_id'];
    status = json['status'];
    cityLogo = json['city_logo'];
    cityBanner = json['city_banner'];
    url = json['url'];
    security = json['security'];
    base = json['base'];
    medium = json['medium'];
    large = json['large'];
    unlimited = json['unlimited'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['city_name'] = this.cityName;
    data['state_id'] = this.stateId;
    data['status'] = this.status;
    data['city_logo'] = this.cityLogo;
    data['city_banner'] = this.cityBanner;
    data['url'] = this.url;
    data['security'] = this.security;
    data['base'] = this.base;
    data['medium'] = this.medium;
    data['large'] = this.large;
    data['unlimited'] = this.unlimited;
    return data;
  }
}
