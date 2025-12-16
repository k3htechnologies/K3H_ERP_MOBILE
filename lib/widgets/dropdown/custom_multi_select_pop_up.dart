import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';

class CustomMultipleSelectPopup extends StatefulWidget {
  final List<Map<String, dynamic>>? dataList;
  final Function(List<Map<String, dynamic>>) onSelected;
  final List<Map<String, dynamic>>? initialValue;
  final String? title;
  final Future<Map<String, dynamic>> Function(int pageNumber, {String? value})
      dataFetchCallBack;
  final String? Function(List<Map<String, dynamic>>?)? validator;
  final bool isMultiSelect;

  const CustomMultipleSelectPopup({
    super.key,
    required this.dataFetchCallBack,
    required this.onSelected,
    this.title,
    this.validator,
    this.initialValue,
    this.dataList,
    this.isMultiSelect = true,
  });

  @override
  State<CustomMultipleSelectPopup> createState() =>
      _CustomMultipleSelectPopupState();

  static Future<List<Map<String, dynamic>>?> showBottomSheet({
    required BuildContext context,
    required String title,
    required Future<Map<String, dynamic>> Function(int pageNumber, {String? value})
        dataFetchCallBack,
    bool isMultiSelect = true,
    List<Map<String, dynamic>>? initialValue,
    List<Map<String, dynamic>>? dataList,
  }) async {
    return await showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final double bottomSheetHeight = (screenHeight * 0.5).clamp(400.0, 700.0);
        return Container(
          height: bottomSheetHeight,
          decoration: const BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.ts20M(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1.0,
                decoration: const BoxDecoration(color: AppColor.grey),
              ),
              Expanded(
                child: DropdownList(
                  dataList: dataList ?? const [],
                  initialValue: initialValue ?? const [],
                  isMultiSelect: isMultiSelect,
                  dataFetchCallBack: dataFetchCallBack,
                  onSelectCallback: (values) {
                    Navigator.of(context).pop(values);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomMultipleSelectPopupState
    extends State<CustomMultipleSelectPopup> {
  late List<Map<String, dynamic>> selectedValues;

  Future<List<Map<String, dynamic>>?> showBottomSheetForDropdown(
    BuildContext context, {
    required List<Map<String, dynamic>> dataList,
    required String title,
    String? Function(Map<String, dynamic>?)? validator,
    List<Map<String, dynamic>>? initialValue,
  }) async {
    return showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final double bottomSheetHeight = (screenHeight * 0.7).clamp(400.0, 700.0);
        return Container(
          height: bottomSheetHeight,
          decoration: const BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.ts20M(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1.0,
                decoration: const BoxDecoration(color: AppColor.grey),
              ),
              Expanded(
                child: _DropdownList(
                  dataList: dataList
                      .map<Map<String, dynamic>>(
                        (item) => Map<String, dynamic>.from(item),
                      )
                      .toList(),
                  initialValue: initialValue ?? [],
                  dataFetchCallBack: widget.dataFetchCallBack,
                  isMultiSelect: widget.isMultiSelect,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    selectedValues = List.from(widget.initialValue ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (widget.title != null)
          Text(widget.title!, style: AppTextStyle.ts16R()),
        Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: FormField<List<Map<String, dynamic>>>(
            validator: widget.validator,
            initialValue: selectedValues,
            builder:
                (FormFieldState<List<Map<String, dynamic>>> formFieldState) {
              final hasError = formFieldState.hasError;
              final borderColor =
                  hasError ? AppColor.error : AppColor.grey30;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      var value = await showBottomSheetForDropdown(
                        context,
                        title: widget.title ?? 'Search',
                        dataList: widget.dataList ?? [],
                        initialValue: selectedValues,
                      );
                      if (value != null) {
                        setState(() {
                          selectedValues = value;
                        });
                        formFieldState.didChange(selectedValues);
                        widget.onSelected(selectedValues);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: borderColor,
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      child: selectedValues.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.isMultiSelect
                                        ? selectedValues
                                            .map((e) => e['DisplayName'])
                                            .join(', ')
                                        : selectedValues.first['DisplayName'] ??
                                            '',
                                    style: AppTextStyle.ts14M(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 24),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Select',
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.grey,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 24),
                              ],
                            ),
                    ),
                  ),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                      child: Text(
                        formFieldState.errorText ?? '',
                        style: AppTextStyle.ts14R(color: AppColor.error),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class DropdownList extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final List<Map<String, dynamic>> initialValue;
  final Future<Map<String, dynamic>> Function(int pageNumber, {String? value})
      dataFetchCallBack;
  final bool isMultiSelect;
  final Function(List<Map<String, dynamic>>)? onSelectCallback;

  const DropdownList({
    super.key,
    required this.dataList,
    required this.initialValue,
    required this.dataFetchCallBack,
    required this.isMultiSelect,
    this.onSelectCallback,
  });

  @override
  State<DropdownList> createState() => _DropdownListState();
}

// Keep private version for internal use (backward compatibility)
class _DropdownList extends DropdownList {
  const _DropdownList({
    required super.dataList,
    required super.initialValue,
    required super.dataFetchCallBack,
    required super.isMultiSelect,
  }) : super(
          key: null,
          onSelectCallback: null,
        );
}

class _DropdownListState extends State<DropdownList> {
  late ScrollController scrollController;
  Timer? _debounce;

  List<Map<String, dynamic>> tempDataListForSearch = [];

  // LIST TO STORE THE INITIAL IDS TO GET THE CHECKBOX SELECTED
  List<int> initialIds = [];

  late TextEditingController searchC;

  int totalNumberOfRecord = 0;
  int currentPage = 1;
  bool isLoading = false;

  String searchText = '';

  // For single select (radio button), store the selected ID
  int? selectedRadioId;

  Future<void> _fetchData() async {
    if (isLoading) return; // Prevent multiple simultaneous calls
    setState(() => isLoading = true);

    final result = await widget.dataFetchCallBack(
      currentPage++,
      value: searchText,
    );

    List<Map<String, dynamic>> fetchedItems =
        List<Map<String, dynamic>>.from(result['itemList']);

    // Mark API items as checked if already selected
    for (var item in fetchedItems) {
      if (widget.isMultiSelect) {
        item['isChecked'] = widget.initialValue.any(
            (selected) => selected['zAttributesId'] == item['zAttributesId']);
      } else {
        // For single select, check if this is the selected item
        if (widget.initialValue.isNotEmpty &&
            widget.initialValue.first['zAttributesId'] ==
                item['zAttributesId']) {
          item['isChecked'] = true;
          selectedRadioId = item['zAttributesId'];
        } else {
          item['isChecked'] = false;
        }
      }
    }

    // Merge selected items that are not in fetched list yet
    if (widget.isMultiSelect) {
      for (var selected in widget.initialValue) {
        if (!fetchedItems.any(
            (item) => item['zAttributesId'] == selected['zAttributesId'])) {
          // Add previously selected item to list so it shows in UI
          fetchedItems.insert(0, {
            'zAttributesId': selected['zAttributesId'],
            'DisplayName': selected['DisplayName'],
            'isChecked': true,
          });
        }
      }
    } else {
      // For single select, add the initial value if not in fetched list
      if (widget.initialValue.isNotEmpty) {
        final initialItem = widget.initialValue.first;
        if (!fetchedItems.any(
            (item) => item['zAttributesId'] == initialItem['zAttributesId'])) {
          fetchedItems.insert(0, {
            'zAttributesId': initialItem['zAttributesId'],
            'DisplayName': initialItem['DisplayName'],
            'isChecked': true,
          });
          selectedRadioId = initialItem['zAttributesId'];
        }
      }
    }

    setState(() {
      totalNumberOfRecord = result["totalNumberOfRecord"] ?? 0;
      tempDataListForSearch.addAll(fetchedItems);
      isLoading = false;
    });
  }

  Future<void> search(String searchText) async {
    this.searchText = searchText;
    currentPage = 1;
    totalNumberOfRecord = 0;
    tempDataListForSearch.clear();
    if (!widget.isMultiSelect) {
      selectedRadioId = null;
    }
    _fetchData();
  }

  // PAGINATION
  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (isLoading) return;
    if (tempDataListForSearch.length >= totalNumberOfRecord) return;
    
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    
    // Load more when user scrolls within 200px of the bottom
    if (currentScroll >= maxScroll - 200) {
      // TO HANDLE MULTIPLE TIME API CALLS
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted && !isLoading && tempDataListForSearch.length < totalNumberOfRecord) {
          _fetchData();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchC = TextEditingController();
    initialIds =
        widget.initialValue.map<int>((e) => e['zAttributesId']).toList();
    
    // For single select, set the initial selected ID
    if (!widget.isMultiSelect && widget.initialValue.isNotEmpty) {
      selectedRadioId = widget.initialValue.first['zAttributesId'];
    }
    
    // SCROLL CONTROLLER
    scrollController = ScrollController();
    // SCROLL LISTENER IF DATA IS COMING FROM AN API
    if (widget.dataList.isEmpty) {
      scrollController.addListener(_onScroll);
      // Fetch initial data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchData();
        }
      });
    } else {
      tempDataListForSearch =
          widget.dataList.map((item) => Map<String, dynamic>.from(item)).toList();
      for (var item in tempDataListForSearch) {
        if (widget.isMultiSelect) {
          item['isChecked'] = widget.initialValue.any(
              (selected) => selected['zAttributesId'] == item['zAttributesId']);
        } else {
          if (widget.initialValue.isNotEmpty &&
              widget.initialValue.first['zAttributesId'] == item['zAttributesId']) {
            item['isChecked'] = true;
            selectedRadioId = item['zAttributesId'];
          } else {
            item['isChecked'] = false;
          }
        }
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchC.dispose();
    scrollController.dispose();
  }

  void _handleItemSelection(Map<String, dynamic> item) {
    setState(() {
      if (widget.isMultiSelect) {
        // Multi-select: toggle checkbox
        item['isChecked'] = !(item['isChecked'] ?? false);
      } else {
        // Single select: radio button behavior
        // Uncheck all items first
        for (var listItem in tempDataListForSearch) {
          listItem['isChecked'] = false;
        }
        // Check the selected item
        item['isChecked'] = true;
        selectedRadioId = item['zAttributesId'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SearchWidget(
            isFilterOn: false,
            textController: searchC,
            onSubmit: (string) async => await search(string),
          ),
        ),
        isLoading && tempDataListForSearch.isEmpty
            ? const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            : tempDataListForSearch.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(
                        "No Data For Selection",
                        style: AppTextStyle.ts16M(),
                      ),
                    ),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: tempDataListForSearch.length + 1,
                        itemBuilder: (context, index) {
                          if (tempDataListForSearch.length == index) {
                            if (isLoading) {
                              return const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [CircularProgressIndicator()],
                              );
                            } else {
                              return const SizedBox();
                            }
                          }
                          final item = tempDataListForSearch[index];
                          if (item['zAttributesId'] == -1) {
                            return const SizedBox();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return InkWell(
                                    onTap: () {
                                      _handleItemSelection(item);
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item['DisplayName'],
                                              style: AppTextStyle.ts14R(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: widget.isMultiSelect
                                                ? (item['isChecked'] ?? false
                                                    ? Icon(
                                                        Icons.check_box,
                                                        color: AppColor.green,
                                                        size: 20,
                                                      )
                                                    : Icon(
                                                        Icons.check_box_outline_blank,
                                                        color: AppColor.black,
                                                        size: 20,
                                                      ))
                                                : (item['isChecked'] ?? false
                                                    ? Icon(
                                                        Icons.radio_button_checked,
                                                        color: AppColor.primary,
                                                        size: 20,
                                                      )
                                                    : Icon(
                                                        Icons.radio_button_unchecked,
                                                        color: AppColor.black,
                                                        size: 20,
                                                      )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(height: 1, color: AppColor.grey30),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ButtonStyle(
              fixedSize: WidgetStateProperty.all(const Size(30, 40)),
              backgroundColor: WidgetStateProperty.all(AppColor.primary),
            ),
            onPressed: () {
              if (widget.isMultiSelect) {
                final selected = tempDataListForSearch
                    .where((e) => e['isChecked'] ?? false)
                    .toList();
                if (widget.onSelectCallback != null) {
                  widget.onSelectCallback!(selected);
                } else {
                  Navigator.of(context).pop(selected);
                }
              } else {
                // For single select, return a list with one item
                final selectedItem = tempDataListForSearch.firstWhere(
                  (e) => e['isChecked'] == true,
                  orElse: () => <String, dynamic>{},
                );
                if (selectedItem.isNotEmpty) {
                  if (widget.onSelectCallback != null) {
                    widget.onSelectCallback!([selectedItem]);
                  } else {
                    Navigator.of(context).pop([selectedItem]);
                  }
                } else {
                  if (widget.onSelectCallback != null) {
                    widget.onSelectCallback!([]);
                  } else {
                    Navigator.of(context).pop([]);
                  }
                }
              }
            },
            child: Text(
              'Select',
              style: AppTextStyle.ts14M(color: AppColor.white),
            ),
          ),
        ),
      ],
    );
  }
}
