import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/data/model/outdoor.model.dart';
import 'package:k3h_erp_app/features/payroll/outdoor/presentation/cubit/outdoor_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class OutdoorViewScreen extends StatefulWidget {
  final OutdoorModel outdoorModel;
  const OutdoorViewScreen({super.key, required this.outdoorModel});

  @override
  State<OutdoorViewScreen> createState() => _OutdoorViewScreenState();
}

class _OutdoorViewScreenState extends State<OutdoorViewScreen>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  late TabController _tabController;

  // CUBIT
  late OutdoorCubit _outdoorCubit;

  @override
  void initState() {
    super.initState();
    _outdoorCubit = context.read<OutdoorCubit>();
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
      _outdoorCubit.onTabChanged(_tabController.index, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Outdoor",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatDateTimeAsDDMMMYYYY(widget.outdoorModel.outDoorDate),
                    style: AppTextStyle.ts16M(),
                  ),
                  horizontalSpacing(),
                  Text(
                    DateFormat(
                      'hh:mm a',
                    ).format(widget.outdoorModel.outDoorTime),
                    style: AppTextStyle.ts16M(),
                  ),
                ],
              ),
            ),
            verticalSpacing(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColor.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColor.primary,
                    unselectedLabelColor: AppColor.grey,
                    indicator: BoxDecoration(
                      color: AppColor.lightBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyle.ts14M(),
                    unselectedLabelStyle: AppTextStyle.ts14M(),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.zero,
                    tabs: const [Tab(text: 'Overview'), Tab(text: 'Document')],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [_buildOverView(), _buildDocument()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OVERVIEW
  Widget _buildOverView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Details", style: AppTextStyle.ts16SB()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Company Name",
                      value: widget.outdoorModel.companyName,
                    ),
                    buildColumnTitleValue(
                      title: "Department",
                      value: widget.outdoorModel.departmentName,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Company Address",
                      value: widget.outdoorModel.companyAddress,
                    ),
                    buildColumnTitleValue(
                      title: "Accompanied By",
                      value: widget.outdoorModel.accompaniedByName,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Purpose",
                      value: widget.outdoorModel.purpose,
                    ),
                    buildColumnTitleValue(
                      title: "Requested By",
                      value: widget.outdoorModel.createdBy,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
            visible: widget.outdoorModel.punchIn != null,
            child: Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Attendance", style: AppTextStyle.ts16SB()),
                  verticalSpacing(),
                  if (widget.outdoorModel.punchIn != null)
                    _buildPunchInPunchOutCard(
                      isPunchIn: true,
                      time: widget.outdoorModel.punchIn!,
                      location: widget.outdoorModel.punchInAddress,
                    ),
                  if (widget.outdoorModel.punchOut != null)
                    _buildPunchInPunchOutCard(
                      isPunchIn: false,
                      time: widget.outdoorModel.punchOut!,
                      location: widget.outdoorModel.punchOutAddress,
                    ),
                ],
              ),
            ),
          ),
          Container(
            decoration: commonCardDecoration(),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 10),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Action Details", style: AppTextStyle.ts16SB()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Created By",
                      value: widget.outdoorModel.createdBy,
                    ),
                    buildColumnTitleValue(
                      title: "Created Date",
                      value: formatDateTimeAsDDMMMYYYY(
                        widget.outdoorModel.createdDate,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildColumnTitleValue(
                      title: "Modified By",
                      value:
                          widget.outdoorModel.modifiedBy.isEmpty
                              ? "-"
                              : widget.outdoorModel.modifiedBy,
                    ),
                    buildColumnTitleValue(
                      title: "Modified Date",
                      value:
                          widget.outdoorModel.modifiedDate != null
                              ? formatDateTimeAsDDMMMYYYY(
                                widget.outdoorModel.modifiedDate!,
                              )
                              : "-",
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

  // DOCUMENT
  Widget _buildDocument() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.outdoorModel.visitingCardUrl.isNotEmpty) {
              showFilePreviewDialog(
                context,
                widget.outdoorModel.visitingCardUrl.split(","),
              );
            }
          },
          child: Container(
            decoration: commonCardDecoration(),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text("Visiting Card", style: AppTextStyle.ts16M()),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color:
                        widget.outdoorModel.visitingCardUrl.isEmpty
                            ? AppColor.grey30
                            : AppColor.lightBlue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.remove_red_eye,
                    size: 18,
                    color:
                        widget.outdoorModel.visitingCardUrl.isEmpty
                            ? AppColor.grey
                            : AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // HELPER CARD
  Widget _buildPunchInPunchOutCard({
    required bool isPunchIn,
    required DateTime time,
    required String location,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isPunchIn ? AppColor.lightGreen : AppColor.lightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPunchIn ? AppColor.darkGreen : AppColor.primary,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: isPunchIn ? AppColor.darkGreen : AppColor.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              horizontalSpacing(),
              Text(
                isPunchIn ? "Punch In" : "Punch Out",
                style: AppTextStyle.ts14M(),
              ),
              Spacer(),
              Text(
                DateFormat('hh:mm a').format(time),
                style: AppTextStyle.ts14M(),
              ),
            ],
          ),
          verticalSpacing(),
          Text(location, style: AppTextStyle.ts14R()),
        ],
      ),
    );
  }
}
