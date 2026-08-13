// STATIC DROPDOWN DATA

const accountTypeValues = [
  'Current',
  'Overdraft',
  'RERA Escrow Current Account',
  'Salary',
  'Saving',
];

const natureOfAccountValues = [
  '100% Collection Account',
  '100% RERA Account',
  '30% RERA Account',
  '70% RERA Account',
  'Collection Escrow Account',
  'Escrow',
  'Loan',
  'Master Escrow Account',
  'Non - Current Account',
  'Overdraft',
  'Regular Account',
  'RERA Escrow Account',
];

const currentAccommodationValues = ['Rented', 'Self-Owned'];

const occupationTypeValues = [
  'Business',
  'Homemaker',
  'Professional',
  'Salaried',
  'Retired',
];

const sourceTypeValues = ['Channel Partner', 'Direct Walkin'];

const residentialTypeValues = [
  '1 RK',
  '1 BHK',
  '2 BHK',
  '3 BHK',
  '4 BHK',
  '5 BHK',
  '6 BHK',
  '7 BHK',
  '8 BHK',
  '9 BHK',
  '10 BHK',
  '1 + 1 JODI',
  '2 + 1 JODI',
  '2 + 2 JODI',
  '2 + 3 JODI',
  'DUPLEX',
  'PENTHOUSE',
];

const floorBrandValues = ['Higher', 'Middle', 'Lower'];

const budgetInCrValues = [
  '<1',
  '1.5',
  '2',
  '2.5',
  '3',
  '3.5',
  '4',
  '4.5',
  '5',
  '5.5',
  '6',
  '6.5',
  '7',
  '7.5',
  '8',
  '8.5',
  '9',
  '9.5',
  '10',
  '10.5',
  '11',
  '11.5',
  '12',
  '12.5',
  '15',
  '15.5',
  '20',
  '20.5',
  '25+',
];

const possessionTypeValues = [
  'RTMI',
  'Under 1 Year',
  '1 Years To 2 Years',
  '2 Years To 3 Years',
  '3 Years & Above',
];

const requirementTypeValues = [
  'Commercial',
  'Commercial Leasing',
  'Residential',
];

const commercialUnitTypeValues = ['OFFICE', 'SHOP'];

const commercialLeasingTypeValues = ['OFFICE', 'SHOP'];

const timelineTypeValues = ['Within 1 Month', 'Beyond 1 Month'];

const fundingSourceValues = ['Loan', 'Self-funded', 'Sale Of Property'];

const ethnicityValues = [
  'Bengali',
  'Christian',
  'Gujarati',
  'Jain',
  'Muslim',
  'Marwari',
  'Maharashtrian',
  'North Indian',
  'Parsi',
  'Punjabi',
  'Sindhi',
  'South Indian',
  'Others',
];

const stageTypeValues = [
  'Follow - Up',
  'Site Visit',
  'Re - Visit Proposed',
  'Re - Visit Scheduled',
  'Re - Visit',
  'Repeat Re - Visit',
  'Negotiation',
  'Unit Selection / Blocked',
  'Booking Done',
  'Blocked',
  'Cancelled',
  'Retention',
  'Lost',
];

const finalStageDetailsValues = [
  'Purchased with competition',
  'Purchased somewhere else',
  'Not connected calls >7',
  'Low Budget',
  'Ready Possession',
  'Location',
  'Product Issue',
  'Pricing Issue',
  'Payment Issue',
  'Loan Issue',
  'Inventory Issue',
  'General Enquiry',
  'Wrong Number',
  'Dropped The Idea Of Buying',
  'Booked Somewhere Else',
];

const channelPartnerActivityValues = [
  'Channel Partner Data Calling',
  'Channel Partner Walked IN',
  'Digital Activity',
];

const directWalkingSubSourceValues = [
  'Advertisement',
  'Exhibition',
  'Employee Reference',
  'HRR Website',
  'Loyalty',
  'Management Reference',
  'Property Search Portal',
  'SMS',
  'Site Branding',
  'Reference',
  'Other',
];

