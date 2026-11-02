import 'package:k3h_erp_app/features/visitor_management/visitor_management_dashboard/data/model/visitor_management_dashboard.model.dart';

class TimelineGroup {
  final DateTime time;
  final List<Table2> visitors;
  TimelineGroup(this.time, this.visitors);
}
