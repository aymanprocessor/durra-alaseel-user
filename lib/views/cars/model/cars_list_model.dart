import 'dart:convert';

CarsListModel carsListModelFromJson(String str) =>
    CarsListModel.fromJson(json.decode(str));

String carsListModelToJson(CarsListModel data) => json.encode(data.toJson());

class CarsListModel {
  List<String> message;
  CarsListData data;
  String type;

  CarsListModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory CarsListModel.fromJson(Map<String, dynamic> json) => CarsListModel(
        message: List<String>.from(json["message"]?["success"] ?? []),
        data: CarsListData.fromJson(json["data"] ?? {}),
        type: json["type"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "message": {"success": message},
        "data": data.toJson(),
        "type": type,
      };
}

class CarsListData {
  AvailableFilters availableFilters;
  List<CarItem> cars;
  Pagination pagination;
  DataPath dataPath;

  CarsListData({
    required this.availableFilters,
    required this.cars,
    required this.pagination,
    required this.dataPath,
  });

  factory CarsListData.fromJson(Map<String, dynamic> json) => CarsListData(
        availableFilters:
            AvailableFilters.fromJson(json["available_filters"] ?? {}),
        cars: List<CarItem>.from(
            (json["cars"] ?? []).map((x) => CarItem.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"] ?? {}),
        dataPath: DataPath.fromJson(json["data_path"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "available_filters": availableFilters.toJson(),
        "cars": List<dynamic>.from(cars.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
        "data_path": dataPath.toJson(),
      };
}

class AvailableFilters {
  List<CarTypeFilter> carTypes;
  List<CarModelFilter> carModels;
  List<BranchFilter> branches;

  AvailableFilters({
    required this.carTypes,
    required this.carModels,
    required this.branches,
  });

  factory AvailableFilters.fromJson(Map<String, dynamic> json) =>
      AvailableFilters(
        carTypes: List<CarTypeFilter>.from(
            (json["car_types"] ?? []).map((x) => CarTypeFilter.fromJson(x))),
        carModels: List<CarModelFilter>.from(
            (json["car_models"] ?? []).map((x) => CarModelFilter.fromJson(x))),
        branches: List<BranchFilter>.from(
            (json["branches"] ?? []).map((x) => BranchFilter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "car_types": List<dynamic>.from(carTypes.map((x) => x.toJson())),
        "car_models": List<dynamic>.from(carModels.map((x) => x.toJson())),
        "branches": List<dynamic>.from(branches.map((x) => x.toJson())),
      };
}

class CarTypeFilter {
  int id;
  String name;
  String slug;

  CarTypeFilter({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CarTypeFilter.fromJson(Map<String, dynamic> json) => CarTypeFilter(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        slug: json["slug"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
      };
}

class CarModelFilter {
  int id;
  String name;
  int carTypeId;
  String? imageUrl;

  CarModelFilter({
    required this.id,
    required this.name,
    required this.carTypeId,
    this.imageUrl,
  });

  factory CarModelFilter.fromJson(Map<String, dynamic> json) => CarModelFilter(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        carTypeId: json["car_type_id"] ?? 0,
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "car_type_id": carTypeId,
        "image_url": imageUrl,
      };
}

class BranchFilter {
  int id;
  String name;
  String slug;
  String address;

  BranchFilter({
    required this.id,
    required this.name,
    required this.slug,
    required this.address,
  });

  factory BranchFilter.fromJson(Map<String, dynamic> json) => BranchFilter(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        slug: json["slug"] ?? '',
        address: json["address"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "address": address,
      };
}

class CarItem {
  int id;
  int vendorId;
  Map<String, dynamic> carTitle;
  String carModel;
  String carNumber;
  int seat;
  int year;
  String fees;
  String price;
  String image;
  String imageUrl;
  int status;
  CarTypeInfo? carType;
  CarModelInfo? carModelInfo;
  AreaInfo? area;
  VendorInfo? vendor;
  String createdAt;

  CarItem({
    required this.id,
    required this.vendorId,
    required this.carTitle,
    required this.carModel,
    required this.carNumber,
    required this.seat,
    required this.year,
    required this.fees,
    required this.price,
    required this.image,
    required this.imageUrl,
    required this.status,
    this.carType,
    this.carModelInfo,
    this.area,
    this.vendor,
    required this.createdAt,
  });

  String get title {
    // Try to get 'en' first, then any available language
    if (carTitle.containsKey('en')) {
      final titleValue = carTitle['en'];
      if (titleValue is Map && titleValue.containsKey('car_title')) {
        return titleValue['car_title']?.toString() ?? carModel;
      }
      return titleValue?.toString() ?? carModel;
    }
    if (carTitle.isNotEmpty) {
      final firstValue = carTitle.values.first;
      if (firstValue is Map && firstValue.containsKey('car_title')) {
        return firstValue['car_title']?.toString() ?? carModel;
      }
      return firstValue?.toString() ?? carModel;
    }
    return carModel;
  }

  factory CarItem.fromJson(Map<String, dynamic> json) => CarItem(
        id: json["id"] ?? 0,
        vendorId: json["vendor_id"] ?? 0,
        carTitle: json["car_title"] is Map
            ? Map<String, dynamic>.from(json["car_title"])
            : {},
        carModel: json["car_model"] ?? '',
        carNumber: json["car_number"] ?? '',
        seat: json["seat"] ?? 0,
        year: json["year"] ?? 0,
        fees: json["fees"]?.toString() ?? '0',
        price: json["price"]?.toString() ?? '0',
        image: json["image"] ?? '',
        imageUrl: json["image_url"] ?? '',
        status: json["status"] ?? 0,
        carType: json["car_type"] != null
            ? CarTypeInfo.fromJson(json["car_type"])
            : null,
        carModelInfo: json["car_model_info"] != null
            ? CarModelInfo.fromJson(json["car_model_info"])
            : null,
        area: json["area"] != null ? AreaInfo.fromJson(json["area"]) : null,
        vendor:
            json["vendor"] != null ? VendorInfo.fromJson(json["vendor"]) : null,
        createdAt: json["created_at"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vendor_id": vendorId,
        "car_title": carTitle,
        "car_model": carModel,
        "car_number": carNumber,
        "seat": seat,
        "year": year,
        "fees": fees,
        "price": price,
        "image": image,
        "image_url": imageUrl,
        "status": status,
        "car_type": carType?.toJson(),
        "car_model_info": carModelInfo?.toJson(),
        "area": area?.toJson(),
        "vendor": vendor?.toJson(),
        "created_at": createdAt,
      };
}

class CarTypeInfo {
  int id;
  String name;
  String slug;

  CarTypeInfo({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CarTypeInfo.fromJson(Map<String, dynamic> json) => CarTypeInfo(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        slug: json["slug"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
      };
}

class CarModelInfo {
  int id;
  String name;
  String? imageUrl;

  CarModelInfo({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory CarModelInfo.fromJson(Map<String, dynamic> json) => CarModelInfo(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image_url": imageUrl,
      };
}

class AreaInfo {
  int id;
  String name;

  AreaInfo({
    required this.id,
    required this.name,
  });

  factory AreaInfo.fromJson(Map<String, dynamic> json) => AreaInfo(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class VendorInfo {
  int id;
  String name;
  String username;

  VendorInfo({
    required this.id,
    required this.name,
    required this.username,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) => VendorInfo(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        username: json["username"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
      };
}

class Pagination {
  int total;
  int perPage;
  int currentPage;
  int lastPage;
  int from;
  int to;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json["total"] ?? 0,
        perPage: json["per_page"] ?? 15,
        currentPage: json["current_page"] ?? 1,
        lastPage: json["last_page"] ?? 1,
        from: json["from"] ?? 0,
        to: json["to"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "per_page": perPage,
        "current_page": currentPage,
        "last_page": lastPage,
        "from": from,
        "to": to,
      };
}

class DataPath {
  String baseUrl;
  String imagePath;

  DataPath({
    required this.baseUrl,
    required this.imagePath,
  });

  factory DataPath.fromJson(Map<String, dynamic> json) => DataPath(
        baseUrl: json["base_url"] ?? '',
        imagePath: json["image_path"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "base_url": baseUrl,
        "image_path": imagePath,
      };
}
