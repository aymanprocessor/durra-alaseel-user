import 'dart:convert';
import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:carbo/views/preview/model/booking_preview_model.dart';
import 'package:carbo/views/preview/widget/authorize_payment_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/api/model/common_success_model.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../../congratulations/model/congratulations_model.dart';
import '../../congratulations/screen/congratulations_screen.dart';
import '../model/booking_confirm_model.dart';
import '../model/manual_input_model.dart';
import '../screen/preview_screen.dart';
import '../widget/web_payment_screen.dart';

class PreviewController extends GetxController {
  final dashboardController = Get.put(DashboardController());

  bool _previewRequestInFlight = false;

  List<TextEditingController> inputFieldControllers = [];
  RxList inputFields = [].obs;
  RxList inputFileFields = [].obs;
  RxBool hasFile = false.obs;
  RxString selectType = "".obs;
  List<String> listImagePath = [];
  List<String> listFieldName = [];


  var identifier = "".obs;
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCVCController = TextEditingController();

  updateImageData(String fieldName, String imagePath) {
    if (listFieldName.contains(fieldName)) {
      int itemIndex = listFieldName.indexOf(fieldName);
      listImagePath[itemIndex] = imagePath;
    } else {
      listFieldName.add(fieldName);
      listImagePath.add(imagePath);
    }
    update();
  }

  String? getImagePath(String fieldName) {
    if (listFieldName.contains(fieldName)) {
      int itemIndex = listFieldName.indexOf(fieldName);
      return listImagePath[itemIndex];
    }
    return null;
  }

  Rxn<PaymentGateway> selectPaymentGateway = Rxn<PaymentGateway>();
  final List<PaymentGateway> paymentGatewayList = [];
  Rxn<Currency> selectedCurrency = Rxn<Currency>();
  final List<Currency> currencyList = [];

  @override
  void onInit() {
    super.onInit();
    _isLoading.value = true;
    getPreviewData();
  }

  var selectedMethod = RxInt(0);

  var paymentType = Rx<PaymentType>(
    PaymentType(
      onlinePayment: "online-payment",
      cash: 'cash',
      balance: 'balance',
    ),
  );

  String get selectedMethodText {
    totalPayable.value = 0.00;
    return selectedMethod.value == 0
        ? paymentType.value.cash
        : paymentType.value.onlinePayment;
  }

  void changePaymentMethod(int method) {
    selectedMethod.value = method;
  }

  void handlePaymentProcess() {
    if (selectedMethodText == 'cash') {
      cashBookedProcess();
    } else if (alias.value.contains('manual')) {
      paymentManualInsert();
    } else {
      bookingProcessAuto();
    }
  }

  ///=> GET ALL BOOKING PREVIEW INFO

  // Start in loading state to avoid building UI before data arrives.
  final _isLoading = true.obs;

  bool get isLoading => _isLoading.value;

  BookingPreviewModel? _bookingPreviewModel;

  BookingPreviewModel? get bookingPreviewModel => _bookingPreviewModel;

