import 'package:flutter/material.dart';
import 'package:k3h_erp_app/features/login/presentation/widgets/login_text_field.widget.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/utils/common_function.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_button.dart';
import 'package:k3h_erp_app/widgets/buttons/custom_icon_button.dart';
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
                isDisable: true,
                text: 'Test',
                leading: Icon(Icons.add, color: AppColor.white,size: 12,),
              ),
              Row(
                spacing: 20,
                children: [
                  Expanded(child: CustomButton(onPressed: () {}, text: 'Test')),
                  CustomButton(
                    onPressed: () {},
                    isDisable: true,
                    text: 'Test',
                    leading: Icon(Icons.add, color: AppColor.white),
                  ),
                ],
              ),
              LoginTextFieldWidget(
                textController: TextEditingController(),
                hint: "Enter some text...",
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
                onPressed: () {},
                icon: Icons.notifications_none,
              ),
              Text(formatDateTimeAsDDMMMYYYY(DateTime.now()))
            ],
          ),
        ),
      ),
    );
  }
}
