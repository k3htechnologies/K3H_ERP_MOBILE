part of '../add_tenant_booking_screen.dart';

extension _RemarkTab on _AddTenantBookingScreenState {
  Widget _buildRemark() {
    return Form(
      key: _remarkFormKey,
      child: Container(
        margin: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Remark",
                style: AppTextStyle.ts14M(color: AppColor.grey),
              ),
              verticalSpacing(),
              Container(
                decoration: commonCardDecoration(),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      title: "Unit / Modulation / Customization Remark",
                      hint: "Enter Unit / Modulation / Customization Remark",
                      isRequired: true,
                      minLines: 3,
                      maxLines: 3,
                      textController: _unitModCustomizationRemarkC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Unit / Modulation / Customization Remark is required.";
                        }
                        if (value.trim().length < 25) {
                          return "Unit / Modulation / Customization Remark must be at least 25 characters";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Payment Related Remark",
                      hint: "Enter Payment Related Remark",
                      isRequired: true,
                      minLines: 3,
                      maxLines: 3,
                      textController: _paymentRemarkC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Payment Related Remark is required.";
                        }
                        if (value.trim().length < 25) {
                          return "Payment Related Remark must be at least 25 characters";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      title: "Other Remark",
                      hint: "Enter Other Remark",
                      minLines: 3,
                      maxLines: 3,
                      textController: _otherRemarkC,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