  Future<BookingPreviewModel?> getPreviewData() async {
    if (_previewRequestInFlight) return _bookingPreviewModel;
    _previewRequestInFlight = true;
    // Get car data from BookingController (new flow from cars list)
    final bookingController = Get.find<BookingController>();
    String carId = bookingController.selectedCar.id.toString();
    String rentalDays = bookingController.rentalDaysController.text;
    
    // Build query params as Map<String, String>
    // Note: token is sent via Authorization Bearer header, not query param
    Map<String, String> queryParams = {
      'car_id': carId,
      // Some backend implementations require car_type for pricing rules.
      // Provide it when available to avoid server-side null errors.
      if ((bookingController.selectedCar.carType?.id ?? 0) > 0)
        'car_type': bookingController.selectedCar.carType!.id.toString(),
      'rental_days': rentalDays,
      'pickup_date': bookingController.selectedPickupDate.value,
      'pickup_time': bookingController.selectedPickupTime.value,
    };
    
    // Add pickup_location as separate fields (backend expects array format)
    if (bookingController.pickupLocation.value != null && 
        bookingController.pickupLocation.value!.isValid) {
      queryParams['pickup_location[latitude]'] = bookingController.pickupLocation.value!.latitude.toString();
      queryParams['pickup_location[longitude]'] = bookingController.pickupLocation.value!.longitude.toString();
      queryParams['pickup_location[address]'] = bookingController.pickupLocation.value!.address;
    } else {
      // Temporary fake location for testing (Riyadh coordinates)
      queryParams['pickup_location[latitude]'] = '24.7136';
      queryParams['pickup_location[longitude]'] = '46.6753';
      queryParams['pickup_location[address]'] = 'Riyadh, Saudi Arabia';
    }
    
    try {
      return await RequestProcess().request<BookingPreviewModel>(
        queryParams: queryParams,
        fromJson: BookingPreviewModel.fromJson,
        apiEndpoint: ApiEndpoint.getBookingPreview,
        isLoading: _isLoading,
        showErrorMessage: false,
        onSuccess: (value) {
          _bookingPreviewModel = value;
          if (_bookingPreviewModel != null) {
            _getPreviewALlData();
          }
          paymentGatewayList
            ..clear()
            ..addAll(_bookingPreviewModel?.data.paymentGateways ?? <PaymentGateway>[]);
        },
      );
    } finally {
      _previewRequestInFlight = false;
    }
  }

  void _getPreviewALlData() {
    final model = _bookingPreviewModel;
    if (model == null) return;

    carModel.value = model.data.car?.carModel ?? '';
    carNumber.value = model.data.car?.carNumber ?? '';
    pickupTime.value = model.data.bookingDetails.pickupTime;
    slug.value = model.data.car?.slug ?? '';
    Id.value = model.data.car?.id.toString() ?? '';
    cashBalance.value = model.data.paymentType.cash;
    onlinePayment.value = model.data.paymentType.onlinePayment;

    // Update totalPayable from pricing_breakdown
    final totalString = model.data.pricingBreakdown?.total;
    if (totalString != null) {
      totalPayable.value = double.tryParse(totalString) ?? 0.0;
    }
  }

  RxString paymentTypes = ''.obs;
  RxString alias = ''.obs;
  RxString currencyName = ''.obs;

  // RxString rate = ''.obs;
  RxString carModel = ''.obs;
  RxString carNumber = ''.obs;
  RxString pickupTime = ''.obs;
  RxString pickupDate = ''.obs;
  RxString slug = ''.obs;
  RxString Id = ''.obs;
  RxString cashBalance = ''.obs;
  RxString onlinePayment = ''.obs;

  ///=> CONFIRM BOOKING PROCESS

  final _isBookingLoading = false.obs;

  bool get isBookingLoading => _isBookingLoading.value;

  late BookingConfirmModel _bookingConfirmModel;

  BookingConfirmModel get bookingConfirmModel => _bookingConfirmModel;

