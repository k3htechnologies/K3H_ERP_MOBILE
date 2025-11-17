import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomPaginationDropDownWidget extends StatefulWidget {
  final Future<Map<String, dynamic>> Function(int pageNumber, {String? value})
  dataFetchCallBack;
  final Function(Map<String, dynamic>) onSelected;
  final String? title;
  final String? Function(Map<String, dynamic>?)? validator;
  final Map<String, dynamic>? initialValue;
  final List<Map<String, dynamic>>? dataList;

  const CustomPaginationDropDownWidget({
    super.key,
    required this.dataFetchCallBack,
    required this.onSelected,
    this.title,
    this.validator,
    this.initialValue,
    this.dataList,
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
    final fetchedItems = List<Map<String, dynamic>>.from(result["itemList"]);

    return fetchedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (widget.title != null)
          Text(widget.title!, style: AppTextStyle.ts14R()),

        FormField<Map<String, dynamic>>(
          initialValue: selectedItem,
          validator: widget.validator,
          builder: (FormFieldState<Map<String, dynamic>> formFieldState) {
            final hasError = formFieldState.hasError;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: InputDecoration(
                    isDense: true,
                    errorText: null,
                    helperText: null,
                    counterText: '',

                    hintStyle: AppTextStyle.ts14R().copyWith(
                      color: AppColor.grey,
                    ),
                    contentPadding: EdgeInsets.zero,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(
                        color:
                        formFieldState.hasError
                            ? AppColor.error
                            : AppColor.grey30,
                        width: 1.0,
                      ),
                    ),
                    errorBorder: InputBorder.none,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(
                        color:
                        formFieldState.hasError
                            ? AppColor.error
                            : AppColor.grey30,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(
                        color:
                        formFieldState.hasError
                            ? AppColor.error
                            : AppColor.grey30,
                        width: 1.0,
                      ),
                    ),

                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color:
                        formFieldState.hasError
                            ? AppColor.error
                            : (AppColor.grey30),
                        width: 1.0,
                      ),
                    ),
                    errorStyle: const TextStyle(
                      height: 0,
                    ), // hide inline error text
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                        formFieldState.hasError
                            ? AppColor.error
                            : (AppColor.grey30),
                      ),
                      borderRadius: BorderRadius.circular(6.0),
                      color: AppColor.white,
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: AppColor.white,
                        textSelectionTheme: TextSelectionThemeData(
                          cursorColor: AppColor.black,
                        ),
                        hoverColor: AppColor.grey10,
                      ),
                      child: DropdownSearch<Map<String, dynamic>>(
                        items: (filter, props) => _fetchData(filter, props!),
                        selectedItem: selectedItem,
                        itemAsString: (item) => item["DisplayName"] ?? '',
                        compareFn: (item, selectedItem) {
                          return item["DisplayName"] ==
                              selectedItem["DisplayName"];
                        },

                        suffixProps: DropdownSuffixProps(
                          dropdownButtonProps: DropdownButtonProps(
                            iconOpened: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 24,
                              color: AppColor.black,
                            ),
                            iconClosed: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 24,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                        decoratorProps: DropDownDecoratorProps(
                          baseStyle: AppTextStyle.ts14R(),
                          decoration: InputDecoration(
                            isDense: true,
                            error: null,
                            errorText: null, // must be null
                            helperText: null,
                            counterText: '',
                            hintStyle: AppTextStyle.ts14R().copyWith(
                              color: AppColor.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 15.0,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchDelay: const Duration(milliseconds: 250),
                          searchFieldProps: TextFieldProps(
                            decoration: const InputDecoration(
                              hintText: 'Search...',
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.black,
                                ), // Set focused border color to black
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          disableFilter: true,
                          listViewProps: const ListViewProps(
                            padding: EdgeInsets.zero,
                          ),
                          loadingBuilder: (context, searchEntry) {
                            return SizedBox(
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.grey,
                                  strokeWidth: 2.0,
                                ),
                              ),
                            );
                          },
                          itemBuilder: (context, item, isDisabled, isSelected) {
                            return ListTile(
                              dense: true,
                              title: Text(
                                (item['DisplayName'] ?? '').toString(),
                              ),
                              tileColor:
                              isSelected ? Colors.grey.shade200 : null,
                              enabled: !isDisabled,
                            );
                          },
                          infiniteScrollProps: InfiniteScrollProps(
                            loadProps: LoadProps(take: 10),
                            loadingMoreBuilder: (context, searchEntry) {
                              return SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.grey,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedItem = value;
                            });
                            formFieldState.didChange(value);
                            widget.onSelected(value);
                          }
                        },

                        onBeforePopupOpening: (selectedItem) async {
                          currentPage = 1;
                          return true; // must return true to allow opening
                        },
                      ),
                    ),
                  ),
                ),
                hasError
                    ? Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                  child: Text(
                    formFieldState.errorText ?? '',
                    style: AppTextStyle.ts14R(color: AppColor.error),
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