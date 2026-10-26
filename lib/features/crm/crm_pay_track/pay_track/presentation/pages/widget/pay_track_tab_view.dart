import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_cubit.dart';
import 'package:k3h_erp_app/features/crm/crm_pay_track/pay_track/presentation/cubit/pay_track_state.dart';
import 'package:k3h_erp_app/utils/common_enums.dart';
import 'package:k3h_erp_app/widgets/chip_style_tab_bar.dart';

class PayTrackTabsView extends StatefulWidget {
  final List<PayTrackTab> tabs;
  final void Function(PayTrackTab tab) onTabSelected;
  final Widget Function(PayTrackTab tab, PayTrackState state) contentBuilder;

  const PayTrackTabsView({
    super.key,
    required this.tabs,
    required this.onTabSelected,
    required this.contentBuilder,
  });

  @override
  State<PayTrackTabsView> createState() => _PayTrackTabsViewState();
}

class _PayTrackTabsViewState extends State<PayTrackTabsView>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.tabs.length, vsync: this)
      ..addListener(_onChange);
  }

  void _onChange() {
    if (_controller.indexIsChanging) return;
    widget.onTabSelected(widget.tabs[_controller.index]);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChipStyleTabBar(
          controller: _controller,
          style: ChipTabBarStyle.underline,
          tabs: widget.tabs.map((t) => t.title).toList(),
        ),
        Expanded(
          child: BlocBuilder<PayTrackCubit, PayTrackState>(
            builder:
                (context, state) => TabBarView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children:
                      widget.tabs
                          .map((t) => widget.contentBuilder(t, state))
                          .toList(),
                ),
          ),
        ),
      ],
    );
  }
}
