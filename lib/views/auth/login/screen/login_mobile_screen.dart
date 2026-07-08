part of 'login_screen.dart';

class LoginMobileScreen extends GetView<LoginController> {
  const LoginMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: Dimensions.defaultHorizontalSize.edgeHorizontal,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              BrandLogo(),
              const HeadingWidget(),
              InputWidget(),
              Sizes.height.v10,
              Obx(() => InlineErrorWidget(
                message: controller.errorMessage.value,
                onDismiss: () => controller.clearError(),
              )),
              Sizes.height.v10,
              const LogInButtonWidget(),
              if (BasicServices.userIsRegister.value == 1)
                const DoNotHaveAnAccount(),
            ],
          ),
        ),
      ),
    );
  }
}
