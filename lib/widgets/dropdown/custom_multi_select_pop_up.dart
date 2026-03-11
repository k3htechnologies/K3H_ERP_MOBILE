import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/app_bar/search_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CustomMultipleSelectPopup extends StatefulWidget {
  final List<Map<String, dynamic>>? dataList;
  final Function(List<Map<String, dynamic>>) onSelected;
  final List<Map<String, dynamic>>? initialValue;
  final String? title;
  final bool isRequired;
  final String? hintText;
  final Future<Map<String, dynamic>> Function(int pageNumber, {String? value})
  dataFetchCallBack;
  final String? Function(List<Map<String, dynamic>>?)? validator;
  final bool isMultiSelect;
  final VoidCallback? onClear;

  const CustomMultipleSelectPopup({
    super.key,
    required this.dataFetchCallBack,
    required this.onSelected,
    this.title,
    this.isRequired = false,
    this.hintText,
    this.validator,
    this.initialValue,
    this.dataList,
    this.isMultiSelect = true,
    this.onClear,
  });

  @override
  State<CustomMultipleSelectPopup> createState() =>
      _CustomMultipleSelectPopupState();

  static Future<List<Map<String, dynamic>>?> showBottomSheet({
    required BuildContext context,
    required String title,
    required Future<Map<String, dynamic>> Function(
      int pageNumber, {
      String? value,
    })
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
        final double bottomSheetHeight = (screenHeight * 0.5).clamp(
          400.0,
          700.0,
        );
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
                    Expanded(child: Text(title, style: AppTextStyle.ts20M())),
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

class _CustomMultipleSelectPopupState extends State<CustomMultipleSelectPopup> {
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
        final double bottomSheetHeight = (screenHeight * 0.7).clamp(
          400.0,
          700.0,
        );
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
                    Expanded(child: Text(title, style: AppTextStyle.ts20M())),
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          context.pop();
                        }
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
                  dataList:
                      dataList
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
  void didUpdateWidget(covariant CustomMultipleSelectPopup oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        selectedValues = List<Map<String, dynamic>>.from(
          widget.initialValue ?? [],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (widget.title != null)
          Row(
            children: [
              Text(widget.title!, style: AppTextStyle.ts14R()),
              widget.isRequired
                  ? Text("*", style: AppTextStyle.ts14R(color: AppColor.error))
                  : SizedBox(),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: FormField<List<Map<String, dynamic>>>(
            validator: widget.validator,
            initialValue: selectedValues,
            builder: (
              FormFieldState<List<Map<String, dynamic>>> formFieldState,
            ) {
              final hasError = formFieldState.hasError;
              final borderColor = hasError ? AppColor.error : AppColor.grey30;

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
                        border: Border.all(color: borderColor, width: 1.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10.0,
                      ),
                      child:
                          selectedValues.isNotEmpty
                              ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child:
                                        widget.isMultiSelect
                                            ? Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children:
                                                  selectedValues.map<Widget>((
                                                    e,
                                                  ) {
                                                    return Chip(
                                                      color:
                                                          const WidgetStatePropertyAll(
                                                            AppColor.lightBlue,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                        side: BorderSide(
                                                          color:
                                                              AppColor.grey30,
                                                          width: .5,
                                                        ),
                                                      ),
                                                      label: Text(
                                                        e['DisplayName'] ?? '',
                                                        style:
                                                            AppTextStyle.ts14M(),
                                                      ),
                                                      deleteIcon: const Icon(
                                                        Icons.close,
                                                        size: 18,
                                                      ),
                                                      onDeleted: () {
                                                        setState(() {
                                                          selectedValues.removeWhere(
                                                            (s) =>
                                                                s['zAttributesId'] ==
                                                                e['zAttributesId'],
                                                          );
                                                        });
                                                        formFieldState
                                                            .didChange(
                                                              selectedValues,
                                                            );
                                                        widget.onSelected(
                                                          selectedValues,
                                                        );
                                                      },
                                                    );
                                                  }).toList(),
                                            )
                                            : Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    selectedValues
                                                            .first['DisplayName'] ??
                                                        '',
                                                    style: AppTextStyle.ts14M(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedValues = [];
                                                    });
                                                    formFieldState.didChange(
                                                      selectedValues,
                                                    );
                                                    widget.onSelected(
                                                      selectedValues,
                                                    );

                                                    if (widget.onClear !=
                                                        null) {
                                                      widget.onClear!();
                                                    }
                                                  },
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              )
                              : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.hintText ?? 'Select',
                                    style: AppTextStyle.ts14R(
                                      color: AppColor.grey,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 24,
                                  ),
                                ],
                              ),
                    ),
                  ),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColor.error,
                            size: 14,
                          ),
                          horizontalSpacing(width: 5),
                          Text(
                            formFieldState.errorText ?? '',
                            style: AppTextStyle.ts14R(color: AppColor.error),
                          ),
                        ],
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

