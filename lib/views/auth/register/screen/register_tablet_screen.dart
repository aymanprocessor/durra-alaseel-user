part of 'register_screen.dart';

class RegisterTabletScreen extends GetView<RegisterController> {
  const RegisterTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('Register Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.defaultHorizontalSize),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              BrandLogo(),
              HeadingTextHeader(),
              RegisterInputFields(),
              Sizes.height.v10,
              Obx(() => InlineErrorWidget(
                message: controller.errorMessage.value,
                onDismiss: () => controller.clearError(),
              )),
              Sizes.height.v10,
              CustomCheckboxWidget(),
              RegisterButton(),
              AlreadyAccountWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
