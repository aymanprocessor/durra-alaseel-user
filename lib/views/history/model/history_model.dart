class HistoryModel {
  Message message;
  Data data;
  String type;

  HistoryModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        message: Message.fromJson(json["message"]),
        data: Data.fromJson(json["data"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "message": message.toJson(),
        "data": data.toJson(),
        "type": type,
      };
}

class Data {
  List<History> history;

  Data({
    required this.history,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        history:
            List<History>.from(json["history"].map((x) => History.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "history": List<dynamic>.from(history.map((x) => x.toJson())),
      };
}

class History {
  int id;
  int carId;
  dynamic branchId;
  int userId;
  String slug;
  String phone;
  String email;
  int tripId;
  String location;
  String destination;
  String paymentType;
  String trxId;
  dynamic amount;
  dynamic charges;
  dynamic deliveryFee;
  dynamic taxAmount;
  dynamic taxPercentage;
  dynamic subtotal;
  dynamic totalAmount;
  bool isDelivery;
  bool paidFromBalance;
  dynamic distance;
  String pickupTime;
  dynamic roundPickupTime;
  DateTime pickupDate;
  dynamic roundPickupDate;
  String message;
  int status;
  DateTime createdAt;
  DateTime updatedAt;
  Cars cars;

  History({
    required this.id,
    required this.carId,
    this.branchId,
    required this.userId,
    required this.slug,
    required this.phone,
    required this.email,
    required this.tripId,
    required this.location,
    required this.destination,
    required this.paymentType,
    required this.trxId,
    required this.amount,
    required this.charges,
    required this.deliveryFee,
    required this.taxAmount,
    required this.taxPercentage,
    required this.subtotal,
    required this.totalAmount,
    required this.isDelivery,
    required this.paidFromBalance,
    required this.distance,
    required this.pickupTime,
    this.roundPickupTime,
    required this.pickupDate,
    this.roundPickupDate,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.cars,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        id: json["id"] ?? 0,
        carId: json["car_id"] ?? 0,
        branchId: json["branch_id"],
        userId: json["user_id"] ?? 0,
        slug: json["slug"] ?? '',
        phone: json["phone"] ?? '',
        email: json["email"] ?? '',
        tripId: json["trip_id"] ?? 0,
        location: json["location"] ?? '',
        destination: json["destination"] ?? '',
        paymentType: json["payment_type"] ?? '',
        trxId: json["trx_id"] ?? '',
        amount: json["amount"],
        charges: json["charges"],
        deliveryFee: json["delivery_fee"],
        taxAmount: json["tax_amount"],
        taxPercentage: json["tax_percentage"],
        subtotal: json["subtotal"],
        totalAmount: json["total_amount"],
        isDelivery: json["is_delivery"] ?? false,
        paidFromBalance: json["paid_from_balance"] ?? false,
        distance: json["distance"],
        pickupTime: json["pickup_time"] ?? '',
        roundPickupTime: json["round_pickup_time"],
        pickupDate: DateTime.parse(json["pickup_date"]),
        roundPickupDate: json["round_pickup_date"],
        message: json["message"] ?? '',
        status: json["status"] ?? 0,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        cars: Cars.fromJson(json["cars"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "car_id": carId,
        "branch_id": branchId,
        "user_id": userId,
        "slug": slug,
        "phone": phone,
        "email": email,
        "trip_id": tripId,
        "location": location,
        "destination": destination,
        "payment_type": paymentType,
        "trx_id": trxId,
        "amount": amount,
        "charges": charges,
        "delivery_fee": deliveryFee,
        "tax_amount": taxAmount,
        "tax_percentage": taxPercentage,
        "subtotal": subtotal,
        "total_amount": totalAmount,
        "is_delivery": isDelivery,
        "paid_from_balance": paidFromBalance,
        "distance": distance,
        "pickup_time": pickupTime,
        "round_pickup_time": roundPickupTime,
        "pickup_date":
            "${pickupDate.year.toString().padLeft(4, '0')}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}",
        "round_pickup_date": roundPickupDate,
        "message": message,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "cars": cars.toJson(),
      };
}

class Cars {
  int id;
  int vendorId;
  dynamic carAreaId;
  dynamic branchId;
  int carTypeId;
  int carModelId;
  String slug;
  Map<String, dynamic> carTitle;
  dynamic carModel;
  int seat;
  int year;
  dynamic experience;
  dynamic carNumber;
  String fees;
  String image;
  int status;
  int approval;
  DateTime createdAt;
  DateTime updatedAt;
  String imageUrl;

  Cars({
    required this.id,
    required this.vendorId,
    this.carAreaId,
    this.branchId,
    required this.carTypeId,
    required this.carModelId,
    required this.slug,
    required this.carTitle,
    this.carModel,
    required this.seat,
    required this.year,
    this.experience,
    this.carNumber,
    required this.fees,
    required this.image,
    required this.status,
    required this.approval,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
  });

  factory Cars.fromJson(Map<String, dynamic> json) => Cars(
        id: json["id"] ?? 0,
        vendorId: json["vendor_id"] ?? 0,
        carAreaId: json["car_area_id"],
        branchId: json["branch_id"],
        carTypeId: json["car_type_id"] ?? 0,
        carModelId: json["car_model_id"] ?? 0,
        slug: json["slug"] ?? '',
        carTitle: json["car_title"] ?? {},
        carModel: json["car_model"],
        seat: json["seat"] ?? 0,
        year: json["year"] ?? 0,
        experience: json["experience"],
        carNumber: json["car_number"],
        fees: json["fees"]?.toString() ?? '0',
        image: json["image"] ?? '',
        status: json["status"] ?? 0,
        approval: json["approval"] ?? 0,
        createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
        imageUrl: json["image_url"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vendor_id": vendorId,
        "car_area_id": carAreaId,
        "branch_id": branchId,
        "car_type_id": carTypeId,
        "car_model_id": carModelId,
        "slug": slug,
        "car_title": carTitle,
        "car_model": carModel,
        "seat": seat,
        "year": year,
        "experience": experience,
        "car_number": carNumber,
        "fees": fees,
        "image": image,
        "status": status,
        "approval": approval,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "image_url": imageUrl,
      };
}

class Message {
  List<String> success;

  Message({
    required this.success,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: List<String>.from(json["success"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": List<dynamic>.from(success.map((x) => x)),
      };
}
