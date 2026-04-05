import 'package:carbo/base/api/services/basic_services.dart';
import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../../../views/history/model/history_model.dart';
import '../controller/booking_details_controller.dart';
import '../widget/extend_booking_bottom_sheet.dart';

class BookingDetailsScreen extends GetView<BookingDetailsController> {
  const BookingDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.background,
      appBar: _buildAppBar(context),
      body: Obx(() {
        final booking = controller.booking.value;
        if (booking == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _BookingDetailsBody(
          booking: booking,
          controller: controller,
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: CustomColor.whiteColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: CustomColor.typography, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final carModel = controller.booking.value?.cars.carModel?.toString();
        return TextWidget(
          carModel ?? Strings.bookingDetails.tr,
          typographyStyle: TypographyStyle.titleMedium,
          fontWeight: FontWeight.w700,
        );
      }),
      centerTitle: true,
    );
  }
}

class _BookingDetailsBody extends StatelessWidget {
  final History booking;
  final BookingDetailsController controller;

  const _BookingDetailsBody({
    required this.booking,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CarImageCard(booking: booking),
          SizedBox(height: Dimensions.verticalSize * 0.5),
          _StatusBadge(status: booking.status),
          SizedBox(height: Dimensions.verticalSize * 0.5),
          _InfoCard(booking: booking),
          SizedBox(height: Dimensions.verticalSize * 0.5),
          Obx(() => controller.canExtend
              ? _ExtendRentalButton(controller: controller)
              : const SizedBox.shrink()),
          Obx(() => controller.canCancel
              ? _CancelBookingButton(controller: controller)
              : const SizedBox.shrink()),
          SizedBox(height: Dimensions.verticalSize * 0.3),
          _ExtensionHistoryLink(controller: controller),
          SizedBox(height: Dimensions.verticalSize),
        ],
      ),
    );
  }
}

class _CarImageCard extends StatelessWidget {
  final History booking;

  const _CarImageCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final imageUrl = booking.cars.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radius),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _placeholder();
                },
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: CustomColor.tertiary,
      child: Icon(Icons.directions_car_outlined,
          size: 64, color: CustomColor.disableColor),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    switch (status) {
      case 1:
        color = Colors.orange;
        label = Strings.pending;
        break;
      case 2:
        color = Colors.blue;
        label = Strings.ongoing;
        break;
      case 3:
        color = CustomColor.primary;
        label = Strings.complete;
        break;
      default:
        color = CustomColor.rejected;
        label = Strings.reject;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize * 0.75,
        vertical: Dimensions.verticalSize * 0.2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Dimensions.radius * 2),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          SizedBox(width: 6),
          TextWidget(
            label.tr,
            fontSize: Dimensions.bodySmall,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final History booking;

  const _InfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final curCode = BasicServices.baseCurCode.value;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomColor.whiteColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        boxShadow: [
          BoxShadow(
            color: CustomColor.blackColor.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      child: Column(
        children: [
          _DeliveryRow(
            isDelivery: booking.isDelivery,
            location: booking.location,
          ),
          _divider(),
          _infoRow(
            Strings.PickUpdate,
            booking.pickupDate.toString().substring(0, 10),
          ),
          _divider(),
          _infoRow(Strings.PickUpTime, booking.pickupTime),
          _divider(),
          _infoRow(
            Strings.totalAmount,
            '${booking.totalAmount ?? 0} $curCode',
          ),
          _divider(),
          _infoRow(Strings.paymentType, booking.paymentType),
          _divider(),
          _infoRow(
            Strings.status,
            booking.status == 1
                ? Strings.pending.tr
                : booking.status == 2
                    ? Strings.ongoing.tr
                    : booking.status == 3
                        ? Strings.complete.tr
                        : Strings.reject.tr,
          ),
          if (booking.message.isNotEmpty) ...[
            _divider(),
            _infoRow(Strings.note, booking.message),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        thickness: 0.5,
        color: CustomColor.tertiary,
      );

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextWidget(
              title.tr,
              fontSize: Dimensions.titleSmall,
              color: CustomColor.secondary,
            ),
          ),
          SizedBox(width: Dimensions.defaultHorizontalSize * 0.5),
          Expanded(
            child: TextWidget(
              value,
              fontSize: Dimensions.titleSmall,
              fontWeight: FontWeight.w600,
              color: CustomColor.typography,
              textAlign: TextAlign.end,
              maxLines: 3,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  final bool isDelivery;
  final String location;

  const _DeliveryRow({
    required this.isDelivery,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDelivery ? CustomColor.primary : CustomColor.secondary;
    final icon = isDelivery
        ? Icons.local_shipping_outlined
        : Icons.storefront_outlined;
    final chipLabel = isDelivery
        ? Strings.deliveryToLocation.tr
        : Strings.branchPickup.tr;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: CustomColor.secondary),
                    SizedBox(width: 6),
                    TextWidget(
                      Strings.delivery.tr,
                      fontSize: Dimensions.titleSmall,
                      color: CustomColor.secondary,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radius * 2),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: TextWidget(
                  chipLabel,
                  fontSize: Dimensions.bodySmall,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: CustomColor.secondary),
                const SizedBox(width: 4),
                Expanded(
                  child: TextWidget(
                    location,
                    fontSize: Dimensions.bodySmall,
                    color: CustomColor.secondary,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExtendRentalButton extends StatelessWidget {
  final BookingDetailsController controller;

  const _ExtendRentalButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        title: Strings.extendRental.tr,
        onPressed: () => _openExtendSheet(context),
      ),
    );
  }

  void _openExtendSheet(BuildContext context) {
    controller.prepareExtendSheet();
    Get.bottomSheet(
      const ExtendBookingBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
      enableDrag: true,
    ).then((_) => controller.disposeExtendSheet());
  }
}

class _ExtensionHistoryLink extends StatelessWidget {
  final BookingDetailsController controller;

  const _ExtensionHistoryLink({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: controller.navigateToExtensionHistory,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.25,
            horizontal: Dimensions.defaultHorizontalSize,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_outlined,
                  size: 18, color: CustomColor.primary),
              SizedBox(width: 6),
              TextWidget(
                Strings.viewExtensionHistory.tr,
                fontSize: Dimensions.titleSmall,
                color: CustomColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelBookingButton extends StatelessWidget {
  final BookingDetailsController controller;

  const _CancelBookingButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Dimensions.verticalSize * 0.5),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: controller.isCancelLoading.value
                ? null
                : () => _showConfirmDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: CustomColor.rejected,
              side: BorderSide(color: CustomColor.rejected),
              padding: EdgeInsets.symmetric(
                vertical: Dimensions.verticalSize * 0.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius),
              ),
            ),
            child: controller.isCancelLoading.value
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomColor.rejected,
                    ),
                  )
                : TextWidget(
                    Strings.cancelBooking.tr,
                    fontSize: Dimensions.titleSmall,
                    color: CustomColor.rejected,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    Get.defaultDialog(
      title: Strings.cancelBooking.tr,
      middleText: Strings.cancelBookingConfirm.tr,
      textConfirm: Strings.yesCancel.tr,
      textCancel: Strings.keepBooking.tr,
      confirmTextColor: Colors.white,
      buttonColor: CustomColor.rejected,
      onConfirm: () {
        Navigator.of(context).pop();
        controller.cancelBooking();
      },
    );
  }
}
