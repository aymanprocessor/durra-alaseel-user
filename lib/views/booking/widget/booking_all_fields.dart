part of '../screen/booking_screen.dart';

class BookingAllFields extends GetView<BookingController> {
  const BookingAllFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: crossStart,
        children: [
          _othersInputField(context),
          if (controller.isChecked.value == true) ...[
            Sizes.height.v5,
            _roundTripField(context),
          ],
          Sizes.height.betweenInputBox,
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

  _roundTripField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomDatePicker(
              showBorder: true,
              label: Strings.PickUpdate,
              selectedDate: controller.selectedRoundDate),
        ),
        Sizes.width.v10,
        Expanded(
          child: CustomTimePicker(
              showBorder: true,
              label: Strings.PickUpTime,
              selectedTime: controller.selectedRoundTime),
        ),
      ],
    );
  }

  _othersInputField(BuildContext context) {
    return Column(
      children: [
        // Email and Phone are hidden - auto-populated from user data
        
        // Pickup Location Checkbox - Branch or Custom
        _pickupLocationCheckbox(),
        Sizes.height.betweenInputBox,
        
        // Map Picker for Custom Location (shown when not picking from branch)
        if (!controller.isPickupFromBranch.value) ...[
          _mapPickerButton(context),
          Sizes.height.betweenInputBox,
        ],
        
        // Show selected location address
        if (controller.pickupLocation.value != null &&
            controller.pickupLocation.value!.isValid) ...[
          _selectedLocationDisplay(),
          Sizes.height.betweenInputBox,
        ],
        
        // Rental Days Input
        PrimaryInputWidget(
          controller: controller.rentalDaysController,
          label: Strings.rentalDays,
          hintText: Strings.enterRentalDays,
          textInputType: TextInputType.number,
          showBorderSide: true,
        ),
        Sizes.height.betweenInputBox,
        
        // Pickup Date and Time
        Row(
          children: [
            Expanded(
              child: CustomDatePicker(
                  showBorder: true,
                  label: Strings.PickUpdate,
                  selectedDate: controller.selectedPickupDate),
            ),
            Sizes.width.v10,
            Expanded(
              child: CustomTimePicker(
                  showBorder: true,
                  label: Strings.PickUpTime,
                  selectedTime: controller.selectedPickupTime),
            ),
          ],
        ),
        RoundTripCheck()
      ],
    );
  }
  
  Widget _pickupLocationCheckbox() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColor.disableColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: controller.isPickupFromBranch.value,
            onChanged: (value) {
              controller.isPickupFromBranch.value = value ?? false;
            },
            activeColor: CustomColor.primary,
          ),
          Expanded(
            child: Text(
              Strings.pickupFromBranch.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: CustomColor.typography,
              ),
            ),
          ),
        ],
      ),
    ));
  }
  
  Widget _mapPickerButton(BuildContext context) {
    return InkWell(
      onTap: () => _openMapPicker(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: CustomColor.disableColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: CustomColor.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                controller.pickupLocation.value != null &&
                        controller.pickupLocation.value!.isValid
                    ? Strings.changePickupLocation.tr
                    : Strings.selectLocationOnMap.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: CustomColor.typography,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: CustomColor.secondary,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _selectedLocationDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CustomColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CustomColor.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: CustomColor.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Location:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CustomColor.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.pickupLocation.value!.address,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: CustomColor.typography,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _openMapPicker(BuildContext context) {
    Get.to(() => MapPickerWidget(
      initialLocation: controller.pickupLocation.value,
      defaultCenter: controller.getBranchLocation(),
      onLocationSelected: (location) {
        controller.setPickupLocation(location);
      },
    ));
  }
}

