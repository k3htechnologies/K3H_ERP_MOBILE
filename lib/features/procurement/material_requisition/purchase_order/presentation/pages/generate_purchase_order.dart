import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/di/app_dependencies.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/model/terms_and_conditions.model.dart';
import 'package:k3h_erp_app/features/masters/terms_and_conditions_master/data/repository/terms_and_conditions.repository.dart';
import 'package:k3h_erp_app/features/procurement/material_requisition/purchase_order/presentation/cubit/purchase_order_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class GeneratePurchaseOrderScreen extends StatefulWidget {
  final int projectId;
  final int materialRequisitionId;
  final String uniquekey;
  const GeneratePurchaseOrderScreen({
    super.key,
    required this.projectId,
    required this.materialRequisitionId,
    required this.uniquekey,
  });

  @override
  State<GeneratePurchaseOrderScreen> createState() =>
      _GeneratePurchaseOrderScreenState();
}

class _GeneratePurchaseOrderScreenState
    extends State<GeneratePurchaseOrderScreen> {
  final TermsAndConditionsMasterRepository _termsAndConditionsRepository =
      serviceLocator<TermsAndConditionsMasterRepository>();

  late PurchaseOrderCubit _purchaseOrderCubit;
  late TextEditingController _remarksC;
  final ValueNotifier<List<Map<String, dynamic>>?> _selectedTermAndCondition =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _purchaseOrderCubit = context.read<PurchaseOrderCubit>();
    _remarksC = TextEditingController();
  }

  Future<Map<String, dynamic>> _fetchTermsAndConditions(
    int pageNumber, {
    String? value,
  }) async {
    final Map<String, dynamic>? queryParams =
        (value != null && value.isNotEmpty) ? {"Title": value} : null;

    var result = await _termsAndConditionsRepository.getTermsAndConditionsList(
      pageNumber: pageNumber,
      pageSize: 10,
      moduleName: "",
      queryParams: queryParams,
    );

    return result.fold(
      (failure) => {
        "itemList": <Map<String, dynamic>>[],
        "totalNumberOfRecord": 0,
      },
      (response) {
        final project = response['data'] as List<TermsAndConditionsModel>;

        return {
          "itemList":
              project.map((term) {
                return {
                  "zAttributesId": term.termsAndConditionsMasterId,
                  "DisplayName": term.title,
                  "Description": term.description,
                };
              }).toList(),
          "totalNumberOfRecord": response['totalNumberOfRecord'] ?? 0,
        };
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Purchase Order",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Purchase Order Details", style: AppTextStyle.ts14M()),
            Container(
              decoration: commonCardDecoration(),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                spacing: 10,
                children: [
                  CustomTextField(
                    title: "Remarks",
                    textController: _remarksC,
                    hint: "Enter Remarks",
                  ),
                  ValueListenableBuilder(
                    valueListenable: _selectedTermAndCondition,
                    builder: (context, value, child) {
                      return CustomMultipleSelectPopup(
                        title: 'Terms and Conditions',
                        isMultiSelect: false,
                        hintText: "Select Terms and Conditions",
                        initialValue: value,
                        dataList: const [],
                        onClear: () {
                          _selectedTermAndCondition.value = null;
                        },
                        onSelected: (value) {
                          _selectedTermAndCondition.value = value;
                        },
                        dataFetchCallBack: _fetchTermsAndConditions,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _selectedTermAndCondition,
                builder: (context, value, child) {
                  if (_selectedTermAndCondition.value != null) {
                    final isHtml =
                        _selectedTermAndCondition.value!.first['Description']
                                ?.contains('<') ==
                            true &&
                        _selectedTermAndCondition.value!.first['Description']
                            ?.contains('>');

                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: commonCardDecoration(),
                        child:
                            isHtml
                                ? Html(
                                  data:
                                      _selectedTermAndCondition
                                          .value!
                                          .first['Description'] ??
                                      "",
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(14),
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                  },
                                )
                                : Text(
                                  _selectedTermAndCondition
                                          .value!
                                          .first['Description'] ??
                                      "",
                                  style: AppTextStyle.ts14R(
                                    color: AppColor.grey,
                                  ),
                                ),
                      ),
                    );
                  }
                  return Spacer();
                },
              ),
            ),
            CustomButton(
              text: "Generate PO",
              onPressed: () {
                _purchaseOrderCubit.generatePurchaseOrder(
                  context: context,
                  projectId: widget.projectId,
                  materialRequisitionDetailId: widget.materialRequisitionId,
                  uniqueKey: widget.uniquekey,
                  remarks: _remarksC.text,
                  termsCondition:
                      _selectedTermAndCondition.value != null
                          ? _selectedTermAndCondition
                              .value!
                              .first['Description']
                          : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
