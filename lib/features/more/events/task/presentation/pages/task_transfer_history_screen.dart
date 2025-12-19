import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar.dart';

class TaskTransferHistoryScreen extends StatefulWidget {
  const TaskTransferHistoryScreen({super.key});

  @override
  State<TaskTransferHistoryScreen> createState() =>
      _TaskTransferHistoryScreenState();
}

class _TaskTransferHistoryScreenState extends State<TaskTransferHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        screenTitle: "Calendar",
        authorization: AuthorizationModel(),
      ),
      body: SafeArea(child: Expanded(child: Column(children: [Text("data")]))),
    );
  }
}
