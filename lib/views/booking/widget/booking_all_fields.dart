part of '../screen/booking_screen.dart';

class BookingAllFields extends GetView<BookingController> {
  const BookingAllFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rentalDetailsCard(context),
        const SizedBox(height: CarboSpacing.x4),
        _insuranceTypeCard(context),
        const SizedBox(height: CarboSpacing.x4),
        _deliveryToggleCard(context),
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
        _rentalCalculationCard(context),
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

  // ── Section 1: Delivery Toggle ─────────────────────────────────────────────
  Widget _deliveryToggleCard(BuildContext context) {
    final isDelivery = !controller.isPickupFromBranch.value;
    final disabled = controller.forcePickupFromBranch;
    final isValidating = controller.isValidatingDateTime.value;
    final validation = controller.dateTimeValidation.value;
    final showHours = validation != null && !validation.isValid;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: CarboColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_shipping_outlined, size: 16, color: CarboColors.primary),
              ),
              const SizedBox(width: CarboSpacing.x2),
              Expanded(
                child: Text(
                  Strings.delivery.tr,
                  style: CarboTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (isValidating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CarboColors.primary,
                  ),
                )
              else if (showHours)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarboSpacing.x3,
                    vertical: CarboSpacing.x1,
                  ),
                  decoration: BoxDecoration(
                    color: CarboColors.errorBg,
                    borderRadius: CarboRadius.fullAll,
                  ),
                  child: Text(
                    Strings.deliveryNotAvailable.tr,
                    style: CarboTypography.labelSmall.copyWith(
                      color: CarboColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Opacity(
                  opacity: disabled ? 0.45 : 1.0,
                  child: Switch(
                    value: isDelivery,
                    onChanged: disabled
                        ? null
                        : (val) => controller.isPickupFromBranch.value = !val,
                    activeColor: CarboColors.primary,
                    activeTrackColor: CarboColors.primaryLight,
                    inactiveThumbColor: CarboColors.textSecondary,
                    inactiveTrackColor: CarboColors.background,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          if (showHours) ...[
            const SizedBox(height: CarboSpacing.x2),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: CarboSpacing.x3,
                vertical: CarboSpacing.x2,
              ),
              decoration: BoxDecoration(
                color: CarboColors.warningBg,
                borderRadius: CarboRadius.mdAll,
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: CarboColors.warning),
                  const SizedBox(width: CarboSpacing.x2),
                  Expanded(
                    child: Text(
                      validation.openTime.isNotEmpty
                          ? '${Strings.pickupTimeOutsideWorkingHours.tr}\n${validation.dayName}: ${validation.openTime} - ${validation.closeTime}'
                          : '${Strings.pickupTimeOutsideWorkingHours.tr}\n${validation.dayName}',
                      style: CarboTypography.labelSmall.copyWith(
                        color: CarboColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            _sectionHeader(
              Icons.map_outlined,
              Strings.deliveryLocation.tr,
            ),
            _mapPickerRow(context),
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
                    hasLocation ? Strings.selectedLocation.tr : labelText,
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

  // ── Section 3: Rental Details ──────────────────────────────────────────────
  Widget _rentalDetailsCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.calendar_month_outlined,
            Strings.rentalDetails.tr,
          ),
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

  // ── Section 4: Rental Calculation ─────────────────────────────────────────
  Widget _rentalCalculationCard(BuildContext context) {
    return Obx(() {
      final curCode = BasicServices.baseCurCode.value;
      final dailyPrice = double.tryParse(controller.carFee.value) ?? 0.0;
      final days = controller.rentalDaysCount.value;
      final rentalFee = dailyPrice * days;
      final isDeliveryOn = !controller.isPickupFromBranch.value;
      final deliveryFee = isDeliveryOn ? controller.deliveryPriceValue : 0.0;
      final isDaily = controller.selectedInsuranceType.value == 'daily';
      final insuranceFee = isDaily ? (controller.selectedCar.dailyInsurance * days) : 0.0;
      final taxPct = BasicServices.taxPercentage.value;
      final taxAmount = (rentalFee + deliveryFee + insuranceFee) * taxPct / 100;
      final estimatedTotal = rentalFee + deliveryFee + insuranceFee + taxAmount;
      final taxLabel = BasicServices.taxName.value.isNotEmpty
          ? BasicServices.taxName.value
          : Strings.tax.tr;

      return _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.receipt_long_outlined, Strings.totalAmount.tr),
            _calcRow(Strings.pricePerDay.tr, '$dailyPrice $curCode'),
            _calcDivider(),
            _calcRow(Strings.rentalDays.tr, '$days'),
            _calcDivider(),
            _calcRow(
              Strings.rentalFees.tr,
              '${rentalFee.toStringAsFixed(2)} $curCode',
              highlight: true,
            ),
            if (isDeliveryOn) ...[
              _calcDivider(),
              _calcRow(
                Strings.delivery.tr,
                '${deliveryFee.toStringAsFixed(2)} $curCode',
              ),
            ],
            if (insuranceFee > 0) ...[
              _calcDivider(),
              _calcRow(
                Strings.dailyInsurance.tr,
                '${insuranceFee.toStringAsFixed(2)} $curCode',
              ),
            ],
            _calcDivider(),
            _calcRow(
              taxLabel,
              '${taxAmount.toStringAsFixed(2)} $curCode',
            ),
            const SizedBox(height: CarboSpacing.x3),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: CarboSpacing.x3,
                vertical: CarboSpacing.x3,
              ),
              decoration: BoxDecoration(
                color: CarboColors.primaryLight,
                borderRadius: CarboRadius.mdAll,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Strings.totalAmount.tr,
                        style: CarboTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: CarboColors.primary,
                        ),
                      ),
                      Text(
                        '${estimatedTotal.toStringAsFixed(2)} $curCode',
                        style: CarboTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: CarboColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (insuranceFee > 0) ...[
                    const SizedBox(height: CarboSpacing.x2),
                    Divider(
                      height: 1,
                      color: CarboColors.primary.withOpacity(0.2),
                    ),
                    const SizedBox(height: CarboSpacing.x2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Strings.dailyInsurance.tr,
                          style: CarboTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: CarboColors.primary,
                          ),
                        ),
                        Text(
                          '${insuranceFee.toStringAsFixed(2)} $curCode',
                          style: CarboTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CarboColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _calcRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CarboSpacing.x2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CarboTypography.bodyMedium.copyWith(
              color: CarboColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: CarboTypography.bodyMedium.copyWith(
              color: highlight ? CarboColors.textPrimary : CarboColors.textSecondary,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcDivider() => const Divider(height: 1, thickness: 0.5, color: CarboColors.border);

  // ── Section: Insurance Type ───────────────────────────────────────────────
  Widget _insuranceTypeCard(BuildContext context) {
    final curCode = BasicServices.baseCurCode.value.isNotEmpty
        ? BasicServices.baseCurCode.value
        : 'SAR';
    final dailyRate = controller.selectedCar.dailyInsurance;
    final deductible = controller.selectedCar.deductibleInsurance;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.shield_outlined,
            Strings.selectInsuranceType.tr,
          ),
          Obx(() {
            final selected = controller.selectedInsuranceType.value;
            return Column(
              children: [
                _insuranceTile(
                  icon: Icons.verified_user_outlined,
                  title: Strings.dailyInsurance.tr,
                  subtitle: dailyRate > 0
                      ? '${dailyRate.toStringAsFixed(2)} $curCode / ${Strings.days.tr}'
                      : Strings.dailyInsurance.tr,
                  value: 'daily',
                  selected: selected,
                ),
                const SizedBox(height: CarboSpacing.x3),
                _insuranceTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: Strings.deductibleInsurance.tr,
                  subtitle: deductible > 0
                      ? '${Strings.deductibleNote.tr}: ${deductible.toStringAsFixed(0)} $curCode'
                      : Strings.deductibleInsurance.tr,
                  value: 'deductible',
                  selected: selected,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _insuranceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required String selected,
  }) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => controller.setInsuranceType(value),
      child: AnimatedContainer(
        duration: CarboDuration.normal,
        padding: const EdgeInsets.all(CarboSpacing.x3),
        decoration: BoxDecoration(
          color: isSelected ? CarboColors.primaryLight : CarboColors.background,
          borderRadius: CarboRadius.mdAll,
          border: Border.all(
            color: isSelected ? CarboColors.primary : CarboColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? CarboColors.primary : CarboColors.surface,
                borderRadius: CarboRadius.smAll,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : CarboColors.textSecondary,
              ),
            ),
            const SizedBox(width: CarboSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CarboTypography.titleSmall.copyWith(
                      color: isSelected ? CarboColors.primary : CarboColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CarboTypography.bodySmall.copyWith(
                      color: isSelected ? CarboColors.primary : CarboColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: CarboDuration.normal,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? CarboColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? CarboColors.primary : CarboColors.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Section 5: Notes ──────────────────────────────────────────────────────
  Widget _notesCard(BuildContext context) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.notes_outlined,
            Strings.additionalNotes.tr,
          ),
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
