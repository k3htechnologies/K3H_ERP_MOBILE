import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/more/ticket/data/model/ticket.model.dart';
import 'package:k3h_erp_app/features/more/ticket/presentation/cubit/ticket_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/custom_common_widget.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class TicketViewScreen extends StatefulWidget {
  final TicketModel? ticket;
  final int ticketId;
  final String systemGeneratedCode;
  const TicketViewScreen({
    super.key,
    required this.systemGeneratedCode,
    required this.ticketId,
    required this.ticket,
  });

  @override
  State<TicketViewScreen> createState() => _TicketViewScreenState();
}

class _TicketViewScreenState extends State<TicketViewScreen>
    with TickerProviderStateMixin {
  late TicketCubit _ticketCubit;
  late ProjectModel _selectedProject;
  late TabController _tabController;
  late final ValueNotifier<bool> _isLoadingNotifier;
  @override
  void initState() {
    super.initState();
    _isLoadingNotifier = ValueNotifier(false);
    _ticketCubit = context.read<TicketCubit>();
    _selectedProject = getProject();
    _ticketCubit.getTicketDetails(
      context,
      _selectedProject.projectId,
      widget.ticketId,
    );
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  // TAB CHANGE METHOD
  void _onTabChanged() {
    if (_tabController.index == 1) {
      _pullChannelPartnerMaster();
    }
  }

  // PULL CHANNEL PARTNER MASTER
  Future<void> _pullChannelPartnerMaster() async {
    _isLoadingNotifier.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: "Ticket Master",
        authorization: AuthorizationModel(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(widget.systemGeneratedCode),
          ),
          ChipStyleTabBar(
            controller: _tabController,
            tabs: ["Details", "Tracking"],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ticketDetailsWidget(context),
                _ticketTrackingWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketDetailsWidget(BuildContext context) {
    final collaborators =
        widget.ticket!.collaboratorsName
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final urls =
        widget.ticket!.attachmentUrl
            .split(",")
            .where((e) => e.trim().isNotEmpty)
            .toList();
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              bottom: 8.0,
              right: 16.0,
            ),
            margin: EdgeInsets.only(bottom: 16.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ticketing Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 8.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Module",
                        value: widget.ticket!.module,
                      ),
                    ),
                    horizontalSpacing(width: 16.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Platform",
                        value: widget.ticket!.platform,
                      ),
                    ),
                  ],
                ),
                verticalSpacing(height: 16.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Attachment",
                        value: widget.ticket!.attachmentUrl,
                        customValueWidget: CustomButton.documentOutline(
                          onPressed: () {
                            if (widget.ticket!.attachmentUrl.isNotEmpty) {
                              showFilePreviewDialog(context, urls);
                            }
                          },
                          isDisable: widget.ticket!.attachmentUrl.isEmpty,
                        ),
                      ),
                    ),
                    horizontalSpacing(width: 16.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Description",
                        value: widget.ticket!.ticketDescription,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              bottom: 8.0,
              right: 16.0,
            ),
            margin: EdgeInsets.only(bottom: 16.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Request Information ", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 8.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Raised By",
                        value: widget.ticket!.createdBy,
                      ),
                    ),
                    horizontalSpacing(width: 16.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Department",
                        value: widget.ticket!.departmentName,
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Date",
                        value: formatDateTimeAsDDMMMYYYY(
                          widget.ticket!.createdDate!,
                        ),
                      ),
                    ),
                    horizontalSpacing(width: 16.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Priority",
                        value: widget.ticket!.priority,
                        valueTextStyle: AppTextStyle.ts14M(
                          color: _priorityColor(widget.ticket!.priority),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                buildColumnTitleValueNormal(
                  title: "Remark",
                  value: widget.ticket!.ticketRemark,
                ),
              ],
            ),
          ),
          widget.ticket!.ticketStatus.toLowerCase() != 'open'
              ? Container(
                padding: EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  bottom: 8.0,
                  right: 16.0,
                ),
                margin: EdgeInsets.only(bottom: 16.0),
                decoration: commonCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Assignee Details", style: AppTextStyle.ts16SB()),
                    verticalSpacing(height: 8.5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Primary Assignee",
                            value: widget.ticket!.employeeName,
                          ),
                        ),
                        horizontalSpacing(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Collaborators",
                                style: AppTextStyle.ts14R(color: AppColor.grey),
                              ),
                              const SizedBox(height: 4),
                              ...collaborators.map(
                                (name) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    name.isEmpty ? "-" : name,
                                    style: AppTextStyle.ts14M(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildColumnTitleValueNormal(
                          title: "Assigned By",
                          value: widget.ticket!.assignedBy,
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Assigned Date",
                            value:
                                widget.ticket!.assignedDate == null
                                    ? "-"
                                    : formatDateTimeAsDDMMMYYYY(
                                      widget.ticket!.assignedDate!,
                                    ),
                          ),
                        ),
                        horizontalSpacing(width: 16.0),
                        Expanded(
                          child: buildColumnTitleValueNormal(
                            title: "Estimated Completion Date",
                            value:
                                widget.ticket!.resolvedTillDate == null
                                    ? "-"
                                    : formatDateTimeAsDDMMMYYYY(
                                      widget.ticket!.resolvedTillDate!,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    verticalSpacing(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildColumnTitleValueNormal(
                          title: "Remark",
                          value: widget.ticket!.assignedRemark,
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : SizedBox.shrink(),
          Container(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              bottom: 8.0,
              right: 16.0,
            ),
            margin: EdgeInsets.only(bottom: 16.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Action Details", style: AppTextStyle.ts16SB()),
                verticalSpacing(height: 8.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Created By",
                        value: widget.ticket!.createdBy,
                      ),
                    ),
                    horizontalSpacing(width: 16.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Created Date",
                        value:
                            widget.ticket!.createdDate == null
                                ? "-"
                                : formatDateTimeAsDDMMMYYYY(
                                  widget.ticket!.createdDate!,
                                ),
                      ),
                    ),
                  ],
                ),
                verticalSpacing(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Modified By",
                        value: widget.ticket!.modifiedBy,
                      ),
                    ),
                    horizontalSpacing(width: 16.0),
                    Expanded(
                      child: buildColumnTitleValueNormal(
                        title: "Modified Date",
                        value:
                            widget.ticket!.modifiedDate == null
                                ? "_"
                                : formatDateTimeAsDDMMMYYYY(
                                  widget.ticket!.modifiedDate!,
                                ),
                      ),
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

  Widget _ticketTrackingWidget(BuildContext context) {
    final trackingItems = [
      {
        "date": widget.ticket?.assignedDate ?? widget.ticket?.createdDate,
        "remark": getDisplayValue(widget.ticket?.ticketRemark),
        "status": getDisplayValue(widget.ticket?.ticketStatus),
      },

      ...widget.ticket!.assignTicketHistory.map(
        (e) => {
          "date": e.createdDate,
          "remark": getDisplayValue(e.assignedRemark),
          "status": getDisplayValue(e.assignedStatus),
        },
      ),
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              bottom: 8.0,
              right: 16.0,
            ),
            margin: EdgeInsets.only(bottom: 16.0),
            decoration: commonCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trackingItems.length,
                  itemBuilder: (context, index) {
                    final item = trackingItems[index];

                    return _trackingItem(
                      date: getDisplayDate(item["date"]),
                      remark: getDisplayValue(item["remark"]),
                      status: getDisplayValue(item["status"]),
                      isLast: index == trackingItems.length - 1,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackingItem({
    required String date,
    required String remark,
    required String status,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                  ),
                ),

                if (!isLast)
                  Expanded(child: Container(width: 3, color: AppColor.primary)),
              ],
            ),
          ),

          horizontalSpacing(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 37),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(date, style: AppTextStyle.ts12M()),
                            verticalSpacing(height: 12.0),
                            Text(
                              remark,
                              style: AppTextStyle.ts12M(
                                color: AppColor.greyTitleAndValueColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      horizontalSpacing(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: AppTextStyle.ts14M(
                            color: _statusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "low":
        return AppColor.green20;
      case "medium":
        return AppColor.yellow;
      case "high":
        return AppColor.missingInformationRed;
      default:
        return Colors.black.withValues(alpha: 0.5);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "open":
        return AppColor.green20;
      case "assigned":
        return AppColor.primary;
      case "closed":
        return AppColor.missingInformationRed;
      case "inprogress":
        return Color(0xffFF9F2D);
      case "resolved":
        return AppColor.yellow;
      case "reopen":
        return AppColor.mediumBlue;
      default:
        return Colors.black.withValues(alpha: 0.5);
    }
  }

  String getDisplayValue(dynamic value) {
    if (value == null) return "-";

    final text = value.toString().trim();

    return text.isEmpty ? "-" : text;
  }

  String getDisplayDate(dynamic value) {
    if (value == null) return "-";

    if (value is DateTime) {
      return formatDateTimeAsDDMMMYYYY(value);
    }

    return "-";
  }
}
