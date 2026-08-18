import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/masters/company_master/presentation/cubit/company_master/company_master_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/static/static_dropdown_data.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_multi_select_pop_up.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TaxTrackerScreen extends StatefulWidget {
  const TaxTrackerScreen({super.key});

  @override
  State<TaxTrackerScreen> createState() => _TaxTrackerScreenState();
}

class _TaxTrackerScreenState extends State<TaxTrackerScreen> {
  late CompanyMasterCubit _companyMasterCubit;
  List<Map<String, dynamic>> _selectedCompany = [];
  @override
  void initState() {
    super.initState();
    _companyMasterCubit = context.read<CompanyMasterCubit>();
  }

  // FETCH COMPANIES
  Future<Map<String, dynamic>> _fetchCompanies(
    int pageNumber, {
    String? value,
  }) async {
    //  SEARCH MODE
    if (value != null) {
      await _companyMasterCubit.getCompanyMaster(context, pageNumber);

      final companyList = _companyMasterCubit.state.companyList;

      final totalCount = _companyMasterCubit.state.totalNumberOfRecord;

      final Map<int, Map<String, dynamic>> uniqueFiltered = {};

      for (final comp in companyList) {
        uniqueFiltered[comp.companyId] = {
          "zAttributesId": comp.companyId,
          "DisplayName": comp.companyName,
        };
      }

      return {
        "itemList": uniqueFiltered.values.toList(),
        "totalNumberOfRecord":
            totalCount > 0 ? totalCount : uniqueFiltered.length,
      };
    }

    //  NORMAL PAGINATION MODE
    final totalCount = _companyMasterCubit.state.totalNumberOfRecord;

    final currentLoadedCount = _companyMasterCubit.state.companyList.length;

    if (currentLoadedCount < totalCount) {
      await _companyMasterCubit.getCompanyMaster(context, pageNumber);
    }

    final updatedList = _companyMasterCubit.state.companyList;

    final Map<int, Map<String, dynamic>> uniqueDepartments = {};

    for (final company in updatedList) {
      uniqueDepartments[company.companyId] = {
        "zAttributesId": company.companyId,
        "DisplayName": company.companyName,
      };
    }

    return {
      "itemList": uniqueDepartments.values.toList(),
      "totalNumberOfRecord":
          totalCount > 0 ? totalCount : uniqueDepartments.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        isMenuButton: true,
        screenTitle: "Income Tax",
        authorization: AuthorizationModel(isAction: true),
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addTaxTracker);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomMultipleSelectPopup(
              hintText: "Select Company",
              isMultiSelect: false,
              dataList: [],
              onSelected: (value) {
                _selectedCompany = value;
              },
              dataFetchCallBack: _fetchCompanies,
            ),
            CustomMultipleSelectPopup(
              hintText: "Select Financial Year",
              isMultiSelect: false,
              dataList: financialYearList,
              onSelected: (value) {
                _selectedCompany = value;
              },
              dataFetchCallBack: _fetchCompanies,
            ),
            taxNoticeCard(),
          ],
        ),
      ),
    );
  }

  Widget taxNoticeCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.black.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5FC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              "Income Tax Notice",
              style: AppTextStyle.ts16B(color: Color(0xff0B1C30)),
            ),
          ),

          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xffF7F8FA),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Notice Type",
                      value: "ITR ACK / Revised Return",
                      customValueWidget: GestureDetector(
                        onTap: () {
                          goRouter.pushNamed(AppRoutes.viewTaxTracker);
                        },
                        child: Text(
                          "ITR ACK / Revised Return",
                          style: AppTextStyle.ts14M(color: AppColor.primary),
                        ),
                      ),
                    ),
                    horizontalSpacing(),
                    buildColumnTitleValue(
                      title: "Authority",
                      value: "Assessing Officer (AO)",
                      valueTextStyle: AppTextStyle.ts14M(),
                    ),
                  ],
                ),
                verticalSpacing(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildColumnTitleValue(
                      title: "Notice U/S",
                      value: "143 (1)",
                      valueTextStyle: AppTextStyle.ts14M(),
                    ),
                    horizontalSpacing(),
                    buildColumnTitleValue(
                      title: "Notice Status",
                      value: "Reply Pending",
                      customValueWidget: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xffFFEDD5),
                          borderRadius: BorderRadius.circular(9999.0),
                        ),
                        child: Text(
                          "Reply Pending",
                          style: AppTextStyle.ts10M(color: Color(0xffC2410C)),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildColumnTitleValue(
                      title: "Notice Date",
                      value: "09 June 2026",
                      valueTextStyle: AppTextStyle.ts14M(),
                    ),
                    horizontalSpacing(),
                    buildColumnTitleValue(
                      title: "Due Date",
                      value: "28 June 2026",
                      valueTextStyle: AppTextStyle.ts14M(),
                    ),
                  ],
                ),
                verticalSpacing(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildCountBox(count: "1", title: "Notice"),
                    ),
                    horizontalSpacing(width: 6),
                    Expanded(child: _buildCountBox(count: "2", title: "Reply")),
                    horizontalSpacing(width: 6),
                    Expanded(
                      child: _buildCountBox(count: "3", title: "Document"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBox({required String count, required String title}) {
    return Container(
      // width: 98.67,
      // height: 47,
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: const Color(0xFF243965),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: AppTextStyle.ts12M(color: AppColor.white)),
          verticalSpacing(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyle.ts12M(color: AppColor.white),
          ),
        ],
      ),
    );
  }
}
