import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/login/presentation/widgets/login_text_field.widget.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/utils/dialog_helper.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
import 'package:k3h_erp_app/widgets/custom_date_picker.dart';
import 'package:k3h_erp_app/widgets/network_image_widget.dart';
import 'package:k3h_erp_app/widgets/text_field/custom_text_field.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                onPressed: () {},
                text: 'Edit',
                leading: Icon(Icons.edit, color: AppColor.white, size: 12),
              ),
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: CustomButton(
                      onPressed: () async {
                        await DialogHelper.showCustomBottomSheet(
                          context,
                          "Hello World",
                          Container(height: 100, color: Colors.red),
                        );
                      },
                      text: 'Save Changes',
                    ),
                  ),
                  CustomButton(
                    backgroundColor: AppColor.error,
                    onPressed: () {
                      DialogHelper.deleteDialog(
                        context,
                        "Delete",
                        "Do you really want to delete this xxxx, It will permanently delete from table.",
                      );
                    },
                    text: 'Delete',
                  ),
                ],
              ),
              LoginTextFieldWidget(
                textController: TextEditingController(),
                hint: "Enter some text... ",
                prefixWidget: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 10),
                      Text("+91"),
                      VerticalDivider(
                        color: AppColor.black,
                        thickness: 0.5,
                        width: 15,
                        indent: 5,
                        endIndent: 5,
                      ),
                    ],
                  ),
                ),
              ),
              CustomTextField(
                textController: TextEditingController(),
                hint: "Enter some text...",
                title: "Hello World",
                isRequired: true,
              ),
              CustomIconButton(
                onPressed: () {
                  DialogHelper.showProcessingOverlay(context);
                },
                icon: Icons.notifications_none,
              ),
              Text(formatDateTimeAsDDMMMYYYY(DateTime.now())),
              NetworkImageWidget(
                imageUrl:
                    "https://plus.unsplash.com/premium_photo-1667358091118-29e916ddbcc5?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fGh1c2t5fGVufDB8fDB8fHww",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(55),
              ),
              CustomTextField(
                textController: TextEditingController(),
                hint: "Enter some text...",
                title: "Remark",
                minLines: 3,
                maxLines: 3,
              ),
              Row(
                spacing: 20,
                children: [
                  Expanded(child: CustomButton.resetOutline(onPressed: () {})),
                  Expanded(child: CustomButton.cancelOutline(onPressed: () {})),
                ],
              ),
              CustomDatePicker(
                title: "Date",
                initialDate: DateTime.now(),
                setValue: (value) {},
                isRequired: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
