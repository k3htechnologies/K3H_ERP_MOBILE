import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/login/presentation/cubit/login_cubit.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/approve_reject_widget.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // CUBIT
  late LoginCubit _loginCubit;
  late BookingCubit _bookingCubit;

  // AUTHORIZATION
  late AuthorizationModel _routhAuthorizationModel;

  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  // PROJECT
  late ProjectModel _project;

  // TEXT EDITING CONTROLLERS
  late TextEditingController _searchC;

  @override
  void initState() {
    super.initState();
    _loginCubit = context.read<LoginCubit>();
    _bookingCubit = context.read<BookingCubit>();
    _project = getProject();
    _routhAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.booking]!;
    _initializeTextEditingController();
    _onScroll();
    _bookingCubit.getBookingList(context, 1, _project.projectId);
  }

  @override
  void dispose() {
    super.dispose();
    _searchC.dispose();
    scrollController.dispose();
  }

  void _initializeTextEditingController() {
    _searchC = TextEditingController();
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_bookingCubit.state.isLoading! &&
          _bookingCubit.state.bookingList.length <
              _bookingCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _bookingCubit.getBookingList(
            context,
            _bookingCubit.state.currentPage + 1,
            _project.projectId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Booking",
        authorization: _routhAuthorizationModel,
        textController: _searchC,
        onSearchSubmit: (value) {
          _bookingCubit.searchBooking(context, value);
        },
        onExportCallback: (value) {
          if (_bookingCubit.state.totalNumberOfRecord == 0) {
            showErrorMessage(context, "Error", "No Data Found");
            return;
          }
          _bookingCubit.exportExcelPdf(context, value, getProject().projectId);
        },
        onProjectChangeCallback: (value) {
          _project = value;
          _bookingCubit.getBookingList(context, 1, value.projectId);
        },
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.bookingList.isEmpty) {
            return Center(child: loader());
          }
          if (state.bookingList.isEmpty) {
            return Center(
              child: noDataWidget(message: "No Booking Data Found"),
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _bookingCubit.state.bookingList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.bookingList.length) {
                return state.bookingList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              var booking = state.bookingList[index];
              // IF BOOKING IS NOT APPROVED OR USER HAS NO ACTION PERMISSION,
              // THEN ACTIONS ARE CONSIDERED ALREADY PERFORMED -> SHOW HISTORY AND DISABLE ACTIONS
              final bool isActionAllowed =
                  booking.isApproval && _routhAuthorizationModel.isAction;
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              goRouter.pushNamed(
                                AppRoutes.viewBooking,
                                queryParameters: {
                                  "booking": Uri.encodeComponent(
                                    EncryptionManager.encryptData(
                                      jsonEncode(booking),
                                    ),
                                  ),
                                },
                              );
                            },
                            child: Text(
                              booking.applicantName,
                              style: AppTextStyle.ts14M(
                                color: AppColor.primary,
                              ).copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColor.primary,
                              ),
                            ),
                          ),
                        ),

                        _routhAuthorizationModel.isAction &&
                                booking.approvalStatus.toLowerCase() !=
                                    'approved'
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconButton.edit(
                                  onPressed: () {
                                    goRouter.pushNamed(
                                      AppRoutes.addBooking,
                                      queryParameters: {
                                        "booking": Uri.encodeComponent(
                                          EncryptionManager.encryptData(
                                            jsonEncode(booking),
                                          ),
                                        ),
                                        "index": index.toString(),
                                      },
                                    );
                                  },
                                ),
                                horizontalSpacing(),
                              ],
                            )
                            : SizedBox.shrink(),
                        statusWidget(booking.approvalStatus),
                      ],
                    ),
                    verticalSpacing(height: 5),
                    buildRowTitleValue(
                      title: "Enquiry Code",
                      value: booking.systemGeneratedCode,
                      fixesWidth: 190,
                    ),
                    buildRowTitleValue(
                      title: "Flat",
                      value: booking.flat,
                      fixesWidth: 190,
                    ),
                    buildRowTitleValue(
                      title: "Category",
                      value: booking.flatType,
                      fixesWidth: 190,
                    ),
                    buildRowTitleValue(
                      title: "Flat Configuration:",
                      value: booking.flatConfiguration,
                      fixesWidth: 190,
                    ),
                    buildRowTitleValue(
                      title: "Agreement Value (₹)",
                      value: booking.agreementValue.toString(),
                      fixesWidth: 190,
                    ),
                    buildRowTitleValue(
                      title: "Expected Registration",
                      value: formatDateTimeAsDDMMMYYYY(
                        booking.registrationDate,
                      ),
                      fixesWidth: 190,
                    ),
                    verticalSpacing(),
                    ApproveRejectWidget(
                      title: isActionAllowed ? "Actions" : "History",
                      isActionAlreadyPerformed: !isActionAllowed,
                      onApprove: (val) async {
                        await _loginCubit.updateModulesWorkflowApproval(
                          context: context,
                          moduleName: 'BOOKING APPROVAL',
                          id: booking.bookingId,
                          projectId: _project.projectId,
                          isApproved: true,
                          remark: val.trim(),
                        );
                        if (context.mounted) {
                          _bookingCubit.getBookingList(
                            context,
                            1,
                            _project.projectId,
                          );
                        }
                      },
                      onReject: (val) async {
                        await _loginCubit.updateModulesWorkflowApproval(
                          context: context,
                          moduleName: 'BOOKING APPROVAL',
                          id: booking.bookingId,
                          projectId: _project.projectId,
                          isApproved: false,
                          remark: val.trim(),
                        );
                        if (context.mounted) {
                          _bookingCubit.getBookingList(
                            context,
                            1,
                            _project.projectId,
                          );
                        }
                      },
                      onThirdTap: () async {
                        final approvalLogHistoryList = await _loginCubit
                            .getApprovalLogHistory(
                              context,
                              _project.projectId,
                              booking.bookingId,
                              "BOOKING APPROVAL",
                            );

                        if (context.mounted) {
                          goRouter.pushNamed(
                            AppRoutes.approvalLogHistory,
                            queryParameters: {
                              "subTitle": Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  "${booking.buildingNumber} > ${booking.wing}",
                                ),
                              ),
                              "approvalList": Uri.encodeComponent(
                                EncryptionManager.encryptData(
                                  jsonEncode(
                                    approvalLogHistoryList
                                        .map((e) => e.toJson())
                                        .toList(),
                                  ),
                                ),
                              ),
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget statusWidget(String status) {
    final trimmed = status.trim();

    final s = trimmed.toLowerCase();

    switch (s) {
      case 'approved':
        return statusChip(status, AppColor.green20, AppColor.green);

      case 'rejected':
        return statusChip(status, AppColor.lightRed, AppColor.red);

      case 'pending':
        return statusChip(status, AppColor.lightYellow, AppColor.brown);

      case 'partially approved':
        return statusChip(status, AppColor.lightPurple, AppColor.purple);

      default:
        return statusChip(status, AppColor.lightGreyBackground, AppColor.black);
    }
  }
}