  Future<BookingConfirmModel?> bookingProcessAuto() async {
    final bookingController = Get.find<BookingController>();
    final previewModel = _bookingPreviewModel;
    
    // Use car data from preview API first, fallback to BookingController's selected car
    String carSlugValue = slug.value.isNotEmpty 
        ? slug.value 
        : bookingController.getCarSlug();
    String carIdValue = Id.value.isNotEmpty 
        ? Id.value 
        : bookingController.selectedCar.id.toString();

    final pickupLocation = bookingController.pickupLocation.value;
    final pickupLocationJson = (pickupLocation != null && pickupLocation.isValid)
        ? pickupLocation.toJson()
        : <String, dynamic>{};

    final branchName = previewModel?.data.car?.branch?.name;
    final locationDisplay = bookingController.isPickupFromBranch.value &&
            branchName != null &&
            branchName.trim().isNotEmpty
        ? branchName.trim()
        : (pickupLocation?.address ?? '');

    final deliveryPriceString = previewModel?.data.pricingBreakdown?.deliveryPrice;
    final deliveryPrice = double.tryParse(deliveryPriceString ?? '') ?? 0.0;
    final includeDelivery = deliveryPrice > 0;

    final tokenValue = (previewModel?.data.token ?? '').trim();

    final gatewayType = paymentTypes.value;
    final gatewayCurrency = selectedCurrency.value?.currencyCode ?? alias.value;
    final isManualGateway = gatewayType.toLowerCase().contains('manual');

    // Optional manual-only field (kept empty unless user provides it elsewhere)
    final String? transactionId = null;
    
    final rentalDays = int.tryParse(bookingController.rentalDaysController.text) ?? 1;
    final carId = int.tryParse(carIdValue) ?? bookingController.selectedCar.id;

    Map<String, dynamic> inputBody = {
      'car_id': carId,
      'car_slug': carSlugValue,
      'location': locationDisplay,
      'rental_days': rentalDays,
      'pickup_location': pickupLocationJson,
      'pickup_date': bookingController.selectedPickupDate.value,
      'pickup_time': bookingController.selectedPickupTime.value,
      'credentials': LocalStorage.email,
      'mobile': LocalStorage.number,
      'message': bookingController.noteController.text,
      'payment': selectedMethodText,
      'include_delivery': includeDelivery,
      'delivery_price': deliveryPrice,
      'round_pickup_date': bookingController.selectedRoundDate.value,
      'round_pickup_time': bookingController.selectedRoundTime.value,
      'gateway_type': gatewayType,
      'gateway_currency': gatewayCurrency,
      if (tokenValue.isNotEmpty) 'token': tokenValue,
      if (isManualGateway && (transactionId?.trim().isNotEmpty ?? false))
        'transaction_id': transactionId!.trim(),
    };
    return RequestProcess().request<BookingConfirmModel>(
      fromJson: BookingConfirmModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        _bookingConfirmModel = value!;
        identifier.value = _bookingConfirmModel.data.identifier;
        if(alias.value.contains('authorize')){
          Get.to(AuthorizeGatewayScreen());
        }else{
          Get.to(() => WebPaymentScreen());
        }
      },
    );

  }

  Future<CommonSuccessModel?> cashBookedProcess() async {
    final bookingController = Get.find<BookingController>();
    final previewModel = _bookingPreviewModel;
    
    // Use car data from preview API first, fallback to BookingController's selected car
    String carSlugValue = slug.value.isNotEmpty 
        ? slug.value 
        : bookingController.getCarSlug();
    String carIdValue = Id.value.isNotEmpty 
        ? Id.value 
        : bookingController.selectedCar.id.toString();

    final pickupLocation = bookingController.pickupLocation.value;
    final pickupLocationJson = (pickupLocation != null && pickupLocation.isValid)
        ? pickupLocation.toJson()
        : <String, dynamic>{};

    final branchName = previewModel?.data.car?.branch?.name;
    final locationDisplay = bookingController.isPickupFromBranch.value &&
            branchName != null &&
            branchName.trim().isNotEmpty
        ? branchName.trim()
        : (pickupLocation?.address ?? '');

    final deliveryPriceString = previewModel?.data.pricingBreakdown?.deliveryPrice;
    final deliveryPrice = double.tryParse(deliveryPriceString ?? '') ?? 0.0;
    final includeDelivery = deliveryPrice > 0;

    final tokenValue = (previewModel?.data.token ?? '').trim();

    final rentalDays = int.tryParse(bookingController.rentalDaysController.text) ?? 1;
    final carId = int.tryParse(carIdValue) ?? bookingController.selectedCar.id;
    
    Map<String, dynamic> inputBody = {
      'car_id': carId,
      'car_slug': carSlugValue,
      'location': locationDisplay,
      'rental_days': rentalDays,
      'pickup_location': pickupLocationJson,
      'pickup_date': bookingController.selectedPickupDate.value,
      'pickup_time': bookingController.selectedPickupTime.value,
      'credentials': LocalStorage.email,
      'mobile': LocalStorage.number,
      'message': bookingController.noteController.text,
      'payment': selectedMethodText,
      'include_delivery': includeDelivery,
      'delivery_price': deliveryPrice,
      'round_pickup_date': bookingController.selectedRoundDate.value,
      'round_pickup_time': bookingController.selectedRoundTime.value,
      if (tokenValue.isNotEmpty) 'token': tokenValue,
    };
    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  }

  ///=> Get manual payment input field

  late ManualInputModel _manualInputModel;

  ManualInputModel get manualInputModel => _manualInputModel;

  Future<ManualInputModel?> paymentManualInsert() async {
    return RequestProcess().request<ManualInputModel>(
      fromJson: ManualInputModel.fromJson,
      apiEndpoint: ApiEndpoint.getManualPaymentField,
      isLoading: _isBookingLoading,
      showSuccessMessage: false,
      showResult: true,
      queryParams: {
        'alias': alias.value,
      },
      onSuccess: (value) {
        _manualInputModel = value!;
        var data = _manualInputModel.data.inputFields;
        getManualDynamicInputField(
          data: data,
          inputFieldControllers: inputFieldControllers,
          inputFields: inputFields,
          inputFileFields: inputFileFields,
          hasFile: hasFile,
          selectType: selectType,
        );
        Get.toNamed(Routes.paymentManualField);
      },
    );
  }

  ///=> manual payment process

  late CommonSuccessModel _commonSuccessModel;

  CommonSuccessModel get commonSuccessModel => _commonSuccessModel;

  Future<CommonSuccessModel?> bookingManualProcess() async {
    final bookingController = Get.find<BookingController>();
    final previewModel = _bookingPreviewModel;
    
    // Use car data from preview API first, fallback to BookingController's selected car
    String carSlugValue = slug.value.isNotEmpty 
        ? slug.value 
        : bookingController.getCarSlug();
    String carIdValue = Id.value.isNotEmpty 
        ? Id.value 
        : bookingController.selectedCar.id.toString();
    
    final pickupLocation = bookingController.pickupLocation.value;
    final pickupLocationJson = (pickupLocation != null && pickupLocation.isValid)
        ? jsonEncode(pickupLocation.toJson())
        : '';

    final branchName = previewModel?.data.car?.branch?.name;
    final locationDisplay = bookingController.isPickupFromBranch.value &&
            branchName != null &&
            branchName.trim().isNotEmpty
        ? branchName.trim()
        : (pickupLocation?.address ?? '');

    final deliveryPriceString = previewModel?.data.pricingBreakdown?.deliveryPrice;
    final deliveryPrice = double.tryParse(deliveryPriceString ?? '') ?? 0.0;
    final includeDelivery = deliveryPrice > 0;

    final tokenValue = (previewModel?.data.token ?? '').trim();

    final gatewayType = paymentTypes.value;
    final gatewayCurrency = selectedCurrency.value?.currencyCode ?? alias.value;
    final isManualGateway = gatewayType.toLowerCase().contains('manual');
    final String? transactionId = null;

    final rentalDays = int.tryParse(bookingController.rentalDaysController.text) ?? 1;
    final carId = int.tryParse(carIdValue) ?? bookingController.selectedCar.id;
    
    Map<String, dynamic> inputBody = {
      'car_id': carId,
      'car_slug': carSlugValue,
      'location': locationDisplay,
      'rental_days': rentalDays,
      // Multipart form doesn't support nested objects directly; send pickup_location as JSON string.
      'pickup_location': pickupLocationJson,
      'pickup_date': bookingController.selectedPickupDate.value,
      'pickup_time': bookingController.selectedPickupTime.value,
      'credentials': LocalStorage.email,
      'mobile': LocalStorage.number,
      'message': bookingController.noteController.text,
      'payment': selectedMethodText,
      'include_delivery': includeDelivery,
      'delivery_price': deliveryPrice,
      'round_pickup_date': bookingController.selectedRoundDate.value,
      'round_pickup_time': bookingController.selectedRoundTime.value,
      'gateway_type': gatewayType,
      'gateway_currency': gatewayCurrency,
      if (tokenValue.isNotEmpty) 'token': tokenValue,
      if (isManualGateway && (transactionId?.trim().isNotEmpty ?? false))
        'transaction_id': transactionId!.trim(),
    };
    final data = _manualInputModel.data.inputFields;

    for (int i = 0; i < data.length; i += 1) {
      if (data[i].type != 'file') {
        inputBody[data[i].name] = inputFieldControllers[i].text;
      }
    }
    inputFileFields.clear();
    inputFields.clear();
    listImagePath.clear();
    listFieldName.clear();
    inputFieldControllers.clear();
    update();

    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      fieldList: listFieldName,
      pathList: listImagePath,
      onSuccess: (value) {
        inputFileFields.clear();
        inputFields.clear();
        listImagePath.clear();
        listFieldName.clear();
        inputFieldControllers.clear();
        update();
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  }

  void _confirmation(CommonSuccessModel commonSuccessModel) {
    Congratulation congratulation = Congratulation(
      details: Strings.bookingSuccessfully,
      route: Routes.dashboardScreen,
      buttonText: Strings.backToHome,
      type: Strings.payment,
    );

    Get.to(
      () => CongratulationsScreen(),
      arguments: congratulation,
    );
  }

  RxDouble totalPayable = 0.0.obs;

  RxDouble exRent = 0.0.obs;
  RxDouble percentCharge = 0.0.obs;
  RxDouble fixeCharge = 0.0.obs;
  RxDouble conversionAmount = 0.0.obs;
  RxDouble totalCharge = 0.0.obs;

  // Note: Fee calculation is now done on backend via preview API
  // This method is deprecated but kept for compatibility
  void calculateAllCharges() {
    // Fees are now calculated on backend based on rental_days
    // Use pricing_breakdown from preview API response instead
    // conversionAmount.value = exRent.value * bookingController.totalFees.value;
    // percentCharge.value = percentCharge.value / 100 * conversionAmount.value;
    // totalCharge.value = fixeCharge.value + percentCharge.value;
    // totalPayable.value = conversionAmount.value + totalCharge.value;
  }

  // Authorize Submit
  final _isAuthorizeLoading = false.obs;
  bool get isAuthorizeLoading => _isAuthorizeLoading.value;

  late CommonSuccessModel _authorizeModel;
  CommonSuccessModel get authorizeModel => _authorizeModel;

  Future<CommonSuccessModel?> authorizeSubmitProcess()async{
    Map<String , dynamic> inputBody ={
      "identifier": identifier.value,
      "card_number": cardNumberController.text,
      "date": cardExpiryController.text,
      "code": cardCVCController.text
    };
    return RequestProcess().request(
      fromJson: CommonSuccessModel.fromJson, 
      apiEndpoint: ApiEndpoint.authorizeSubmit, 
      body: inputBody,
      method: HttpMethod.POST,
      isLoading: _isAuthorizeLoading, 
      onSuccess: (value){
        _authorizeModel = value!;
        Congratulation congratulation = Congratulation(
          details: Strings.paymentSuccessful,
          route: Routes.dashboardScreen,
          buttonText: Strings.backToHome,
          type: Strings.payment,
        );
        Get.offAll(
              () => CongratulationsScreen(),
          arguments: congratulation,
        );
      });
  }
}
