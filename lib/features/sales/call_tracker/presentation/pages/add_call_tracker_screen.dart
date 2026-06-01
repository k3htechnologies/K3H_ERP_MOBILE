import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:k3h_erp_app/core/models/project.model.dart';
import 'package:k3h_erp_app/core/route_authorization.dart';
import 'package:k3h_erp_app/features/sales/call_tracker/presentation/cubit/call_tracker_cubit.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/static_data.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';
import 'package:k3h_erp_app/widgets/app_bar/custom_app_bar_with_back_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/dropdown/custom_dropdown.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class AddCallTrackerScreen extends StatefulWidget {
  const AddCallTrackerScreen({super.key});

  @override
  State<AddCallTrackerScreen> createState() => _AddCallTrackerScreenState();
}

class _AddCallTrackerScreenState extends State<AddCallTrackerScreen> {
  late CallTrackerCubit _callTrackerCubit;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC, _mobileNoC, _emailC, _addressC;
  late ProjectModel _selectedProject;
  final ValueNotifier<Map<String, dynamic>?> _selectedSource = ValueNotifier(
    null,
  );

  @override
  void initState() {
    _callTrackerCubit = context.read<CallTrackerCubit>();
    _initializeTextEditingControllers();
    _selectedProject = getProject();
    super.initState();
  }

  void _initializeTextEditingControllers() {
    _nameC = TextEditingController();
    _mobileNoC = TextEditingController();
    _emailC = TextEditingController();
    _addressC = TextEditingController();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _callTrackerCubit.addCallingData(
        context: context,
        projectId: _selectedProject.projectId,
        name: _nameC.text,
        emailId: _emailC.text,
        mobileNumber: _mobileNoC.text,
        address: _addressC.text,
        source: _selectedSource.value?['DisplayName'] ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithBackButton(
        screenTitle: 'Call Tracker',
        authorization: AuthorizationModel(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Call Tracker",
              style: AppTextStyle.ts14M(color: AppColor.grey),
            ),
            Container(
              decoration: commonCardDecoration(),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      textController: _nameC,
                      title: 'Name',
                      hint: 'Enter Name',
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _mobileNoC,
                      title: 'Mobile Number',
                      hint: 'Enter Mobile Number',
                      keyboardType: TextInputType.phone,
                      inputFormatterList: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Mobile number is required";
                        }
                        if (isValidMobileNumber(value.trim()) == false) {
                          return "Mobile number is invalid";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      textController: _emailC,
                      title: 'Email',
                      hint: 'Enter Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      textController: _addressC,
                      title: 'Address',
                      hint: 'Enter Address',
                      minLines: 3,
                      maxLines: 3,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _selectedSource,
                      builder: (context, source, child) {
                        return CustomDropDownWidget(
                          title: "Source",
                          hintText: "Select Source",
                          isRequired: true,
                          initialValue: source,
                          dataList: directWalkingSubSourceList,
                          onSelected: (v) {
                            _selectedSource.value = v;
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Source is required";
                            }
                            return null;
                          },
                          onValueClear: () {
                            _selectedSource.value = null;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          color: AppColor.white,
          padding: EdgeInsets.all(16),
          child: CustomButton(
            leading: Icon(Icons.add, color: AppColor.white, size: 16),
            text: "Add",
            onPressed: _submitForm,
          ),
        ),
      ),
    );
  }
}
