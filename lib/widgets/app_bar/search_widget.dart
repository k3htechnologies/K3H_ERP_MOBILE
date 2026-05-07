import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/app_assets.dart';

class SearchWidget extends StatefulWidget {
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
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      widget.onSubmit(value);
    });
  }

  void _onSubmitted(String value) {
    // Avoid a queued debounce firing after manual submit.
    _debounce?.cancel();
    widget.onSubmit(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
            colorFilter: ColorFilter.mode(AppColor.primary, BlendMode.srcIn),
          ),

          /// SEARCH FIELD
          Expanded(
            child: TextField(
              controller: widget.textController,
              onChanged: _onChanged,
              onSubmitted: _onSubmitted,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
              cursorHeight: 15,
              cursorColor: isDarkMode ? AppColor.warning : AppColor.cursorColor,
              style: AppTextStyle.ts12R().copyWith(
                color: isDarkMode ? AppColor.white : AppColor.black,
              ),
              decoration: InputDecoration.collapsed(
                hintText: widget.hintText,
                hintStyle: AppTextStyle.ts12R(color: AppColor.grey),
              ),
            ),
          ),

          // FILTER ICON
          if (widget.isFilterOn) ...[
            GestureDetector(
              onTap: widget.onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.lightBlue,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: SvgPicture.asset(
                  AppAssets.filterIcon,
                  colorFilter: const ColorFilter.mode(
                    AppColor.primary,
                    BlendMode.srcIn,
                  ),
                  width: 14,
                  height: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
