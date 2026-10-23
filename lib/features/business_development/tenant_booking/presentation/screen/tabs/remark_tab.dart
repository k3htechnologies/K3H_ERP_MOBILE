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
                      minLines: 3,
                      maxLines: 3,
                      textController: _unitModCustomizationRemarkC,
                    ),
                    CustomTextField(
                      title: "Payment Related Remark",
                      hint: "Enter Payment Related Remark",
                      minLines: 3,
                      maxLines: 3,
                      textController: _paymentRemarkC,
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
