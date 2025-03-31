class ZoomCarModel {
  late List<Sections> sections;
  late List bottomFilters;
  late List<FiltersV6> filtersV6;
  late String ctaText;
  late int starts;
  late int ends;
  late List<String> flags;
  late List<String> experiments;
  late Chat chat;

  ZoomCarModel(
      {required this.sections,
      required this.bottomFilters,
      required this.filtersV6,
      required this.ctaText,
      required this.starts,
      required this.ends,
      required this.flags,
      required this.experiments,
      required this.chat});

  ZoomCarModel.fromJson(Map<String, dynamic> json) {
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections.add(Sections.fromJson(v));
      });
    }
    if (json['bottom_filters'] != null) {
      // bottomFilters = <Temp>[];
      json['bottom_filters'].forEach((v) {
        // bottomFilters.add(Temp.fromJson(v));
      });
    }
    if (json['filters_v6'] != null) {
      filtersV6 = <FiltersV6>[];
      json['filters_v6'].forEach((v) {
        filtersV6.add(FiltersV6.fromJson(v));
      });
    }
    ctaText = json['cta_text'];
    starts = json['starts'];
    ends = json['ends'];
    flags = json['flags'] != null ? json['flags'].cast<String>() : null;
    // experiments = json['experiments'].cast<String>();
    // chat = json['chat'] != null ? Chat.fromJson(json['chat']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['sections'] = this.sections.map((v) => v.toJson()).toList();
      data['bottom_filters'] =
        this.bottomFilters.map((v) => v.toJson()).toList();
      data['filters_v6'] = this.filtersV6.map((v) => v.toJson()).toList();
      data['cta_text'] = this.ctaText;
    data['starts'] = this.starts;
    data['ends'] = this.ends;
    data['flags'] = this.flags;
    data['experiments'] = this.experiments;
    data['chat'] = this.chat.toJson();
      return data;
  }
}

class Sections {
  late List<Cards> cards;

  Sections({required this.cards});

