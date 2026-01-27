part of '../screen/preview_screen.dart';

class PreviewSectionCard extends GetView<PreviewController> {
  PreviewSectionCard({
    super.key,
  });

  final bookController = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    final model = controller.bookingPreviewModel;
    final pricingBreakdown = model?.data.pricingBreakdown;
    final currency = model?.data.bookingCurrency ?? 'SAR';
    final bookingDetails = model?.data.bookingDetails;
    final user = model?.data.user;
    final branch = model?.data.car?.branch;
    
    // Determine pickup location display
    String pickupLocationDisplay;
    if (branch?.name != null && branch!.name.isNotEmpty) {
      // Use branch name if available
      pickupLocationDisplay = '${branch.name} Branch';
    } else {
      // Use map location address
      pickupLocationDisplay = bookingDetails?.pickupLocation?.address ?? 
                             bookController.pickupLocation.value?.address ?? 
                             'Not selected';
    }
    
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          padding:
              EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.5),
          Strings.preview,
          fontWeight: FontWeight.bold,
          fontSize: Dimensions.titleSmall,
        ),
        Container(
          padding: EdgeInsets.symmetric(
              vertical: Dimensions.verticalSize * 0.5,
              horizontal: Dimensions.defaultHorizontalSize),
          decoration: BoxDecoration(
              color: CustomColor.whiteColor,
              borderRadius: BorderRadius.circular(Dimensions.radius * 0.5)),
          child: Column(
            children: [
              // User Email
              if (user?.email != null && user!.email.isNotEmpty)
                _cardSection(Strings.email, user.email),
              // User Mobile
              if (user?.mobile != null && user!.mobile.isNotEmpty)
                _cardSection(Strings.Phone, user.mobile),
              // Pickup Location
              _cardSection(Strings.PickUpLocation, pickupLocationDisplay),
              // Pickup Date from bookingDetails
              if (bookingDetails?.pickupDate != null && bookingDetails!.pickupDate.isNotEmpty)
                _cardSection(Strings.PickUpdate, bookingDetails.pickupDate),
              // Pickup Time from bookingDetails
              if (bookingDetails?.pickupTime != null && bookingDetails!.pickupTime.isNotEmpty)
                _cardSection(Strings.PickUpTime, bookingDetails.pickupTime),
              // Round Trip Date - only show if exists
              if (bookingDetails?.roundPickupDate != null && bookingDetails!.roundPickupDate!.isNotEmpty)
                _cardSection(Strings.roundTripDate, bookingDetails.roundPickupDate!),
              // Round Trip Time - only show if exists
              if (bookingDetails?.roundPickupTime != null && bookingDetails!.roundPickupTime!.isNotEmpty)
                _cardSection(Strings.roundTripTime, bookingDetails.roundPickupTime!),
              // Car Model
              _cardSection(Strings.carModel, controller.carModel.value),
              // Pricing breakdown
              if (pricingBreakdown != null) ...[
                _cardSection(
                  Strings.rentalDays,
                  '${pricingBreakdown.rentalDays}',
                ),
                _cardSection(
                  Strings.rentalFees,
                  '${pricingBreakdown.rentalFees} $currency',
                ),
                if (double.tryParse(pricingBreakdown.deliveryPrice) != null && 
                    double.parse(pricingBreakdown.deliveryPrice) > 0)
                  _cardSection(
                    'Delivery',
                    '${pricingBreakdown.deliveryPrice} $currency',
                  ),
                if (double.tryParse(pricingBreakdown.charges) != null && 
                    double.parse(pricingBreakdown.charges) > 0)
                  _cardSection(
                    'Charges',
                    '${pricingBreakdown.charges} $currency',
                  ),
                _cardSection(
                  Strings.tax,
                  '${pricingBreakdown.taxAmount} $currency',
                ),
              ],
              Obx(
                () => _cardSection(
                  Strings.totalPayable,
                  '${controller.totalPayable.value.toStringAsFixed(BasicServices.precision.value)} $currency',
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  _cardSection(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Dimensions.verticalSize * 0.25,
          horizontal: Dimensions.defaultHorizontalSize),
      child: Row(
        mainAxisAlignment: mainSpaceBet,
        children: [
          TextWidget(
            title,
            fontSize: Dimensions.titleSmall,
          ),
          TextWidget(
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
            value,
            fontWeight: FontWeight.w500,
            color: CustomColor.primary,
            fontSize: Dimensions.titleSmall,
          ),
        ],
      ),
    );
  }
}
