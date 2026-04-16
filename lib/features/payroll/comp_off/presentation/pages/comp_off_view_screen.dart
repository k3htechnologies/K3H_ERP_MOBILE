import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/data/model/comp_off.model.dart';
import 'package:k3h_erp_app/features/payroll/comp_off/presentation/cubit/comp_off_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CompOffViewScreen extends StatefulWidget {
  final CompOffModel compOffModel;
  const CompOffViewScreen({super.key, required this.compOffModel});

  @override
  State<CompOffViewScreen> createState() => _CompOffViewScreenState();
}

class _CompOffViewScreenState extends State<CompOffViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late CompOffCubit _compOffCubit;

  @override
  void initState() {
    super.initState();
    _compOffCubit = context.read<CompOffCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _compOffCubit.onTabChanged(_tabController.index, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Comp Off",
        authorization: AuthorizationModel(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                formatDateTimeAsDDMMMYYYY(widget.compOffModel.compOffDate),
                style: AppTextStyle.ts16SB(color: AppColor.primary),
              ),
            ),
            verticalSpacing(height: 15),
            _buildOverView(),
          ],
        ),
      ),
    );
  }

  // OVERVIEW
  Widget _buildOverView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: commonCardDecoration(),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text("Details", style: AppTextStyle.ts16SB()),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Comp-Off Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.compOffModel.compOffDate,
                      ),
                    ),
                    buildColumnTitleValue(
                      title: "Worked Date Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.compOffModel.workingDate,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Approval Status",
                      value: widget.compOffModel.status,
                      customValueWidget:
                          widget.compOffModel.status.isNotEmpty
                              ? approvalStatusWidget(widget.compOffModel.status)
                              : null,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildColumnTitleValue(
                      title: "Reason",
                      value: widget.compOffModel.reason,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actionCardWidget(
            createdBy: widget.compOffModel.createdBy,
            createdDate: widget.compOffModel.createdDate,
            modifiedBy: widget.compOffModel.modifiedBy,
            modifiedDate: widget.compOffModel.modifiedDate,
          ),
        ],
      ),
    );
  }
}
