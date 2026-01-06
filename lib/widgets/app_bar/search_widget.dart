import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';

class SearchWidget extends StatelessWidget {
  final Function(String) onSubmit;
  final TextEditingController textController;
  final String hintText;
  final bool isFilterOn;

  const SearchWidget({
    super.key,
    required this.onSubmit,
    required this.textController,
    this.hintText = 'Search...',
    this.isFilterOn = true,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Timer? debounce;
    return Container(
      height: 35.0,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 3.0, right: 6.0),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.grey30),
      ),
      child: Row(
        spacing: 5.0,
        children: [
          SvgPicture.asset(
            AppAssets.searchIcon,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode( AppColor.primary.withValues(alpha: .6), BlendMode.srcIn),
          ),
          Expanded(
            child: TextField(
              controller: textController,
              onChanged: (value) {
                // CANCEL THE PREVIOUS DEBOUNCE TIMER
                if (debounce?.isActive ?? false) debounce!.cancel();
                // SET UP NEW DEBOUNCE TIMER
                debounce = Timer(const Duration(seconds: 1), () {
                  onSubmit(value);
                });
              },
              onSubmitted: onSubmit,
              cursorHeight: 15,
              cursorColor: isDarkMode ? AppColor.warning : AppColor.cursorColor,
              style: AppTextStyle.ts12R().copyWith(color: isDarkMode?AppColor.white:AppColor.black),
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: AppTextStyle.ts12R(color: AppColor.grey),
                fillColor: AppColor.white,
                filled: true
              ),
            ),
          ),
          if (isFilterOn) ...[
            Container(
              height: 28,
              width: 1,
              margin: EdgeInsets.symmetric(horizontal: 6.0),
              color: isDarkMode ? AppColor.grey: AppColor.grey30,
            ),
            SvgPicture.asset(
              AppAssets.filterIcon,
              colorFilter: ColorFilter.mode(AppColor.grey, BlendMode.srcIn),
              width: 16,
              height: 16,
            ),
          ],
        ],
      ),
    );
  }
}
