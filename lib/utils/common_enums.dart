// Project Details Tabs ------------------------------------
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

// Material Requisition Tabs ------------------------------------

enum MaterialRequisitionTab {
  overview,
  details,
  finalizeVendor,
  purchaseOrder,
  grn,
  invoice,
}

extension MaterialRequisitionTabExtension on MaterialRequisitionTab {
  String get title {
    switch (this) {
      case MaterialRequisitionTab.overview:
        return "Overview";

      case MaterialRequisitionTab.details:
        return "Details";

      case MaterialRequisitionTab.finalizeVendor:
        return "Finalize Vendor";

      case MaterialRequisitionTab.purchaseOrder:
        return "Purchase Order";

      case MaterialRequisitionTab.grn:
        return "GRN";

      case MaterialRequisitionTab.invoice:
        return "Invoice";
    }
  }
}
