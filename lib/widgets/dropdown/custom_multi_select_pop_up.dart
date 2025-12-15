import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
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

  const CustomMultipleSelectPopup({
    super.key,
    required this.dataFetchCallBack,
    required this.onSelected,
    this.title,
    this.validator,
    this.initialValue,
    this.dataList,
  });

  @override
  State<CustomMultipleSelectPopup> createState() =>
      _CustomMultipleSelectPopupState();
}

class _CustomMultipleSelectPopupState
    extends State<CustomMultipleSelectPopup> {
  late List<Map<String, dynamic>> selectedValues;

  Future<List<Map<String, dynamic>>?> showPopupForDropdown(
      BuildContext context, {
        required List<Map<String, dynamic>> dataList,
        required String title,
        String? Function(Map<String, dynamic>?)? validator,
        List<Map<String, dynamic>>? initialValue,
      }) async {
    return showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final double dialogWidth =
        (screenSize.width * 0.45).clamp(360.0, 560.0);
        final double dialogHeight =
        (screenSize.height * 0.6).clamp(320.0, 460.0);
        return Dialog(
          backgroundColor: AppColor.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(title, style: AppTextStyle.ts20M())),
                      GestureDetector(
                        onTap: () {
                          goRouter.pop();
                        },
                        child: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1.0,
                  decoration: BoxDecoration(color: AppColor.grey),
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
                  ),
                ),
              ],
            ),
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
                      var value = await showPopupForDropdown(
                        context,
                        title: 'Search',
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
                      child:
                      selectedValues.isNotEmpty
                          ? Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              selectedValues
                                  .map((e) => e['DisplayName'])
                                  .join(', '),
                              style: AppTextStyle.ts14M(),
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

class _DropdownList extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final List<Map<String, dynamic>> initialValue;
  final Future<Map<String, dynamic>> Function(int pageNumber, {String? value})
  dataFetchCallBack;

  const _DropdownList({
    required this.dataList,
    required this.initialValue,
    required this.dataFetchCallBack,
  });

  @override
  State<_DropdownList> createState() => _DropdownListState();
}

class _DropdownListState extends State<_DropdownList> {
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

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    final result = await widget.dataFetchCallBack(
      currentPage++,
      value: searchText,
    );

    List<Map<String, dynamic>> fetchedItems =
    List<Map<String, dynamic>>.from(result['itemList']);

    // Mark API items as checked if already selected
    for (var item in fetchedItems) {
      item['isChecked'] = widget.initialValue
          .any((selected) => selected['zAttributesId'] == item['zAttributesId']);
    }

    // Merge selected items that are not in fetched list yet
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

    setState(() {
      totalNumberOfRecord = result["totalNumberOfRecord"];
      tempDataListForSearch.addAll(fetchedItems);
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

  // PAGINATION
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 100 &&
        !isLoading &&
        tempDataListForSearch.length < totalNumberOfRecord) {
      // TO HANDLE MULTIPLE TIME API CALLS
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _fetchData();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchC = TextEditingController();
    initialIds =
        widget.initialValue.map<int>((e) => e['zAttributesId']).toList();
    // SCROLL CONTROLLER
    scrollController = ScrollController();
    // SCROLL LISTENER IF DATA IS COMING FROM AN API
    if (widget.dataList.isEmpty) {
      scrollController.addListener(_onScroll);
      _fetchData();
    } else {
      tempDataListForSearch =
          widget.dataList.map((item) => Map<String, dynamic>.from(item)).toList();
      for (var item in tempDataListForSearch) {
        item['isChecked'] = widget.initialValue.any(
              (selected) => selected['zAttributesId'] == item['zAttributesId'],
        );
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SearchWidget(
            isFilterOn: false,
            textController: searchC,
            onSubmit: (string) async => await search(string),
          ),
        ),

        isLoading && tempDataListForSearch.isEmpty
            ? Expanded(
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
            : Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              controller: scrollController,
              itemCount: tempDataListForSearch.length + 1,
              itemBuilder: (context, index) {
                if (tempDataListForSearch.length == index) {
                  if (isLoading) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    );
                  } else {
                    return SizedBox();
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
                            setState(() {
                              item['isChecked'] =
                              !(item['isChecked'] ?? false);
                            });
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
                                  padding: EdgeInsets.only(right: 10),
                                  child:
                                  item['isChecked'] ?? false
                                      ? Icon(
                                    Icons.check_box,
                                    color: AppColor.green,
                                    size: 20,
                                  )
                                      : Icon(
                                    Icons.check_box_outline_blank,
                                    color: AppColor.black,
                                    size: 20,
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ButtonStyle(
              fixedSize: WidgetStateProperty.all(Size(30, 40)),
              backgroundColor: WidgetStateProperty.all(AppColor.primary),
            ),
            onPressed: () {
              goRouter.pop(
                tempDataListForSearch
                    .where((e) => e['isChecked'] ?? false)
                    .toList(),
              );
            },
            child: Text('Select',style: AppTextStyle.ts14M(color: AppColor.white),),
          ),
        ),
      ],
    );
  }
}