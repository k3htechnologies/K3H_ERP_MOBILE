import 'package:flutter/material.dart';
import 'package:k3h_erp_app/core/models/user.model.dart';
import 'package:k3h_erp_app/routes/route_delegate.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class EmployeeMasterViewDetailsScreen extends StatelessWidget {
  final UserModel employee;
  const EmployeeMasterViewDetailsScreen({super.key, required this.employee});

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(title, style: AppTextStyle.ts16M()),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        spacing: 10.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label : ',
            style: AppTextStyle.ts12R(color: AppColor.grey),
            textAlign: TextAlign.start,
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyle.ts14R(),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataColumn(String label, String value) {
    return Column(
      spacing: 4.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label : ', style: AppTextStyle.ts12R(color: AppColor.grey)),
        Text(value, style: AppTextStyle.ts14R()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColor.black, size: 20),
          onPressed: () {
            goRouter.pop();
          },
        ),
        centerTitle: true,
        title: Text(
          'View Details',
          style: AppTextStyle.ts16R(),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: AppColor.greyBackground,

      body: ListView(
        children: [
          verticalSpacing(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border(
                top: BorderSide(color: AppColor.grey30),
                bottom: BorderSide(color: AppColor.grey30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header('Basic Details'),
                  _dataRow('First Name', employee.firstName),
                  _dataRow('Middle Name', employee.middleName),
                  _dataRow('Last Name', employee.lastName),
                  _dataRow('Gender', employee.gender),
                  _dataRow('Marital Status', employee.maritalStatus),
                  _dataRow('Blood Group', employee.bloodGroup),
                  _dataRow(
                    'DOB',
                    employee.dateOfBirth != null
                        ? formatDateTimeAsDDMMMYYYY(employee.dateOfBirth!)
                        : '-',
                  ),
                  _dataRow('Office Email Id', employee.officeEmailId),
                  _dataRow('Email Id', employee.emailId),
                  _dataRow(
                    'Personal Mobile Number',
                    employee.personalMobileNumber,
                  ),
                  _dataRow(
                    'Office / Landline Number',
                    employee.officeMobileNumber,
                  ),
                  _dataRow('Employment Type', employee.employeeType),
                  _dataRow(
                    'Relation To Emergency Contact',
                    employee.emergencyContactPersonRelationship,
                  ),
                  _dataRow(
                    'Emergency Contact Number',
                    employee.emergencyMobileNumber,
                  ),
                ],
              ),
            ),
          ),
          verticalSpacing(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border(
                top: BorderSide(color: AppColor.grey30),
                bottom: BorderSide(color: AppColor.grey30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header('Employee Info Sheet'),
                  _dataRow('Company Name', employee.companyName),
                  _dataRow('Branch', employee.branch),
                  _dataRow('Department', employee.department),
                  _dataRow('Designation', employee.designation),
                  _dataRow(
                    'Joining Date',
                    employee.joiningDate != null
                        ? formatDateTimeAsDDMMMYYYY(employee.joiningDate!)
                        : '-',
                  ),
                  _dataRow('Reporting Person', employee.reportPersonName),
                ],
              ),
            ),
          ),
          verticalSpacing(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border(
                top: BorderSide(color: AppColor.grey30),
                bottom: BorderSide(color: AppColor.grey30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header('Address'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _dataColumn(
                      'Communication Address',
                      employee.communicationAddress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _dataColumn(
                      'Permanent Address',
                      employee.permanentAddress,
                    ),
                  ),
                  Container(height: 1, color: AppColor.grey30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _dataColumn('State', employee.stateName),
                        ),
                        Expanded(
                          flex: 2,
                          child: _dataColumn('District', employee.districtName),
                        ),
                        Expanded(child: _dataColumn('City', employee.cityName)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          verticalSpacing(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              border: Border(
                top: BorderSide(color: AppColor.grey30),
                bottom: BorderSide(color: AppColor.grey30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header('Bank Details'),
                  _dataRow('Bank Name', employee.bankName),
                  _dataRow('Account Number', employee.accountNo),
                  _dataRow('Bank Branch Name', employee.bankBranchName),
                  _dataRow('IFSC Code', employee.ifscCode),
                ],
              ),
            ),
          ),
          verticalSpacing(height: 40),
        ],
      ),
    );
  }
}
