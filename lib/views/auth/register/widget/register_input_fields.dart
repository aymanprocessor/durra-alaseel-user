part of '../screen/register_screen.dart';

class RegisterInputFields extends GetView<RegisterController> {
  const RegisterInputFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  skipEnterText: true,
                  label: Strings.firstName,
                  controller: controller.firstNameController,
                  hintText: Strings.firstName,
                  validatorFunction: controller.validateRequired,
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: PrimaryInputWidget(
                  skipEnterText: true,
                  label: Strings.lastName,
                  controller: controller.lastNameController,
                  hintText: Strings.lastName,
                  validatorFunction: controller.validateRequired,
                ),
              ),
            ],
          ),
          Sizes.height.v10,
          PrimaryInputWidget(
            label: Strings.Phone,
            controller: controller.phoneController,
            hintText: Strings.Phone,
            textInputType: TextInputType.phone,
            validatorFunction: controller.validatePhone,
          ),
          Sizes.height.v10,
          PrimaryInputWidget(
            label: Strings.emailAddress,
            controller: controller.emailAddressController,
            hintText: Strings.emailAddress,
            validatorFunction: controller.validateEmail,
          ),
          Sizes.height.v10,
          PrimaryInputWidget(
            isPasswordField: true,
            label: Strings.password,
            controller: controller.passwordController,
            hintText: Strings.password,
            validatorFunction: controller.validatePassword,
          ),
        ],
      ),
    );
  }
}
