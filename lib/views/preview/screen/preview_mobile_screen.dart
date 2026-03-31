part of 'preview_screen.dart';

class PreviewMobileScreen extends GetView<PreviewController> {
  const PreviewMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarboColors.background,
      body: Obx(
        () => controller.isLoading
            ? Container(
                color: CarboColors.background,
                child: const Center(child: Loader()),
              )
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _PreviewHeroHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      CarboSpacing.x4,
                      CarboSpacing.x4,
                      CarboSpacing.x4,
                      CarboSpacing.x6,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        PaymentSelectionWidget(),
                        const SizedBox(height: CarboSpacing.x3),
                        PreviewSectionCard(),
                        const SizedBox(height: CarboSpacing.x4),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Obx(
        () => controller.isLoading
            ? const SizedBox.shrink()
            : _BottomBar(),
      ),
    );
  }
}

class _PreviewHeroHeader extends GetView<PreviewController> {
  const _PreviewHeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: CarboGradients.primary,
        boxShadow: CarboShadow.primaryGlow,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CarboSpacing.x4,
            CarboSpacing.x3,
            CarboSpacing.x4,
            CarboSpacing.x6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: CarboRadius.mdAll,
                      ),
                      child: const Icon(
                        CarboIcons.back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: CarboSpacing.x3),
                  Expanded(
                    child: Text(
                      Strings.bookingPreview.tr,
                      style: CarboTypography.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CarboSpacing.x5),
              Builder(builder: (_) {
                final car = controller.bookingPreviewModel?.data.car;
                if (car == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (car.carModel.isNotEmpty)
                      Text(
                        car.carModel,
                        style: CarboTypography.headlineLarge.copyWith(
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    if (car.carNumber.isNotEmpty) ...[
                      const SizedBox(height: CarboSpacing.x2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CarboSpacing.x3,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: CarboRadius.fullAll,
                        ),
                        child: Text(
                          car.carNumber,
                          style: CarboTypography.labelMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends GetView<PreviewController> {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        CarboSpacing.x4,
        CarboSpacing.x3,
        CarboSpacing.x4,
        bottomPadding + CarboSpacing.x3,
      ),
      decoration: const BoxDecoration(
        color: CarboColors.surface,
        boxShadow: CarboShadow.floating,
      ),
      child: Obx(
        () => PrimaryButton(
          isLoading: controller.isBookingLoading,
          title: Strings.ConfirmBooking,
          onPressed: () => controller.handlePaymentProcess(),
        ),
      ),
    );
  }
}
