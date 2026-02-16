import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/booking/presentation/cubit/booking_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
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
        onSearchSubmit: (value) {},
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addBooking);
        },
        onExportCallback: (value) {},
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
            return Center(child: noDataWidget());
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
                        Text(
                          booking.approvalStatus,
                          style: AppTextStyle.ts14M(),
                        ),
                        horizontalSpacing(),
                        Row(
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
                            CustomIconButton.delete(onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                    buildRowTitleValue(
                      title: "Flat No.",
                      value: booking.flat,
                      fixesWidth: 190,
                    ),
                    buildRowTitleValue(
                      title: "Category",
                      value: booking.flatType,
                      fixesWidth: 190,
                    ),
                    buildRowTitleValue(
                      title: "Configuration-RERA Area:",
                      value: booking.reraCarpetAreaSqFt.toString(),
                      fixesWidth: 190,
                    ),
                    buildRowTitleValue(
                      title: "Agreement Value (in ₹)",
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
