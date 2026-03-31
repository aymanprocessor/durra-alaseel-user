part of '../screen/booking_screen.dart';

class BookingAllFields extends GetView<BookingController> {
  const BookingAllFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pickupTypeCard(context),
        const SizedBox(height: CarboSpacing.x4),
        AnimatedSwitcher(
          duration: CarboDuration.normal,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: !controller.isPickupFromBranch.value
              ? _deliveryLocationCard(context)
              : const SizedBox.shrink(key: ValueKey('no_delivery')),
        ),
        if (!controller.isPickupFromBranch.value)
          const SizedBox(height: CarboSpacing.x4),
        _rentalDetailsCard(context),
        const SizedBox(height: CarboSpacing.x4),
        _returnTripCard(context),
        const SizedBox(height: CarboSpacing.x4),
        _notesCard(context),
      ],
    ));
  }

  // ── Shared card container ──────────────────────────────────────────────────
  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CarboSpacing.x4),
      decoration: BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.lgAll,
        boxShadow: CarboShadow.card,
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CarboSpacing.x3),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: CarboColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: CarboColors.primary),
          ),
          const SizedBox(width: CarboSpacing.x2),
          Text(
            label,
            style: CarboTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Section 1: Pickup Type ─────────────────────────────────────────────────
  Widget _pickupTypeCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.location_on_outlined, 'Pickup Options'),
          _pickupOptionTile(
            value: true,
            icon: Icons.store_mall_directory_outlined,
            title: Strings.pickupFromBranch.tr,
          ),
          const SizedBox(height: CarboSpacing.x2),
          _pickupOptionTile(
            value: false,
            icon: Icons.local_shipping_outlined,
            title: 'Delivery to My Location',
            disabled: controller.forcePickupFromBranch,
          ),
          if (controller.deliveryAvailable != null ||
              controller.selectedCar.branch != null) ...[
            const SizedBox(height: CarboSpacing.x3),
            _deliveryAvailabilityBadge(),
          ],
        ],
      ),
    );
  }

  Widget _pickupOptionTile({
    required bool value,
    required IconData icon,
    required String title,
    bool disabled = false,
  }) {
    final isSelected = controller.isPickupFromBranch.value == value;
    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : () => controller.isPickupFromBranch.value = value,
        child: AnimatedContainer(
          duration: CarboDuration.normal,
          padding: const EdgeInsets.symmetric(
            horizontal: CarboSpacing.x3,
            vertical: CarboSpacing.x3,
          ),
          decoration: BoxDecoration(
            color: isSelected ? CarboColors.primaryLight : CarboColors.background,
            borderRadius: CarboRadius.mdAll,
            border: Border(
              left: BorderSide(
                color: isSelected ? CarboColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? CarboColors.primary : CarboColors.textSecondary,
              ),
              const SizedBox(width: CarboSpacing.x3),
              Expanded(
                child: Text(
                  title,
                  style: CarboTypography.bodyMedium.copyWith(
                    color: isSelected ? CarboColors.primary : CarboColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, size: 18, color: CarboColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveryAvailabilityBadge() {
    final available = controller.deliveryAvailable;
    final Color bgColor;
    final Color textColor;
    final IconData badgeIcon;
    final String badgeText;

    if (available == null) {
      bgColor = CarboColors.infoBg;
      textColor = CarboColors.info;
      badgeIcon = Icons.info_outline;
      badgeText = Strings.deliveryUnknown.tr;
    } else if (available) {
      bgColor = CarboColors.successBg;
      textColor = CarboColors.success;
      badgeIcon = Icons.check_circle_outline;
      badgeText = Strings.deliveryAvailable.tr;
    } else {
      bgColor = CarboColors.errorBg;
      textColor = CarboColors.error;
      badgeIcon = Icons.cancel_outlined;
      badgeText = Strings.deliveryNotAvailable.tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x3,
        vertical: CarboSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: CarboRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            '${Strings.branchDelivery.tr}: $badgeText',
            style: CarboTypography.labelMedium.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  // ── Section 2: Delivery Location ──────────────────────────────────────────
  Widget _deliveryLocationCard(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('delivery_section'),
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.map_outlined, 'Delivery Location'),
            _mapPickerRow(context),
            Obx(() {
              final isChecking = controller.isCheckingDelivery.value;
              final result = controller.deliveryCheckResult.value;
              if (!isChecking && result == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: CarboSpacing.x3),
                child: _deliveryStatusBanner(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _mapPickerRow(BuildContext context) {
    final hasLocation = controller.selectedDeliveryLocation.value != null;
    final addressText = controller.selectedLocationAddress.value.isNotEmpty
        ? controller.selectedLocationAddress.value
        : (hasLocation
            ? '${controller.selectedDeliveryLocation.value!.latitude.toStringAsFixed(5)}, '
                '${controller.selectedDeliveryLocation.value!.longitude.toStringAsFixed(5)}'
            : Strings.selectLocationOnMap.tr);
    final labelText = hasLocation
        ? Strings.changePickupLocation.tr
        : Strings.selectLocationOnMap.tr;

    return GestureDetector(
      onTap: controller.forcePickupFromBranch
          ? null
          : () => Get.to(() => const MapLocationPickerScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CarboSpacing.x3,
          vertical: CarboSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: CarboColors.background,
          borderRadius: CarboRadius.mdAll,
          border: Border.all(
            color: hasLocation ? CarboColors.primary : CarboColors.border,
            width: hasLocation ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasLocation ? CarboColors.primaryLight : CarboColors.background,
                borderRadius: CarboRadius.smAll,
              ),
              child: const Icon(Icons.location_on, size: 20, color: CarboColors.primary),
            ),
            const SizedBox(width: CarboSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLocation ? 'Selected Location' : labelText,
                    style: CarboTypography.labelMedium
                        .copyWith(color: CarboColors.textSecondary),
                  ),
                  if (hasLocation) ...[
                    const SizedBox(height: 2),
                    Text(
                      addressText,
                      style: CarboTypography.bodyMedium.copyWith(
                        color: CarboColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Transform.scale(
              scaleX: Directionality.of(context) == TextDirection.rtl ? -1 : 1,
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: CarboColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryStatusBanner() {
    if (controller.isCheckingDelivery.value) {
      return _statusBannerRow(
        color: CarboColors.infoBg,
        textColor: CarboColors.info,
        icon: null,
        isLoading: true,
        message: 'Checking delivery availability...',
      );
    }
    final result = controller.deliveryCheckResult.value;
    if (result == null) return const SizedBox.shrink();
    return _statusBannerRow(
      color: result.allowed ? CarboColors.successBg : CarboColors.errorBg,
      textColor: result.allowed ? CarboColors.success : CarboColors.error,
      icon: result.allowed ? Icons.check_circle_outline : Icons.cancel_outlined,
      isLoading: false,
      message: result.allowed
          ? 'Within delivery range — delivery fee applies'
          : result.statusMessage,
    );
  }

  Widget _statusBannerRow({
    required Color color,
    required Color textColor,
    required IconData? icon,
    required bool isLoading,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CarboSpacing.x3,
        vertical: CarboSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: CarboRadius.smAll,
      ),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else
            Icon(icon, size: 16, color: textColor),
          const SizedBox(width: CarboSpacing.x2),
          Expanded(
            child: Text(
              message,
              style: CarboTypography.bodySmall.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section 3: Rental Details ──────────────────────────────────────────────
  Widget _rentalDetailsCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.calendar_month_outlined, 'Rental Details'),
          PrimaryInputWidget(
            controller: controller.rentalDaysController,
            label: Strings.rentalDays,
            hintText: Strings.enterRentalDays,
            textInputType: TextInputType.number,
            showBorderSide: true,
          ),
          const SizedBox(height: CarboSpacing.x3),
          Row(
            children: [
              Expanded(
                child: CustomDatePicker(
                  showBorder: true,
                  label: Strings.PickUpdate,
                  selectedDate: controller.selectedPickupDate,
                  firstDate: DateTime.now(),
                ),
              ),
              const SizedBox(width: CarboSpacing.x3),
              Expanded(
                child: CustomTimePicker(
                  showBorder: true,
                  label: Strings.PickUpTime,
                  selectedTime: controller.selectedPickupTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section 4: Return Trip ─────────────────────────────────────────────────
  Widget _returnTripCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.repeat_outlined, 'Return Trip'),
          Row(
            children: [
              Icon(
                Icons.swap_horiz_rounded,
                size: 20,
                color: controller.isChecked.value
                    ? CarboColors.primary
                    : CarboColors.textSecondary,
              ),
              const SizedBox(width: CarboSpacing.x3),
              Expanded(
                child: Text(
                  Strings.roundTrip,
                  style: CarboTypography.bodyMedium.copyWith(
                    color: controller.isChecked.value
                        ? CarboColors.primary
                        : CarboColors.textPrimary,
                    fontWeight: controller.isChecked.value
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              Switch(
                value: controller.isChecked.value,
                onChanged: (val) => controller.isChecked.value = val,
                activeColor: CarboColors.primary,
                activeTrackColor: CarboColors.primaryLight,
                inactiveThumbColor: CarboColors.textSecondary,
                inactiveTrackColor: CarboColors.background,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: CarboSpacing.x3),
              child: Row(
                children: [
                  Expanded(
                    child: CustomDatePicker(
                      showBorder: true,
                      label: Strings.PickUpdate,
                      selectedDate: controller.selectedRoundDate,
                    ),
                  ),
                  const SizedBox(width: CarboSpacing.x3),
                  Expanded(
                    child: CustomTimePicker(
                      showBorder: true,
                      label: Strings.PickUpTime,
                      selectedTime: controller.selectedRoundTime,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: controller.isChecked.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: CarboDuration.normal,
          ),
        ],
      ),
    );
  }

  // ── Section 5: Notes ──────────────────────────────────────────────────────
  Widget _notesCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.notes_outlined, 'Additional Notes'),
          PrimaryInputWidget(
            skipEnterText: true,
            optionalText: Strings.Optional,
            label: Strings.note,
            maxLines: 4,
            controller: controller.noteController,
            hintText: Strings.writeHere,
            textInputType: TextInputType.name,
            showBorderSide: true,
          ),
        ],
      ),
    );
  }
}