const subSubSourceValues = [
  'Facebook',
  'Hoarding',
  'Instagram',
  'Google Ads',
  'Newspaper',
];

const lostReasonValues = [
  'Purchased with competition',
  'Purchased somewhere else',
  'Not connected calls >7',
  'Low Budget',
  'Ready Possession',
  'Location',
  'Product Issue',
  'Pricing Issue',
  'Payment Issue',
  'Loan Issue',
  'Inventory Issue',
  'General Enquiry',
  'Wrong Number',
  'Dropped The Idea Of Buying',
  'Booked Somewhere Else',
];

const designationValues = [
  'Business Head',
  'Cluster Head',
  'Owner',
  'Partner',
  'Team Member',
];

const specialityValues = [
  'Commercial Sale',
  'Commercial Leasing',
  'Residential Sale',
  'Commercial + Residential Sale',
];

const companyTypeValues = ['New Company', 'Existing Company'];

const firmTypeValues = ['LLP', 'Private Limited Company', 'Proprietorship'];

const channelPartnerTypeValues = [
  'International Channel Partner (IPC)',
  'Institutional Channel Partner (ICP)',
  'Retail Channel Partner (RCP)',
];

const flatTypeValues = [
  'BMC',
  'Commercial',
  'eDeck',
  'Fitness Center',
  'Gym',
  'MHADA',
  'Multi Purpose Room',
  'Land Lord',
  'Lien',
  'Part Terrace',
  'Refuge',
  'Religious Structure',
  'Residential',
  'Society Office',
  'SRA',
  'Upashray',
  'Void',
];

const residentialFlatValues = [
  '1 RK',
  '1 BHK',
  '2 BHK',
  '3 BHK',
  '4 BHK',
  '5 BHK',
  '6 BHK',
  '7 BHK',
  '8 BHK',
  '1 + 1 JODI',
  '2 + 1 JODI',
  '2 + 2 JODI',
  '2 + 3 JODI',
  'PENTHOUSE',
];

const commercialFlatValues = ['OFFICE', 'SHOP'];

const flatStatusValues = ['Available', 'Blocked', 'Hold'];

const flatStatusWithOtherOptionsValues = [
  'Available',
  'Blocked',
  'Hold',
  'Alloted',
  'Booked',
];

const flatFacingValues = [
  'City View',
  'Forest / Mangrove View',
  'Building View',
  'Internal Amenity View',
  'Garden View',
  'Club - House View',
  'Sea View',
  'Open View',
  'Others',
];

const caseTypeValues = ['Criminal', 'Civil'];

const courtTypeValues = [
  'Civil Court',
  'District Court',
  'High Court',
  'Session Court',
  'Supreme Court',
];

const genderValues = ['Male', 'Female', 'Other'];

const materialRequisitionStagesValues = [
  'Get Quotation',
  'Finalize Vendor',
  'Get Purchase Order',
  'Add GRN',
  'Add Invoice',
];

const materialRequisitionStatusValues = [
  'Pending',
  'Approved',
  'Rejected',
  'Completed',
  'Cancelled',
];

const projectStatusValues = [
  'On-Going',
  'Up-Coming',
  'Completed',
  'On-Hold',
  'Cancelled',
  'Planning',
];

const callStatusValues = [
  'Connected',
  'Not Connected',
  'Wrong Number',
  'Switched Off',
  'Busy',
  'No Answer',
  'Disconnected',
  'Rescheduled',
];
const callPurposeValues = [
  'Complaint',
  'Welcome Call',
  'Payment Follow - UP',
  'Registration Follow - UP',
  'Reminder',
  'Query Resolution',
  'Feedback',
  'Other',
];

const statusModeValues = [
  'Open',
  'Assigned',
  'In Progress',
  'Resolved',
  'ReOpen',
  'Closed',
];

const platformTypeValues = ['ERP', 'Application', 'Website'];