class _DropdownList extends DropdownList {
  const _DropdownList({
    required super.dataList,
    required super.initialValue,
    required super.dataFetchCallBack,
    required super.isMultiSelect,
  }) : super(key: null, onSelectCallback: null);
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

  dynamic selectedRadioId;

  List<Map<String, dynamic>> _localSelectedValues = [];

  Future<void> _fetchData() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final result = await widget.dataFetchCallBack(
      currentPage++,
      value: searchText,
    );

    final itemList = result['itemList'] ?? result['data'] ?? [];
    List<Map<String, dynamic>> fetchedItems =
        (itemList as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

    for (int i = 0; i < fetchedItems.length; i++) {
      final item = fetchedItems[i];
      if (widget.isMultiSelect) {
        fetchedItems[i] = {
          ...item,
          'isChecked': _localSelectedValues.any(
            (selected) => selected['zAttributesId'] == item['zAttributesId'],
          ),
        };
      } else {
        if (_localSelectedValues.isNotEmpty &&
            _localSelectedValues.first['zAttributesId'] ==
                item['zAttributesId']) {
          fetchedItems[i] = {...item, 'isChecked': true};
          selectedRadioId = item['zAttributesId'];
        } else {
          fetchedItems[i] = {...item, 'isChecked': false};
        }
      }
    }

    if (widget.isMultiSelect) {
      if (searchText.isEmpty) {
        for (var selected in _localSelectedValues) {
          if (!fetchedItems.any(
            (item) => item['zAttributesId'] == selected['zAttributesId'],
          )) {
            // Add previously selected item to list so it shows in UI
            fetchedItems.insert(0, {
              'zAttributesId': selected['zAttributesId'],
              'DisplayName': selected['DisplayName'],
              'isChecked': true,
            });
          }
        }
      }
    } else {
      if (_localSelectedValues.isNotEmpty) {
        final initialItem = _localSelectedValues.first;
        if (!fetchedItems.any(
          (item) => item['zAttributesId'] == initialItem['zAttributesId'],
        )) {
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

      final Map<dynamic, Map<String, dynamic>> uniqueMap = {
        for (var item in tempDataListForSearch) item['zAttributesId']: item,
      };

      for (var item in fetchedItems) {
        uniqueMap[item['zAttributesId']] = item;
      }

      tempDataListForSearch = uniqueMap.values.toList();
      isLoading = false;
    });
  }

  Future<void> search(String searchText) async {
    this.searchText = searchText;
    currentPage = 1;
    totalNumberOfRecord = 0;
    tempDataListForSearch.clear();
    _fetchData();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (isLoading) return;
    if (widget.dataList.isNotEmpty && searchText.isEmpty) return;
    if (tempDataListForSearch.length >= totalNumberOfRecord) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted &&
            !isLoading &&
            tempDataListForSearch.length < totalNumberOfRecord) {
          _fetchData();
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchC = TextEditingController();
    _localSelectedValues =
        widget.initialValue.map((e) => Map<String, dynamic>.from(e)).toList();
    initialIds =
        widget.initialValue
            .where((e) => e['zAttributesId'] != null)
            .map<int>(
              (e) =>
                  e['zAttributesId'] is int
                      ? e['zAttributesId']
                      : int.tryParse(e['zAttributesId'].toString()) ?? -1,
            )
            .toList();

    // For single select, set the initial selected ID
    if (!widget.isMultiSelect && widget.initialValue.isNotEmpty) {
      final firstItem = widget.initialValue.first;
      if (firstItem['zAttributesId'] != null) {
        selectedRadioId = firstItem['zAttributesId'];
      }
    }

    // SCROLL CONTROLLER
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    if (widget.dataList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchData();
        }
      });
    } else {
      tempDataListForSearch =
          widget.dataList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
      for (int i = 0; i < tempDataListForSearch.length; i++) {
        final item = tempDataListForSearch[i];
        if (widget.isMultiSelect) {
          tempDataListForSearch[i] = {
            ...item,
            'isChecked': widget.initialValue.any(
              (selected) => selected['zAttributesId'] == item['zAttributesId'],
            ),
          };
        } else {
          if (widget.initialValue.isNotEmpty &&
              widget.initialValue.first['zAttributesId'] ==
                  item['zAttributesId']) {
            tempDataListForSearch[i] = {...item, 'isChecked': true};
            selectedRadioId = item['zAttributesId'];
          } else {
            tempDataListForSearch[i] = {...item, 'isChecked': false};
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
        final index = tempDataListForSearch.indexWhere(
          (e) => e['zAttributesId'] == item['zAttributesId'],
        );
        if (index != -1) {
          final newChecked =
              !(tempDataListForSearch[index]['isChecked'] ?? false);
          tempDataListForSearch[index] = {
            ...tempDataListForSearch[index],
            'isChecked': newChecked,
          };
          if (newChecked) {
            if (!_localSelectedValues.any(
              (s) => s['zAttributesId'] == item['zAttributesId'],
            )) {
              _localSelectedValues.add({
                'zAttributesId': item['zAttributesId'],
                'DisplayName': item['DisplayName'],
                ...item,
              });
            }
          } else {
            _localSelectedValues.removeWhere(
              (s) => s['zAttributesId'] == item['zAttributesId'],
            );
          }
        }
      } else {
        for (int i = 0; i < tempDataListForSearch.length; i++) {
          final isSelected =
              tempDataListForSearch[i]['zAttributesId'] ==
              item['zAttributesId'];
          tempDataListForSearch[i] = {
            ...tempDataListForSearch[i],
            'isChecked': isSelected,
          };
          if (isSelected) {
            selectedRadioId = item['zAttributesId'];
          } else {
            if (selectedRadioId == item['zAttributesId']) {
              selectedRadioId = null;
            }
          }
        }
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
            ? const Expanded(child: Center(child: CircularProgressIndicator()))
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
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child:
                                          widget.isMultiSelect
                                              ? (item['isChecked'] ?? false
                                                  ? Icon(
                                                    Icons.check_box,
                                                    color: AppColor.primary,
                                                    size: 20,
                                                  )
                                                  : Icon(
                                                    Icons
                                                        .check_box_outline_blank,
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
                                                    Icons
                                                        .radio_button_unchecked,
                                                    color: AppColor.black,
                                                    size: 20,
                                                  )),
                                    ),
                                    Flexible(
                                      child: Text(
                                        item['DisplayName'],
                                        style: AppTextStyle.ts14R(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ButtonStyle(
                fixedSize: WidgetStateProperty.all(const Size(30, 40)),
                backgroundColor: WidgetStateProperty.all(AppColor.primary),
              ),
              onPressed: () {
                if (widget.isMultiSelect) {
                  final result = List<Map<String, dynamic>>.from(
                    _localSelectedValues,
                  );

                  if (widget.onSelectCallback != null) {
                    widget.onSelectCallback!(result);
                  } else {
                    Navigator.of(context).pop(result);
                  }
                } else {
                  final selectedItem = tempDataListForSearch.firstWhere(
                    (e) => e['isChecked'] == true,
                    orElse: () => <String, dynamic>{},
                  );

                  List<Map<String, dynamic>> result;

                  if (selectedItem.isNotEmpty) {
                    result = <Map<String, dynamic>>[selectedItem];
                  } else {
                    result = <Map<String, dynamic>>[];
                  }

                  if (widget.onSelectCallback != null) {
                    widget.onSelectCallback!(result);
                  } else {
                    Navigator.of(context).pop(result);
                  }
                }
              },
              child: Text(
                'Select',
                style: AppTextStyle.ts14M(color: AppColor.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
