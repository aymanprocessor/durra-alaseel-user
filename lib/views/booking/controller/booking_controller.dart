import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/cars/model/cars_list_model.dart';
import 'package:carbo/backend/model/car_booking/pickup_location_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingController extends GetxController {
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
  
  // Pickup location management
  Rx<PickupLocation?> pickupLocation = Rx<PickupLocation?>(null);
  RxBool isPickupFromBranch = false.obs;
  
  // Car data from route arguments
  late CarItem selectedCar;
  RxString carFee = '0'.obs;
  
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
    
    // Auto-populate email and phone from LocalStorage (hidden fields)
    emailController.text = LocalStorage.email;
    mobileController.text = LocalStorage.number;
    
    // Listen to pickup location changes for form validation
    ever(pickupLocation, (_) => _updateFormValidity());
    ever(isPickupFromBranch, (_) {
      if (isPickupFromBranch.value) {
        _setPickupToBranchLocation();
      }
      _updateFormValidity();
    });
    
    // Listen to date/time/rental days changes
    ever(selectedPickupDate, (_) => _updateFormValidity());
    ever(selectedPickupTime, (_) => _updateFormValidity());
    rentalDaysController.addListener(_updateFormValidity);
    
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
    // Default to area center or Riyadh if no specific branch location available
    // Branch location should be obtained from preview API response
    pickupLocation.value = PickupLocation(
      latitude: 24.7136, // Default: Riyadh center
      longitude: 46.6753,
      address: selectedCar.area?.name ?? 'Branch Location',
    );
  }
  
  /// Get branch location as LatLng for map centering
  LatLng? getBranchLocation() {
    // Default to Riyadh center
    // In future, this can be fetched from preview API branch data
    return const LatLng(24.7136, 46.6753);
  }
  
  /// Set pickup location from map picker
  void setPickupLocation(PickupLocation location) {
    pickupLocation.value = location;
    isPickupFromBranch.value = false;
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
