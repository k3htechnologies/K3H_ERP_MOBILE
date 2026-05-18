import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon; // <--- changed
  final Color? backgroundColor;
  final double? size;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon, // <--- widget now
    this.backgroundColor = AppColor.lightBlue,
    this.size = 16,
  });

  // === Named Constructor for Edit Icon Button ===
  CustomIconButton.edit({
    Key? key,
    required VoidCallback onPressed,
    bool isDisabled = false,
  }) : this(
         key: key,
         onPressed: isDisabled ? () {} : onPressed,
         icon: Icon(
           Icons.edit,
           size: 16,
           color: isDisabled ? AppColor.grey2 : AppColor.black,
         ),
         backgroundColor:
             isDisabled ? AppColor.lightGreyBackground : AppColor.lightBlue,
         size: 16,
       );

  // === Named Constructor for Delete Icon Button ===
  CustomIconButton.delete({
    Key? key,
    required VoidCallback onPressed,
    bool isDisabled = false,
  }) : this(
         key: key,
         onPressed: isDisabled ? () {} : onPressed,
         icon: SvgPicture.asset(
           AppAssets.deleteIcon2,
           height: 16,
           colorFilter: ColorFilter.mode(
             isDisabled ? AppColor.grey2 : AppColor.error,
             BlendMode.srcIn,
           ),
         ),
         backgroundColor:
             isDisabled ? AppColor.lightGreyBackground : AppColor.lightRed,
         size: 16,
       );
  CustomIconButton.add({
    Key? key,
    required VoidCallback onPressed,
    bool isDisabled = false,
  }) : this(
         key: key,
         onPressed: isDisabled ? () {} : onPressed,
         icon: Icon(
           Icons.add,
           size: 16,
           color: isDisabled ? AppColor.grey2 : AppColor.black,
         ),
         backgroundColor:
             isDisabled ? AppColor.lightGreyBackground : AppColor.lightBlue,
         size: 16,
       );
  CustomIconButton.remove({
    Key? key,
    required VoidCallback onPressed,
    bool isDisabled = false,
  }) : this(
         key: key,
         onPressed: isDisabled ? () {} : onPressed,
         icon: SvgPicture.asset(
           AppAssets.removeIcon,
           height: 16,
           colorFilter: ColorFilter.mode(
             isDisabled ? AppColor.grey2 : AppColor.error,
             BlendMode.srcIn,
           ),
         ),
         backgroundColor:
             isDisabled ? AppColor.lightGreyBackground : AppColor.lightRed,
         size: 16,
       );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          height: size,
          width: size,
          child: icon, // <--- widget rendered here
        ),
      ),
    );
  }
}
