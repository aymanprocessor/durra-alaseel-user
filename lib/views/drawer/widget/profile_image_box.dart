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
                child: CachedNetworkImage(
                  imageUrl: controller.userProfileImage.value,
                  errorWidget: (context, url, error) {
                    print('❌ Profile Image Load Error: $error');
                    print('❌ Failed URL: $url');
                    return Image.network(
                      controller.userDefaultImageUrl.value,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Default Image Also Failed: $error');
                        return Icon(Icons.person, size: 50);
                      },
                    );
                  },
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
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