const moduleTypeValues = [
  'Dashboard',
  'Inventory',
  'Project Document',
  'Legal',
  'Marketing',
  'Procurement',
  'Project',
  'Stock Management',
  'Channel Partner',
  'Sale',
  'CRM',
  'Setting',
  'Payroll',
  'Redevelopment',
  'Operation',
];

const ibmObmRangeFilterValues = [
  'Below 10',
  'Between 11 And 50',
  'Between 51 And 100',
  'Between 101 And 200',
  'Between 201 And 300',
  'Between 301 And 400',
  'Between 401 And 500',
  'Above 501',
];

const inwardOutwardDocumentTypeValues = ['Inward', 'Outward'];

const inwardOutwardDeliveryModeValues = ['Courier', 'Hand-To-Hand'];

const inwardOutwardDeliveryStatusValues = ['Acknowledged', 'Delivered'];

const ibmObmReportTypeValues = ['Date', 'Year'];

const yearValues = [
  '2025',
  '2026',
  '2027',
  '2028',
  '2029',
  '2030',
  '2031',
  '2032',
  '2033',
  '2034',
  '2035',
  '2036',
  '2037',
  '2038',
  '2039',
  '2040',
  '2041',
  '2042',
];

const supportValues = [
  'Below The Line (BTL)',
  'Paper Insert',
  'Standee Require',
  'Video Recording',
];

const paymentModeValues = [
  'Cheque',
  'Demand Draft',
  'IMPS',
  'NEFT',
  'Online Transfer',
  'RTGS',
  'UPI',
];

const paymentTypeValues = ['Full', 'Partial'];

const financialYearValues = ['2025-26', '2026-27', '2027-28'];

const paymentReceivedFormValues = ['Bank', 'Owner'];
const paymentForValues = [
  'Stamp Duty',
  'Registration Fees',
  'Agreement Value (Without TDS)',
  'Agreement Value GST',
  'Agreement Value TDS',
  'Other Charges Value',
  'Other Charges GST',
];

const unitSqFtLumsumValues = ['Per SqFt', 'Lump Sum'];

const propertyTypeValues = ['Residential', 'Commercial'];
const tenureValues = [
  'Tenure 1',
  'Tenure 2',
  'Tenure 3',
  'Tenure 4',
  'Tenure 5',
  'Tenure 6',
  'Tenure 7',
  'Tenure 8',
  'Tenure 9',
  'Tenure 10',
  'Tenure 11',
  'Tenure 12',
  'Tenure 13',
  'Tenure 14',
];
const tenderPaymentModeValues = [
  'Cheque',
  'Cash',
  'Demand Draft',
  'IMPS',
  'NEFT',
  'Pay Order',
  'RTGS',
  'UPI',
];

const tenantDocumentTypeValues = [
  "33 (38) Notice",
  "79 / A Consent",
  "Additional Document (If Any)",
  "Affidavit",
  "Assessment Bill",
  "Consent For Cluster (If Applicable)",
  "Developer Format Consent",
  "Electric NOC",
  "Electricity Bill",
  "Eligible / Non Eligible (Form 3 & 4)",
  "Extra Area Purchase Letter",
  "Extra Purchase Payment Schedule",
  "Gas Bill",
  "Maintenance Bill",
  "MGL NOC",
  "MHADA Verified Consent",
  "Notarized Kararnama",
  "PAAA Floor Plan",
  "Photo Pass",
  "Photo Pass Receipt",
  "POA (Admission)",
  "Ration Card (If Applicable)",
  "Registered PAAA",
  "Rent Receipt (If Applicable)",
  "Repossession Letter",
  "Repossession Undertaking",
  "Sales Agreement",
  "Share Certificate",
  "Transfer Documents",
  "Unit Plan",
  "Vacant Possession Letter",
  "Vacating Consent Letter",
  "Yadi Slip",
];

const aopStatusValues = ['AOP', 'NON - AOP', 'EXPIRED', 'EXPIRE SOON'];

const applicantTypeValues = ['Applicant', 'Co - Applicant'];
