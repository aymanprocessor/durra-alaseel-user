part of 'login_screen.dart';

class LoginTabletScreen extends GetView<LoginController> {
  const LoginTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('Login Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
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
        ],
      ),
    );
  }
}