  Sections.fromJson(Map<String, dynamic> json) {
    if (json['cards'] != null) {
      cards = <Cards>[];
      json['cards'].forEach((v) {
        cards.add(Cards.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cards'] = this.cards.map((v) => v.toJson()).toList();
      return data;
  }
}

class Cards {
  late String type;
  late CarData carData;
  late NotifyMeData notifyMeData;

  Cards({required this.type, required this.carData, required this.notifyMeData});

  Cards.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    carData = json['car_data'] != null ? CarData.fromJson(json['car_data']) : throw Exception("car_data is null");
    notifyMeData = json['notify_me_data'] != null ? NotifyMeData.fromJson(json['notify_me_data']) : throw Exception("notify_me_data is null");
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'car_data': carData.toJson(),
      'notify_me_data': notifyMeData.toJson(),
    };
  }
}

class CarData {
  late int cargroupId;
  late int carId;
  late String name;
  late String brand;
  late String url;
  late String urlLarge;
  late Location location;
  late Pricing pricing;
  late List<String> accessories;
  late Rating rating;
  late List messages;
  late List<String> imageUrls;
  late bool isOriginalCarImages;

  CarData(
      {required this.cargroupId,
      required this.carId,
      required this.name,
      required this.brand,
      required this.url,
      required this.urlLarge,
      required this.location,
      required this.pricing,
      required this.accessories,
      required this.rating,
      required this.messages,
      required this.imageUrls,
      required this.isOriginalCarImages});

  CarData.fromJson(Map<String, dynamic> json) {
    cargroupId = json['cargroup_id'];
    carId = json['car_id'];
    name = json['name'];
    brand = json['brand'];
    url = json['url'];
    urlLarge = json['url_large'];
    location =
        (json['location'] != null ? Location.fromJson(json['location']) : null)!;
    pricing =
        (json['pricing'] != null ? Pricing.fromJson(json['pricing']) : null)!;
    accessories = json['accessories'].cast<String>();
    rating = (json['rating'] != null ? Rating.fromJson(json['rating']) : null)!;
    if (json['messages'] != null) {
      // messages = <Temp>[];
      json['messages'].forEach((v) {
        // messages.add(Temp.fromJson(v));
      });
    }
    imageUrls = json['image_urls'].cast<String>();
    isOriginalCarImages = json['is_original_car_images'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cargroup_id'] = this.cargroupId;
    data['car_id'] = this.carId;
    data['name'] = this.name;
    data['brand'] = this.brand;
    data['url'] = this.url;
    data['url_large'] = this.urlLarge;
    data['location'] = this.location.toJson();
      data['pricing'] = this.pricing.toJson();
      data['accessories'] = this.accessories;
    data['rating'] = this.rating.toJson();
      data['messages'] = this.messages.map((v) => v.toJson()).toList();
      data['image_urls'] = this.imageUrls;
    data['is_original_car_images'] = this.isOriginalCarImages;
    return data;
  }
}

class Location {
  late int id;
  late double lat;
  late double lng;
  late double distance;
  late List hdIds;
  late List terminalIds;
  dynamic hdUnavailableReason;
  late String zoomAirUnvailableReason;
  late String text;

  Location(
      {required this.id,
      required this.lat,
      required this.lng,
      required this.distance,
      required this.hdIds,
      required this.terminalIds,
      this.hdUnavailableReason,
      required this.zoomAirUnvailableReason,
      required this.text});

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lat = json['lat'];
    lng = json['lng'];
    distance = json['distance'];
    if (json['hd_ids'] != null) {
      // hdIds = <Temp>[];
      json['hd_ids'].forEach((v) {
        // hdIds.add(Temp.fromJson(v));
      });
    }
    if (json['terminal_ids'] != null) {
      // terminalIds = <Temp>[];
      json['terminal_ids'].forEach((v) {
        // terminalIds.add(Temp.fromJson(v));
      });
    }
    hdUnavailableReason = json['hd_unavailable_reason'];
    zoomAirUnvailableReason = json['zoom_air_unvailable_reason'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['distance'] = this.distance;
    data['hd_ids'] = this.hdIds.map((v) => v.toJson()).toList();
      data['terminal_ids'] = this.terminalIds.map((v) => v.toJson()).toList();
      data['hd_unavailable_reason'] = this.hdUnavailableReason;
    data['zoom_air_unvailable_reason'] = this.zoomAirUnvailableReason;
    data['text'] = this.text;
    return data;
  }
}

class Pricing {
  late String id;
  late String flexiName;
  late String payableAmount;
  late int revenue;

  Pricing({ required this.id, required this.flexiName, required this.payableAmount, required this.revenue});

  Pricing.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    flexiName = json['flexi_name'];
    payableAmount = json['payable_amount'];
    revenue = json['revenue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['flexi_name'] = this.flexiName;
    data['payable_amount'] = this.payableAmount;
    data['revenue'] = this.revenue;
    return data;
  }
}

class Rating {
  late String text;
  late String iconUrl;

  Rating({required this.text, required this.iconUrl});

  Rating.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    iconUrl = json['icon_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['text'] = this.text;
    data['icon_url'] = this.iconUrl;
    return data;
  }
}

class NotifyMeData {
  late String header;
  late String subHeader;
  late String image;
  late String ctaText;
  late String notifyMeHeader;
  late List<String> carTypes;
  late String placeholderText;
  late String notifyMeCtaText;

  NotifyMeData(
      {required this.header,
      required this.subHeader,
      required this.image,
      required this.ctaText,
      required this.notifyMeHeader,
      required this.carTypes,
      required this.placeholderText,
      required this.notifyMeCtaText});

  NotifyMeData.fromJson(Map<String, dynamic> json) {
    header = json['header'];
    subHeader = json['sub_header'];
    image = json['image'];
    ctaText = json['cta_text'];
    notifyMeHeader = json['notify_me_header'];
    carTypes = json['car_types'].cast<String>();
    placeholderText = json['placeholder_text'];
    notifyMeCtaText = json['notify_me_cta_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['header'] = this.header;
    data['sub_header'] = this.subHeader;
    data['image'] = this.image;
    data['cta_text'] = this.ctaText;
    data['notify_me_header'] = this.notifyMeHeader;
    data['car_types'] = this.carTypes;
    data['placeholder_text'] = this.placeholderText;
    data['notify_me_cta_text'] = this.notifyMeCtaText;
    return data;
  }
}

class FiltersV6 {
  late String header;
  late String id;
  late String type;
  late bool showSeparator;
  late List<FilterItems> filterItems;
  late bool hideForSpecificSearch;
  late String subHeader;

  FiltersV6(
      {required this.header,
      required this.id,
      required this.type,
      required this.showSeparator,
      required this.filterItems,
      required this.hideForSpecificSearch,
      required this.subHeader});

  FiltersV6.fromJson(Map<String, dynamic> json) {
    header = json['header'];
    id = json['id'];
    type = json['type'];
    showSeparator = json['show_separator'];
    if (json['filter_items'] != null) {
      filterItems = <FilterItems>[];
      json['filter_items'].forEach((v) {
        filterItems.add(FilterItems.fromJson(v));
      });
    }
    hideForSpecificSearch = json['hide_for_specific_search'];
    subHeader = json['sub_header'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['header'] = this.header;
    data['id'] = this.id;
    data['type'] = this.type;
    data['show_separator'] = this.showSeparator;
    data['filter_items'] = this.filterItems.map((v) => v.toJson()).toList();
      data['hide_for_specific_search'] = this.hideForSpecificSearch;
    data['sub_header'] = this.subHeader;
    return data;
  }
}

class FilterItems {
  late String id;
  late String icon;
  late String title;
  late bool isSelected;
  late bool isEnabled;
  late String subTitle;
  late Metadata metadata;

  FilterItems(
      {required this.id,
      required this.icon,
      required this.title,
      required this.isSelected,
      required this.isEnabled,
      required this.subTitle,
      required this.metadata});

  FilterItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    title = json['title'];
    isSelected = json['is_selected'];
    isEnabled = json['is_enabled'];
    subTitle = json['sub_title'];
    metadata =
        (json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['icon'] = this.icon;
    data['title'] = this.title;
    data['is_selected'] = this.isSelected;
    data['is_enabled'] = this.isEnabled;
    data['sub_title'] = this.subTitle;
    data['metadata'] = this.metadata.toJson();
      return data;
  }
}

class Metadata {
  late SearchData searchData;
  late Slider slider;

  Metadata({required this.searchData, required this.slider});

  Metadata.fromJson(Map<String, dynamic> json) {
    searchData = (json['search_data'] != null
        ? SearchData.fromJson(json['search_data'])
        : null)!;
    slider = (json['slider'] != null ? Slider.fromJson(json['slider']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['search_data'] = searchData.toJson();
      data['slider'] = slider.toJson();
      return data;
  }
}

class SearchData {
  late String hint;
  late List<Items> items;
  late Disclaimer disclaimer;

  SearchData({required this.hint, required this.items, required this.disclaimer});

  SearchData.fromJson(Map<String, dynamic> json) {
    hint = json['hint'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items.add(Items.fromJson(v));
      });
    }
    disclaimer = (json['disclaimer'] != null
        ? Disclaimer.fromJson(json['disclaimer'])
        : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['hint'] = this.hint;
    data['items'] = this.items.map((v) => v.toJson()).toList();
      data['disclaimer'] = this.disclaimer.toJson();
      return data;
  }
}

class Items {
  late String id;
  late String name;
  late bool isSelected;

  Items({required this.id, required this.name, required this.isSelected});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isSelected = json['is_selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['is_selected'] = this.isSelected;
    return data;
  }
}

class Disclaimer {
  late String text;
  late String disclaimerStatus;

  Disclaimer({required this.text, required this.disclaimerStatus});

  Disclaimer.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    disclaimerStatus = json['disclaimer_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['text'] = this.text;
    data['disclaimer_status'] = this.disclaimerStatus;
    return data;
  }
}

class Slider {
  late int min;
  late int max;
  late int precision;
  late String unit;
  late int value;

  Slider({required this.min, required this.max, required this.precision, required this.unit, required this.value});

  Slider.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
    precision = json['precision'];
    unit = json['unit'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['min'] = this.min;
    data['max'] = this.max;
    data['precision'] = this.precision;
    data['unit'] = this.unit;
    data['value'] = this.value;
    return data;
  }
}

class Chat {
  late String image;
  late Action action;

  Chat({required this.image, required this.action});

  Chat.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    action = (json['action'] != null ? Action.fromJson(json['action']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['image'] = this.image;
    data['action'] = this.action.toJson();
      return data;
  }
}

class Action {
  dynamic cta;
  late String type;
  late Metadat metadata;

  Action({this.cta, required this.type, required this.metadata});

  Action.fromJson(Map<String, dynamic> json) {
    cta = json['cta'];
    type = json['type'];
    metadata =
        (json['metadata'] != null ? Metadat.fromJson(json['metadata']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['cta'] = this.cta;
    data['type'] = this.type;
    data['metadata'] = this.metadata.toJson();
      return data;
  }
}

class Metadat {
  late String title;
  late String url;

  Metadat({required this.title, required this.url});

  Metadat.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = this.title;
    data['url'] = this.url;
    return data;
  }
}
