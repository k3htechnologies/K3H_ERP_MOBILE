import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/resignation/data/model/resignation.model.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/cubit/resignation_cubit.dart';
import 'package:k3h_erp_app/features/payroll/resignation/presentation/cubit/resignation_state.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ResignationScreen extends StatefulWidget {
  const ResignationScreen({super.key});

  @override
  State<ResignationScreen> createState() => _ResignationScreenState();
}

class _ResignationScreenState extends State<ResignationScreen> {
  //CUBIT
  late ResignationCubit _resignationCubit;
  //AUTHORIZATION
  late AuthorizationModel _routeAuthorizationModel;
  // PAGINATION
  late ScrollController scrollController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _resignationCubit = context.read<ResignationCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.resignation]!;
    _onScroll();
    _resignationCubit.getResignationList(context, 1);
  }

  // <---- PAGINATION ---->
  void _onScroll() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !_resignationCubit.state.isLoading! &&
          _resignationCubit.state.resignationList.length <
              _resignationCubit.state.totalNumberOfRecord) {
        // TO HANDLE MULTIPLE TIME API CALLS
        if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 300), () {
          _resignationCubit.getResignationList(
            context,
            _resignationCubit.state.currentPage + 1,
          );
        });
      }
    });
  }

  // <---- DELETE RESIGNATION ---->
  Future<void> _showPopupToDeleteResignation(
    BuildContext context,
    ResignationModel obj,
    int currentPage,
    int index,
  ) async {
    var result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a resignation?',
      'Deleting this resignation will permanently remove its contents.',
    );
    if (result && context.mounted) {
      _resignationCubit.deleteResignation(
        context: context,
        resignationId: obj.employeeResignationId,
        uniqueKey: obj.uniqueKey,
        pageNumber: currentPage,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Resignation',
        authorization: _routeAuthorizationModel,
        onAddCallback: () async {
          await goRouter.pushNamed(AppRoutes.addresignation);
          if (context.mounted) {
            _resignationCubit.getResignationList(context, 1);
          }
        },
      ),
      body: BlocBuilder<ResignationCubit, ResignationState>(
        builder: (context, state) {
          if ((state.isLoading ?? true) && state.resignationList.isEmpty) {
            return Center(child: loader());
          }
          if (state.resignationList.isEmpty) {
            return Center(child: noDataWidget());
          }
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: state.resignationList.length + 1,
            itemBuilder: (context, index) {
              if (index == state.resignationList.length) {
                return state.resignationList.length < state.totalNumberOfRecord
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox.shrink();
              }
              final resignation = state.resignationList[index];

              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: commonCardDecoration(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              resignation.employeeName,
                              style: AppTextStyle.ts16M(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        _statusButton(resignation, index),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomIconButton.edit(
                              onPressed: () async {
                                await goRouter.pushNamed(
                                  AppRoutes.addresignation,
                                  queryParameters: {
                                    "resignation": Uri.encodeQueryComponent(
                                      EncryptionManager.encryptData(
                                        jsonEncode(resignation),
                                      ),
                                    ),
                                    'index': index.toString(),
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomIconButton.delete(
                              onPressed: () {
                                _showPopupToDeleteResignation(
                                  context,
                                  resignation,
                                  state.currentPage,
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpacing(height: 10),

                    buildRowTitleValue(
                      title: "Resignation Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        resignation.resignationDate,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Expected Relieving Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        resignation.resignationDate,
                      ),
                    ),
                    buildRowTitleValue(
                      title: "Offer In Hand",
                      value: resignation.isAnyOfferInHand ? "Yes" : "No",
                    ),
                    buildRowTitleValue(
                      title: "Offer Amount",
                      value: resignation.offerAmount.toString(),
                    ),
                    buildRowTitleValue(
                      title: "Reason Of Leaving",
                      value: resignation.reasonOfLeaving,
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

  // HELPER WIDGET
  Widget _statusButton(ResignationModel resignation, int index) {
    String status;
    status = '';

    late String buttonText;
    late Color bgColor;
    late Color textColor;

    VoidCallback? onTap;

    switch (status) {
      default:
        buttonText = "Pending";
        bgColor = AppColor.darkBlue;
        textColor = AppColor.white;
        onTap = () {};
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Text(buttonText, style: AppTextStyle.ts14M(color: textColor)),
      ),
    );
  }
}
