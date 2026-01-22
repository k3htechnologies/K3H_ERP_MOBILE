import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/cubit/outdoor_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class OutdoorScreen extends StatefulWidget {
  const OutdoorScreen({super.key});

  @override
  State<OutdoorScreen> createState() => _OutdoorScreenState();
}

class _OutdoorScreenState extends State<OutdoorScreen> {
  // CUBIT
  late OutdoorCubit _outdoorCubit;

  // AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC, _conclusionC;

  @override
  void initState() {
    super.initState();
    _outdoorCubit = context.read<OutdoorCubit>();
    scrollController = ScrollController();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.outdoor]!;
    _initializeTextEditingController();
    _onScroll();
    _outdoorCubit.getOutdoorList(context, 1);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    _conclusionC.dispose();
    scrollController.dispose();
  }

  // INITIALIZE TEXT CONTROLLERS
  void _initializeTextEditingController() {
    _searchC = TextEditingController();
    _conclusionC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_outdoorCubit.state.isLoading! &&
          _outdoorCubit.state.outdoorList.length <
              _outdoorCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _outdoorCubit.getOutdoorList(
            context,
            _outdoorCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Outdoor",
        authorization: _routeAuthorizationModel,
        onExportCallback: (value) {
          _outdoorCubit.exportExcelPdf(context, value);
        },
        onAddCallback: () {},
        onSearchSubmit: (value) {
          _outdoorCubit.searchOutdoor(context, value);
        },
        textController: _searchC,
      ),
      body: BlocBuilder<OutdoorCubit, OutdoorState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.outdoorList.isEmpty) {
            return Center(child: loader());
          }
          if (state.outdoorList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _outdoorCubit.state.outdoorList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.outdoorList.length) {
                return state.outdoorList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var outdoor = state.outdoorList[index];
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _punchOutMissingWidget(
                          outdoor.punchIn,
                          outdoor.punchOut,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewOutdoor,
                                queryParameters: {
                                  "outdoor": Uri.encodeQueryComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(outdoor),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              formatDateTimeAsDDMMMYYYY(outdoor.outDoorDate),
                              style: AppTextStyle.ts16M(
                                color: AppColor.primary,
                              ),
                            ),
                          ),
                        ),
                        horizontalSpacing(),
                        Row(
                          children: [CustomIconButton.edit(onPressed: () {})],
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('hh:mm a').format(outdoor.outDoorTime),
                      style: AppTextStyle.ts14M(),
                    ),
                    verticalSpacing(),
                    _statusButton(outdoor.punchIn, outdoor.punchOut),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // HELPER WIDGET
  Widget _statusButton(DateTime? punchInTime, DateTime? punchOutTime) {
    String status;

    if (punchInTime == null) {
      status = "punchin";
    } else if (punchOutTime == null) {
      status = "punchout";
    } else {
      status = "conclusion";
    }

    late String buttonText;
    late Color bgColor;
    late Color textColor;

    VoidCallback? onTap;

    switch (status) {
      case "punchin":
        buttonText = "Punch In";
        bgColor = AppColor.lightGreen;
        textColor = AppColor.darkGreen;
        onTap = () {
          // Punch In logic
        };
        break;

      case "punchout":
        buttonText = "Punch Out";
        bgColor = AppColor.lightBlue;
        textColor = AppColor.primary;
        onTap = () {
          // Punch Out logic
        };
        break;

      default:
        buttonText = "Conclusion";
        bgColor = AppColor.purple20;
        textColor = AppColor.purple;
        onTap = () {
          DialogHelper.showCustomDialogue(
            context,
            title: "Add Conclusion",
            childContent: Column(
              children: [
                CustomTextField(
                  textController: _conclusionC,
                  isRequired: true,
                  hint: "Enter Conclusion",
                  minLines: 3,
                  maxLines: 3,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter conclusion";
                    }
                    return null;
                  },
                ),
              ],
            ),
            bottomSection: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: CustomButton(
                    text: "Clear",
                    onPressed: () {},
                    backgroundColor: AppColor.grey,
                  ),
                ),
                Spacer(),
                SizedBox(
                  width: 120,
                  child: CustomButton(text: "Save", onPressed: () {}),
                ),
              ],
            ),
          );
        };
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, size: 16, color: textColor),
            const SizedBox(width: 4),
            Text(buttonText, style: AppTextStyle.ts14M(color: textColor)),
          ],
        ),
      ),
    );
  }

  // <---- PADDING WIDGET ---->
  Widget _punchOutMissingWidget(DateTime? punchInTime, DateTime? punchOutTime) {
    final DateTime today = DateTime.now();

    bool isPreviousDay = false;

    if (punchInTime != null) {
      final DateTime punchDate = DateTime(
        punchInTime.year,
        punchInTime.month,
        punchInTime.day,
      );

      final DateTime currentDate = DateTime(today.year, today.month, today.day);

      isPreviousDay = punchDate.isBefore(currentDate);
    }

    final bool isVisible =
        punchInTime != null && punchOutTime == null && isPreviousDay;

    return Visibility(
      visible: isVisible,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: AppColor.warning, size: 16),
          horizontalSpacing(),
        ],
      ),
    );
  }
}
