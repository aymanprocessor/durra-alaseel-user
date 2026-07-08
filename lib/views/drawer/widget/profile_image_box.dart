part of '../screen/drawer_screen.dart';

class ProfileHeaderWidget extends GetView<DashboardController> {
  const ProfileHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back(); // Close drawer
        Get.toNamed(Routes.update_profileScreen);
      },
      child: Column(
        children: [
          Sizes.height.v30,
          Hero(
            tag: 'profile_avatar',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: CustomColor.primary),
              ),
              child: CircleAvatar(
              radius: Dimensions.radius * 4.5,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: Obx(() {
                  final profileImageUrl = controller.userProfileImage.value;
                  final defaultImageUrl = controller.userDefaultImageUrl.value;

                  bool isValidUrl(String url) {
                    return url.isNotEmpty &&
                        (url.startsWith('http://') || url.startsWith('https://'));
                  }

                  if (isValidUrl(profileImageUrl)) {
                    return CachedNetworkImage(
                      imageUrl: profileImageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => isValidUrl(defaultImageUrl)
                          ? Image.network(defaultImageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50))
                          : const Icon(Icons.person, size: 50),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  } else if (isValidUrl(defaultImageUrl)) {
                    return Image.network(defaultImageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 50));
                  } else {
                    return const Icon(Icons.person, size: 50);
                  }
                }),
              ),
            ),
          ),
          ),
          Sizes.height.v10,
          Column(
            crossAxisAlignment: crossStart,
            children: [
              TextWidget(
                controller.userFullName.value,
                fontSize: Dimensions.titleLarge,
                fontWeight: FontWeight.w500,
              ),
              TextWidget(
                controller.userEmail.value,
                fontSize: Dimensions.titleSmall,
              ),
            ],
          )
        ],
      ),
    );
  }
}
