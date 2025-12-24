import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomPaginationDropDownWidget extends StatefulWidget {
  final Future<Map<String, dynamic>> Function(int pageNumber, {String? value})
  dataFetchCallBack;
  final Function(Map<String, dynamic>) onSelected;

  // 🔒 KEPT AS-IS
  final List<Map<String, dynamic>>? dataList;

  final String? title;
  final bool isRequired;
  final String? Function(Map<String, dynamic>?)? validator;
  final Map<String, dynamic>? initialValue;
  final String? hintText;

  const CustomPaginationDropDownWidget({
    super.key,
    required this.dataFetchCallBack,
    required this.onSelected,
    this.dataList,
    this.title,
    this.isRequired = false,
    this.validator,
    this.initialValue,
    this.hintText,
  });

  @override
  State<CustomPaginationDropDownWidget> createState() =>
      _CustomPaginationDropDownWidgetState();
}

class _CustomPaginationDropDownWidgetState
    extends State<CustomPaginationDropDownWidget> {
  int totalNumberOfRecord = 0;
  int currentPage = 1;
  String? searchText;
  Map<String, dynamic>? selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.initialValue;
  }

  Future<List<Map<String, dynamic>>> _fetchData(
    String? filter,
    LoadProps props,
  ) async {
    if (searchText != filter) {
      currentPage = 1;
      searchText = filter;
    }

    final result = await widget.dataFetchCallBack(currentPage++, value: filter);

    totalNumberOfRecord = result["totalNumberOfRecord"];
    return List<Map<String, dynamic>>.from(result["itemList"]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Row(
            children: [
              Text(widget.title!, style: AppTextStyle.ts14R()),
              if (widget.isRequired)
                Text("*", style: AppTextStyle.ts14R(color: AppColor.error)),
            ],
          ),

        const SizedBox(height: 4),

        FormField<Map<String, dynamic>>(
          initialValue: selectedItem,
          validator: widget.validator,
          builder: (formFieldState) {
            final hasError = formFieldState.hasError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasError ? AppColor.error : AppColor.grey30,
                      width: 1,
                    ),
                    color: AppColor.white,
                  ),
                  child: DropdownSearch<Map<String, dynamic>>(
                    items: (filter, props) => _fetchData(filter, props!),

                    selectedItem: selectedItem,

                    itemAsString: (item) => item["DisplayName"] ?? '',

                    compareFn: (a, b) => a["DisplayName"] == b["DisplayName"],

                    decoratorProps: DropDownDecoratorProps(
                      baseStyle: AppTextStyle.ts14R(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        hintText: widget.hintText ?? 'Select',
                        hintStyle: AppTextStyle.ts14R().copyWith(
                          color: AppColor.grey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                      ),
                    ),

                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      disableFilter: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: AppTextStyle.ts14R().copyWith(color: AppColor.black),
                          isDense: true,
                          prefixIcon: Icon(Icons.search, color: AppColor.black),
                          filled: true,
                          fillColor: AppColor.lightGrey.withValues(alpha: .3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: AppColor.grey,
                              width: .5,
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: AppColor.grey,
                              width: .5,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: AppColor.grey,
                              width: .5,
                            ),
                          ),

                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: AppColor.grey,
                              width: .5,
                            ),
                          ),
                        ),
                      ),
                      infiniteScrollProps: InfiniteScrollProps(
                        loadProps: LoadProps(take: 10),
                        loadingMoreBuilder:
                            (context, _) => const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                      ),
                    ),

                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedItem = value;
                      });
                      formFieldState.didChange(value);
                      widget.onSelected(value);
                    },

                    onBeforePopupOpening: (selectedItem) async {
                      currentPage = 1;
                      return true;
                    },
                  ),
                ),

                hasError
                    ? Padding(
                      padding: const EdgeInsets.only(left: 12, top: 2),
                      child: Text(
                        formFieldState.errorText ?? '',
                        style: AppTextStyle.ts12R(color: AppColor.error),
                      ),
                    )
                    : const SizedBox(height: 18),
              ],
            );
          },
        ),
      ],
    );
  }
}
