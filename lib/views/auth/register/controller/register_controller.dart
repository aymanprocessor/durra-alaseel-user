import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../base/api/services/auth_services.dart';
import '../../../../base/utils/api_error_handler.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  RxBool agree = false.obs;
  RxString errorMessage = ''.obs;

  get onPrivacyPolicy => '';
  RxBool isFormValid = false.obs;

  @override
  void onInit() {
    // add initial values for testing purposes
    emailAddressController.text = 'test@gmail.com';
    passwordController.text = '123456';
    firstNameController.text = 'John';
    lastNameController.text = 'Doe';
    phoneController.text = '1234567890';

    emailAddressController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
    firstNameController.addListener(_updateFormValidity);
    lastNameController.addListener(_updateFormValidity);
    phoneController.addListener(_updateFormValidity);
    super.onInit();
  }

  void _updateFormValidity() {
    isFormValid.value = emailAddressController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
    // Clear error message when user starts typing
    errorMessage.value = '';
  }

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email address';
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (!GetUtils.isNumericOnly(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (value.length < 6) return 'The password must be at least 6 characters';
    return null;
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void clearError() {
    errorMessage.value = '';
  }

  get onRegistration => registrationProcess();

  registrationProcess() async {
    ApiErrorHandler.clearError();
    return AuthServices.registrationProcess(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailAddressController.text,
      password: passwordController.text,
      phone: phoneController.text,
      isLoading: _isLoading,
      onError: (error) {
        errorMessage.value = ApiErrorHandler.lastError.isNotEmpty 
            ? ApiErrorHandler.lastError 
            : 'Registration failed. Please try again.';
      },
    );
  }
}
