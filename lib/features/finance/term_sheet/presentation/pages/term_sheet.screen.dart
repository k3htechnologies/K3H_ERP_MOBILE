import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/finance/term_sheet/presentation/cubit/term_sheet_cubit.dart';
import 'package:k3h_erp_app/routes/app_routes.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TermSheetScreen extends StatefulWidget {
  const TermSheetScreen({super.key});

  @override
  State<TermSheetScreen> createState() => _TermSheetScreenState();
}

class _TermSheetScreenState extends State<TermSheetScreen> {
  late TermSheetCubit _termSheetCubit;
  late AuthorizationModel _routeAuthorizationModel;
  late TextEditingController _searchC;

  @override
  void initState() {
    _termSheetCubit = context.read<TermSheetCubit>();
    _routeAuthorizationModel =
        Authorization.routeAuthorizationMap[AppRoutes.termSheet]!;
    initialiseControllers();
    _termSheetCubit.getTermSheet(context, 1);
    super.initState();
  }

  void initialiseControllers() {
    _searchC = TextEditingController();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Term Sheet",
        authorization: _routeAuthorizationModel,
        searchHintText: "Search By Project Name",
        onSearchSubmit: (value) {},
        textController: _searchC,
        isFilterOn: true,
        onExportCallback: (value) {},
        onAddCallback: () {
          goRouter.pushNamed(AppRoutes.addTermSheet);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _termSheetCubit.getTermSheet(context, 1);
        },
        child: BlocBuilder<TermSheetCubit, TermSheetState>(
          builder: (context, state) {
            if (state.isLoading ?? false) {
              return Center(child: loader());
            }
            if (state.termSheetList.isEmpty) {
              return Center(
                child: noDataWidget(
                  message: "No Term Sheet Data found",
                  iconSize: 160.0,
                ),
              );
            }
            return ListView.builder(
              itemCount: state.termSheetList.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              itemBuilder: (context, index) {
                return termSheetCard(context, state, index);
              },
            );
          },
        ),
      ),
    );
  }

  Widget termSheetCard(BuildContext context, TermSheetState state, int index) {
    final termSheet = state.termSheetList[index];
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(16),
      decoration: commonCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.0,
        children: [
          GestureDetector(
            onTap: () {
              goRouter.pushNamed(AppRoutes.viewTermSheet);
            },
            child: Text(
              termSheet.nameOfInstitutionBankNbfc.isEmpty
                  ? "-"
                  : termSheet.nameOfInstitutionBankNbfc,
              style: AppTextStyle.ts14M(color: AppColor.primary).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColor.primary,
              ),
            ),
          ),
          buildRowTitleValue(
            title: "Project Name",
            value: termSheet.projectName,
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Laon Taken By",
            value: termSheet.loanTakenBy,
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Term Sheet Date",
            value: formatDateTimeAsDDMMMYYYY(termSheet.termSheetDate),
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Facility Amount (₹)",
            value: termSheet.facilityAmount.toIndianCurrency(),
            singleLine: false,
          ),
          buildRowTitleValue(
            title: "Rate Of Interest (%)",
            value: "${termSheet.rateOfInterestInPercentage} %",
            singleLine: false,
          ),
        ],
      ),
    );
  }
}
