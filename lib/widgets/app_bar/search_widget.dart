import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';

class SearchWidget extends StatelessWidget {
  final Function(String) onSubmit;
  final VoidCallback? onFilterTap;
  final TextEditingController textController;
  final String hintText;
  final bool isFilterOn;

  const SearchWidget({
    super.key,
    required this.onSubmit,
    required this.textController,
    this.onFilterTap,
    this.hintText = "Search...",
    this.isFilterOn = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Timer? debounce;

    return Container(
      height: 40.0,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 3.0, right: 6.0),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.grey30),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.searchIcon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColor.primary.withValues(alpha: .6),
              BlendMode.srcIn,
            ),
          ),

          /// SEARCH FIELD
          Expanded(
            child: TextField(
              controller: textController,
              onChanged: (value) {
                if (debounce?.isActive ?? false) debounce!.cancel();
                debounce = Timer(const Duration(seconds: 1), () {
                  onSubmit(value);
                });
              },
              onSubmitted: onSubmit,
              cursorHeight: 15,
              cursorColor:
              isDarkMode ? AppColor.warning : AppColor.cursorColor,
              style: AppTextStyle.ts12R()
                  .copyWith(color: isDarkMode ? AppColor.white : AppColor.black),
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: AppTextStyle.ts12R(color: AppColor.grey),
              ),
            ),
          ),

          // FILTER ICON
          if (isFilterOn) ...[
            Container(
              height: 28,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              color: isDarkMode ? AppColor.grey : AppColor.grey30,
            ),

            GestureDetector(
              onTap: onFilterTap,
              child: SvgPicture.asset(
                AppAssets.filterIcon,
                colorFilter: const ColorFilter.mode(
                  AppColor.grey,
                  BlendMode.srcIn,
                ),
                width: 16,
                height: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
