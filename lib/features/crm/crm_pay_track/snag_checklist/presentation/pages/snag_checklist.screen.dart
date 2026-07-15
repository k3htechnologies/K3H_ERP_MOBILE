import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/cubit/snag_checklist_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/pages/civil_tab_checklist.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/pages/electrical_tab_checklist.screen.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/snag_checklist/presentation/pages/plumbing_tab_checklist.screen.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class SnagCheckListScreen extends StatefulWidget {
  final int projectId;
  final int bookingId;

  const SnagCheckListScreen({
    super.key,
    required this.projectId,
    required this.bookingId,
  });

  @override
  State<SnagCheckListScreen> createState() => _SnagCheckListScreenState();
}

class _SnagCheckListScreenState extends State<SnagCheckListScreen>
    with SingleTickerProviderStateMixin {
  late SnagChecklistCubit _snagChecklistCubit;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _snagChecklistCubit = context.read<SnagChecklistCubit>();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _snagChecklistCubit.getSnagCheckList(
      context,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      categoryName: 'Civil',
    );
  }

  void _handleTabChange() async {
    if (_tabController.indexIsChanging) return;

    String categoryName = "Civil";

    switch (_tabController.index) {
      case 0:
        categoryName = "Civil";
        break;

      case 1:
        categoryName = "Electrical";
        break;

      case 2:
        categoryName = "Plumbing";
        break;
    }

    await _snagChecklistCubit.getSnagCheckList(
      context,
      projectId: widget.projectId,
      bookingId: widget.bookingId,
      categoryName: categoryName,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(),
        ChipStyleTabBar(
          controller: _tabController,
          tabs: ['Civil', 'Electrical', 'Plumbing'],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              CivilTabChecklistScreen(
                projectId: widget.projectId,
                bookingId: widget.bookingId,
                categoryName: "Civil",
              ),
              ElectricalTabChecklistScreen(
                projectId: widget.projectId,
                bookingId: widget.bookingId,
                categoryName: "Electrical",
              ),
              PlumbingTabChecklistScreen(
                projectId: widget.projectId,
                bookingId: widget.bookingId,
                categoryName: "Plumbing",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
