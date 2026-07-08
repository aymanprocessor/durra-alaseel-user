import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../base/api/services/auth_services.dart';
import '../../../../base/utils/api_error_handler.dart';

class LoginController extends GetxController {
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  RxBool isFormValid = false.obs;
  RxString errorMessage = ''.obs;

  get onLogInProcess => logInProcess();

  @override
  void onInit() {
    // emailAddressController.text = 'user@appdevs.net';
    // passwordController.text = 'appdevs';
    emailAddressController.addListener(_updateFormValidity);
    passwordController.addListener(_updateFormValidity);
    super.onInit();
  }

  void _updateFormValidity() {
    isFormValid.value = emailAddressController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
    // Clear error message when user starts typing
    // errorMessage.value = '';
  }

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  logInProcess() async {
    ApiErrorHandler.clearError();
    return AuthServices.logInService(
      credentials: emailAddressController.text,
      password: passwordController.text,
      isLoading: _isLoading,
      onError: (error) {
        errorMessage.value = ApiErrorHandler.lastError.isNotEmpty 
            ? ApiErrorHandler.lastError 
            : 'Login failed. Please try again.';
      },
    ).then((value) {
      // emailAddressController.clear();
      // passwordController.clear();
    });
  }

  logOutProcess() async {
    return AuthServices.logOutService(
      isLoading: _isLoading,
    );
  }

  deleteAccountProcess() async {
    return AuthServices.deleteAccountServices(
      isLoading: _isLoading,
    );
  }

  void clearError() {
    errorMessage.value = '';
  }
}
