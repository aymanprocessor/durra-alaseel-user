import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/cars/model/cars_list_model.dart';
import 'package:carbo/backend/model/car_booking/pickup_location_model.dart';
import 'package:carbo/models/delivery_check_result.dart';
import 'package:carbo/services/delivery_api_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingController extends GetxController {
  BookingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final emailController = TextEditingController();
  final noteController = TextEditingController();
  final mobileController = TextEditingController();
  final rentalDaysController = TextEditingController();
  
  // Removed: distanceController, destinationController, locationController
  
  RxBool isFormValid = false.obs;
  RxString selectedRoundDate = ''.obs;
  RxString selectedRoundTime = ''.obs;
  RxString selectedPickupDate = ''.obs;
  RxString selectedPickupTime = ''.obs;
  var isChecked = false.obs;

  // Delivery option state
  final deliveryCheckResult = Rxn<DeliveryCheckResult>();
  final selectedDeliveryLocation = Rxn<LatLng>();
  final isCheckingDelivery = false.obs;
  final selectedLocationAddress = ''.obs;

  // Pickup location management
  Rx<PickupLocation?> pickupLocation = Rx<PickupLocation?>(null);
  RxBool isPickupFromBranch = false.obs;
  
  // Car data from route arguments
  late CarItem selectedCar;
  RxString carFee = '0'.obs;

  bool? get deliveryAvailable {
    return selectedCar.branch?.isDeliveryAvailable;
  }

  bool get isDeliveryEnabled {
    return !isPickupFromBranch.value && deliveryCheckResult.value?.allowed == true;
  }

  double get deliveryPriceValue => selectedCar.deliveryPriceValue;

  bool get forcePickupFromBranch => deliveryAvailable == false;

  bool get canConfirmBooking {
    if (!isFormValid.value) return false;
    if (isPickupFromBranch.value) return true;
    return deliveryCheckResult.value?.allowed == true;
  }

  BranchInfo? get deliveryBranchInfo => selectedCar.branch;

  Set<Marker> get mapMarkers {
    final markers = <Marker>{};
    final branch = selectedCar.branch;
    if (branch != null && (branch.latitude != 0.0 || branch.longitude != 0.0)) {
      markers.add(Marker(
        markerId: const MarkerId('branch'),
        position: LatLng(branch.latitude, branch.longitude),
        infoWindow: InfoWindow(title: branch.name),
      ));
    }
    if (selectedDeliveryLocation.value != null) {
      markers.add(Marker(
        markerId: const MarkerId('delivery'),
        position: selectedDeliveryLocation.value!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Delivery Location'),
      ));
    }
    return markers;
  }

  Set<Circle> get mapCircles {
    final branch = selectedCar.branch;
    if (branch == null || !branch.isDeliveryAvailable) return {};
    return {
      Circle(
        circleId: const CircleId('delivery_radius'),
        center: LatLng(branch.latitude, branch.longitude),
        radius: branch.deliveryRadiusKm! * 1000,
        strokeColor: const Color(0xFFFF8C00),
        strokeWidth: 2,
        fillColor: const Color(0x26FF8C00),
      ),
    };
  }

  /// Get car slug for API requests (from car type if available)
  String getCarSlug() {
    return selectedCar.carType?.slug ?? '';
  }

  @override
  void onInit() {
    // Get car data from route arguments
    if (Get.arguments != null && Get.arguments is Map) {
      selectedCar = Get.arguments['car'] ?? CarItem(
        id: 0, vendorId: 0, carTitle: {}, carModel: '', carNumber: '',
        seat: 0, year: 0, fees: '0', price: '0', image: '', imageUrl: '',
        status: 0, createdAt: '',
      );
      carFee.value = selectedCar.fees;
    }

    // Reset delivery state for the newly loaded car
    deliveryCheckResult.value = null;
    selectedDeliveryLocation.value = null;
    
    // Auto-populate email and phone from LocalStorage (hidden fields)
    emailController.text = LocalStorage.email;
    mobileController.text = LocalStorage.number;
    
    // Listen to pickup location changes for form validation
    ever(pickupLocation, (_) => _updateFormValidity());
    ever(isPickupFromBranch, (_) {
      if (forcePickupFromBranch && !isPickupFromBranch.value) {
        isPickupFromBranch.value = true;
        return;
      }

      if (isPickupFromBranch.value) {
        deliveryCheckResult.value = null;
        selectedDeliveryLocation.value = null;
        selectedLocationAddress.value = '';
        _setPickupToBranchLocation();
      } else {
        pickupLocation.value = null;
        deliveryCheckResult.value = null;
        selectedDeliveryLocation.value = null;
        selectedLocationAddress.value = '';
      }
      _updateFormValidity();
    });
    
    // Listen to date/time/rental days changes
    ever(selectedPickupDate, (_) => _updateFormValidity());
    ever(selectedPickupTime, (_) => _updateFormValidity());
    rentalDaysController.addListener(_updateFormValidity);

    if (forcePickupFromBranch) {
      isPickupFromBranch.value = true;
      _setPickupToBranchLocation();
    }
    
    super.onInit();
  }

  void _updateFormValidity() {
    // Form is valid if all required fields are filled:
    // 1. Pickup location (from branch or custom)
    // 2. Rental days (min 1 day)
    // 3. Pickup date
    // 4. Pickup time
    
    bool hasValidPickupLocation = isPickupFromBranch.value || 
        (pickupLocation.value != null && pickupLocation.value!.isValid);
    
    bool hasValidRentalDays = rentalDaysController.text.isNotEmpty && 
        (int.tryParse(rentalDaysController.text) ?? 0) > 0;
    
    bool hasPickupDate = selectedPickupDate.value.isNotEmpty;
    bool hasPickupTime = selectedPickupTime.value.isNotEmpty;
    
    isFormValid.value = hasValidPickupLocation && 
                        hasValidRentalDays && 
                        hasPickupDate && 
                        hasPickupTime;
  }
  
  /// Set pickup location to branch location from car data
  void _setPickupToBranchLocation() {
    // Use branch name from car data - this is from the cars list API
    final branchName = selectedCar.branch?.name;
    final branchAddress = branchName != null && branchName.isNotEmpty
        ? '$branchName Branch'
        : 'Branch Location';
    final branch = selectedCar.branch;
    pickupLocation.value = PickupLocation(
      latitude: branch?.latitude ?? 24.7136,
      longitude: branch?.longitude ?? 46.6753,
      address: branchAddress,
    );
  }
  
  /// Get branch location as LatLng for map centering
  LatLng? getBranchLocation() {
    final branch = selectedCar.branch;
    if (branch != null && (branch.latitude != 0.0 || branch.longitude != 0.0)) {
      return LatLng(branch.latitude, branch.longitude);
    }
    return const LatLng(24.7136, 46.6753);
  }
  
  /// Set pickup location from map picker
  void setPickupLocation(PickupLocation location) {
    if (forcePickupFromBranch) {
      isPickupFromBranch.value = true;
      _setPickupToBranchLocation();
      return;
    }

    pickupLocation.value = location;
    isPickupFromBranch.value = false;
  }

  Future<void> onDeliveryLocationSelected(LatLng location) async {
    selectedDeliveryLocation.value = location;
    selectedLocationAddress.value = '';
    isCheckingDelivery.value = true;
    deliveryCheckResult.value = null;

    // Set placeholder address immediately
    pickupLocation.value = PickupLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      address: '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
    );

    // Run reverse geocoding + delivery check concurrently
    await Future.wait([
      _resolveAddress(location),
      _validateDeliveryLocation(location),
    ]);

    isCheckingDelivery.value = false;
  }

  Future<void> _resolveAddress(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty &&
          selectedDeliveryLocation.value?.latitude == location.latitude &&
          selectedDeliveryLocation.value?.longitude == location.longitude) {
        final p = placemarks.first;
        final parts = [
          if (p.street?.isNotEmpty == true) p.street!,
          if (p.subLocality?.isNotEmpty == true) p.subLocality!,
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.country?.isNotEmpty == true) p.country!,
        ];
        final addr = parts.join(', ');
        if (addr.isNotEmpty) {
          selectedLocationAddress.value = addr;
          pickupLocation.value = PickupLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            address: addr,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _validateDeliveryLocation(LatLng location) async {
    final branch = selectedCar.branch;
    if (branch == null) return;

    final service = Get.find<DeliveryApiService>();
    final result = await service.checkDeliveryArea(
      branchId: branch.id,
      lat: location.latitude,
      lng: location.longitude,
    );

    deliveryCheckResult.value = result;

    if (result == null) {
      Get.snackbar('Error', 'Could not validate delivery location. Please try again.');
    }
  }

  @override
  void onClose() {
    dateController.dispose();
    timeController.dispose();
    emailController.dispose();
    noteController.dispose();
    mobileController.dispose();
    rentalDaysController.dispose();
    super.onClose();
  }

  // Remove old fee calculation based on distance
  // Fees are now calculated on backend based on rental_days
}
