import 'package:k3h_erp_app/utils/common_function.dart';

class TicketEmployeeModel {
  int employeeId;
  String employeeName;
  int activeTickets;

  TicketEmployeeModel({
    required this.employeeId,
    required this.employeeName,
    required this.activeTickets,
  });

  factory TicketEmployeeModel.fromJson(Map<String, dynamic> json) =>
      TicketEmployeeModel(
        employeeId: parseValue<int>(json, "EmployeeId"),
        employeeName: parseValue<String>(json, "EmployeeName"),
        activeTickets: parseValue<int>(json, "ActiveTickets"),
      );

  Map<String, dynamic> toJson() => {
    "EmployeeId": employeeId,
    "EmployeeName": employeeName,
    "ActiveTickets": activeTickets,
  };
}
