import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/company_master/data/model/company_bank.model.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/status/status.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompanyBankDetails extends StatefulWidget {
  const CompanyBankDetails({super.key});

  @override
  State<CompanyBankDetails> createState() => _CompanyBankDetailsState();
}

class _CompanyBankDetailsState extends State<CompanyBankDetails> {
  late CompanyMasterCubit _companyMasterCubit;
  late AuthorizationModel _routeAuthorizationModel;
  @override
  void initState() {
    _companyMasterCubit = context.read<CompanyMasterCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.companyMaster] ??
        AuthorizationModel();
    super.initState();
  }

  Future<void> _showDeleteCompanyBankDetailsDialog(
    BuildContext context,
    CompanyBankModel bank,
    int index,
  ) async {
    final result = await DialogHelper.deleteDialog(
      context,
      'You are about to delete a bank ?',
      'Deleting this bank will permanently remove all associated data.',
    );
    if (result && context.mounted) {
      await _companyMasterCubit.deleteCompanyWithBankDetails(
        context: context,
        companyMasterId: bank.companyId,
        uniqueKey: bank.uniquekey,
        companyWithBankDetailsId: bank.companyWithBankDetailsId,
        index: index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyMasterCubit, CompanyMasterState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(
                    "${(state.bankDetailList?.isEmpty ?? true) ? 'Add' : 'Update'} Bank Details",
                    style: AppTextStyle.ts16SB(),
                  ),
                  Spacer(),
                  CustomButton(
                    isDisable: !_routeAuthorizationModel.isAction,
                    onPressed: () {
                      goRouter.pushNamed(AppRoutes.addCompanyBankDetails);
                    },
                    text: "Add",
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    backgroundColor: AppColor.primary,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.bankDetailList == null) {
                    return loader();
                  }
                  if (state.bankDetailList!.isEmpty) {
                    return Center(
                      child: noDataWidget(message: "No Bank's Found"),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.bankDetailList!.length,
                    itemBuilder: (context, index) {
                      final bank = state.bankDetailList![index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(color: AppColor.primary, width: 4),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    bank.beneficiaryAccountHolderName,
                                    style: AppTextStyle.ts16SB(),
                                  ),
                                ),
                                horizontalSpacing(),
                                Row(
                                  children: [
                                    CustomIconButton.edit(
                                      isDisabled:
                                          !_routeAuthorizationModel.isAction,
                                      onPressed: () {
                                        goRouter.pushNamed(
                                          AppRoutes.addCompanyBankDetails,
                                          queryParameters: {
                                            'bank': Uri.encodeQueryComponent(
                                              EncryptionManager.encryptData(
                                                jsonEncode(bank.toJson()),
                                              ),
                                            ),
                                            'index': index.toString(),
                                          },
                                        );
                                      },
                                    ),
                                    horizontalSpacing(),
                                    CustomIconButton.delete(
                                      isDisabled:
                                          !_routeAuthorizationModel.isAction,
                                      onPressed: () {
                                        _showDeleteCompanyBankDetailsDialog(
                                          context,
                                          bank,
                                          index,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            activeInactiveStatusWidget(
                              bank.status,
                              textStyle: AppTextStyle.ts12M(),
                            ),
                            Divider(height: 30, color: AppColor.grey2),
                            buildRowWrapper(
                              child: buildColumnTitleValue(
                                title: "Bank Name",
                                value: bank.bankName,
                              ),
                            ),
                            verticalSpacing(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10.w,
                              children: [
                                buildColumnTitleValue(
                                  title: "Nature Of Account",
                                  value: bank.natureOfAccount,
                                  customValueWidget: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.lightBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      bank.natureOfAccount,
                                      style: AppTextStyle.ts14M(
                                        color: AppColor.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Divider(height: 30, color: AppColor.grey2),

                            Row(
                              spacing: 10.w,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Account Type",
                                  value: bank.acType,
                                ),
                                buildColumnTitleValue(
                                  title: "Branch",
                                  value: bank.branch,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10.w,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "Account Number",
                                  value: bank.accountNumber,
                                ),
                                buildColumnTitleValue(
                                  title: "IFSC Code",
                                  value: bank.ifscCode,
                                ),
                              ],
                            ),
                            verticalSpacing(),
                            Row(
                              spacing: 10.w,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildColumnTitleValue(
                                  title: "MICR Code ",
                                  value: bank.mICRCode.toString(),
                                ),
                                buildColumnTitleValue(
                                  title: "Cancel Cheque",
                                  value: bank.cancelChequeURL,
                                  customValueWidget:
                                      CustomButton.documentOutline(
                                        isDisable: bank.cancelChequeURL.isEmpty,
                                        onPressed: () {
                                          showFilePreviewDialog(
                                            title: "Cancel Cheque",
                                            context,
                                            bank.cancelChequeURL.split(","),
                                          );
                                        },
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
