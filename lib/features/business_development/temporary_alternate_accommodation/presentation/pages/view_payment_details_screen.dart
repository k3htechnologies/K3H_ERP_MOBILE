import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/payment_ledger.model.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/data/model/temporary_alternate_accommodation.model.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/features/business_development/temporary_alternate_accommodation/presentation/cubit/temporary_alternate_accommodation_cubit.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class ViewPaymentDetailsScreen extends StatefulWidget {
  final TemporaryAlternativeAccommodationModel rentModel;
  final double totalAmount;
  final PaymentLedgerModel paymentLedger;

  const ViewPaymentDetailsScreen({
    super.key,
    required this.rentModel,
    required this.totalAmount,
    required this.paymentLedger,
  });
  @override
  State<ViewPaymentDetailsScreen> createState() =>
      _ViewPaymentDetailsScreenState();
}

class _ViewPaymentDetailsScreenState extends State<ViewPaymentDetailsScreen> {
  late TemporaryAlternateAccommodationCubit
  _temporaryAlternateAccommodationCubit;

  late AuthorizationModel _routeAuthorizationModel;

  @override
  void initState() {
    super.initState();
    _temporaryAlternateAccommodationCubit =
        context.read<TemporaryAlternateAccommodationCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Temporary Alternate\nAccommodation",
        authorization: _routeAuthorizationModel,
        extraHeight: 20,
        showMenuIcon: false,
        searchHintText: 'Search byFlat Number or Applicant Name',
        textController: TextEditingController(),
        onSearchSubmit: (value) {
          _temporaryAlternateAccommodationCubit.onPaymentLedgerSearch(
            context: context,
            value: value,
            tenantId: widget.rentModel.tenantId,
            tenantApplicantId: widget.rentModel.tenantApplicantId,
            buildingId: widget.rentModel.buildingId,
            projectId: widget.rentModel.projectId,
          );
        },
        onAddCallback: () {
          goRouter.pushNamed(
            AppRoutes.addPayment,
            queryParameters: {
              'rent': Uri.encodeComponent(
                EncryptionManager.encryptData(
                  jsonEncode(widget.rentModel.toJson()),
                ),
              ),

              'totalAmount': widget.totalAmount.toString(),
              'paidAmount':
                  _temporaryAlternateAccommodationCubit.paidAmountForSummary
                      ?.toString(),
              'previousRoute': AppRoutes.viewSummary,
            },
          );
        },
      ),
      body: BlocBuilder<
        TemporaryAlternateAccommodationCubit,
        TemporaryAlternateAccommodationState
      >(
        builder: (context, state) {
          if (state.isLoading == true &&
              (state.paymentLedgerList ?? []).isEmpty) {
            return Center(child: loader());
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              spacing: 16,
              children: [
                infoCard([
                  {
                    "title": "Flat Number",
                    "value": widget.rentModel.flatNumber,
                  },
                  {
                    "title": "Applicant Name",
                    "value": widget.rentModel.applicantName,
                  },
                  {"title": "Tenure", "value": widget.rentModel.tenure},
                  {
                    "title": "Charge Type",
                    "value":
                        context
                            .read<TemporaryAlternateAccommodationCubit>()
                            .state
                            .currentTabName,
                  },
                  {
                    "title": "Carpet Area (SqFt)",
                    "value":
                        '${widget.rentModel.flatCarpetAreaSqFt.addCommas()} SqFt',
                  },
                  {"title": "Unit Type", "value": widget.rentModel.flatType},
                  {
                    "title": "Total Amount",
                    "value": widget.totalAmount.toIndianCurrency(),
                  },
                  {
                    "title": "Paid Total Amount",
                    "value":
                        _temporaryAlternateAccommodationCubit
                            .paidAmountForSummary
                            ?.toIndianCurrency(),
                  },
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
