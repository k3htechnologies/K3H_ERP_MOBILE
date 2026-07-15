// PROJECT DETAILS TABS  ------------------------------------
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

// MATERIAL REQUISITION TABS ------------------------------------

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

// CRM : PAYTRACK TABS -----------------------------------

enum PayTrackTab {
  bookingPayTrack,
  bankLoan,
  paymentLedger,
  modificationRequest,
  paymentSchedule,
  flatHandover,
  files,
  payTrackCallLog,
  snagChecklist,
  flatHandoverChecklist,
}

extension PayTrackTabExtension on PayTrackTab {
  String get title {
    switch (this) {
      case PayTrackTab.bookingPayTrack:
        return "Overview";
      case PayTrackTab.bankLoan:
        return "Bank Loan";
      case PayTrackTab.paymentLedger:
        return "Payment Ledger";
      case PayTrackTab.modificationRequest:
        return "Modification Request";
      case PayTrackTab.paymentSchedule:
        return "Payment Schedule";
      case PayTrackTab.flatHandover:
        return "Flat Handover";
      case PayTrackTab.files:
        return "Files";
      case PayTrackTab.payTrackCallLog:
        return "Pay Track Call Log";
      case PayTrackTab.snagChecklist:
        return "Snag Checklist";
      case PayTrackTab.flatHandoverChecklist:
        return "Flat Handover Checklist";
    }
  }
}

// CRM : BROKERAGE TABS -----------------------------------

enum BrokerageTab { invoice, payment }

extension BrokerageTabExtension on BrokerageTab {
  String get title {
    switch (this) {
      case BrokerageTab.invoice:
        return "Invoice";
      case BrokerageTab.payment:
        return "Payment";
    }
  }
}
