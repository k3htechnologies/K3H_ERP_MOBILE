enum ProjectDetailsTab { overview, employee, bankDetails, company, approval }

extension ProjectDetailsTabExtension on ProjectDetailsTab {
  String get title {
    switch (this) {
      case ProjectDetailsTab.overview:
        return "Overview";

      case ProjectDetailsTab.employee:
        return "Employee";

      case ProjectDetailsTab.bankDetails:
        return "Bank Details";

      case ProjectDetailsTab.company:
        return "Company";

      case ProjectDetailsTab.approval:
        return "Approval";
    }
  }
}
