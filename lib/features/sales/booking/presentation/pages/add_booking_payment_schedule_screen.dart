import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/features/sales/booking/data/model/booking.model.dart';

class AddBookingPaymentScheduleScreen extends StatefulWidget {
  const AddBookingPaymentScheduleScreen({super.key});

  @override
  State<AddBookingPaymentScheduleScreen> createState() =>
      _AddBookingPaymentScheduleScreenState();
}

class _AddBookingPaymentScheduleScreenState
    extends State<AddBookingPaymentScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  String selectedType = "Date";

  final TextEditingController _dateC = TextEditingController();
  final TextEditingController _percentageC = TextEditingController();
  final TextEditingController _otherStageC = TextEditingController();

  DateTime? selectedDate;

  Map<String, dynamic>? selectedStage;

  final List<Map<String, dynamic>> stageList = [
    {"Id": 1, "Name": "Plinth"},
    {"Id": 2, "Name": "Slab"},
    {"Id": 3, "Name": "Other"},
  ];

  bool get isOtherStage =>
      selectedStage != null && selectedStage!["Name"] == "Other";

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate = picked;
      _dateC.text = DateFormat("dd-MM-yyyy").format(picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    String name = "";
    DateTime? date;

    if (selectedType == "Date") {
      name = "Date Schedule";
      date = selectedDate;
    } else {
      name =
          isOtherStage
              ? _otherStageC.text.trim()
              : selectedStage?["Name"] ?? "";
    }

    final model = BookingPaymentScheduleData(
      bookingPaymentScheduleId: 0,
      type: selectedType,
      name: name,
      date: date,
      paymentSchedulePercentage: double.parse(_percentageC.text),
      paymentCummulativePercentage: 0,
      paymentScheduleAmount: 0,
      paymentScheduleGSTAmount: 0,
      paymentScheduleTDSAmount: 0,
      ranking: 0, // will be set later
    );

    Navigator.pop(context, model);
  }

  Widget _typeButton(String type) {
    final bool isSelected = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stageDropdown() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      value: selectedStage,
      hint: const Text("Select Stage"),
      items:
          stageList
              .map((e) => DropdownMenuItem(value: e, child: Text(e["Name"])))
              .toList(),
      onChanged: (value) {
        setState(() {
          selectedStage = value;
        });
      },
      validator: (value) {
        if (selectedType == "Stage" && value == null) {
          return "Stage is required";
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _dateC.dispose();
    _percentageC.dispose();
    _otherStageC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Payment Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Payment Schedule Type",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  _typeButton("Date"),
                  const SizedBox(width: 10),
                  _typeButton("Stage"),
                ],
              ),

              const SizedBox(height: 20),

              if (selectedType == "Date") ...[
                const Text("Date *"),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _dateC,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: "DD-MM-YYYY",
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: _pickDate,
                  validator: (value) {
                    if (selectedType == "Date" &&
                        (value == null || value.isEmpty)) {
                      return "Date is required";
                    }
                    return null;
                  },
                ),
              ],

              if (selectedType == "Stage") ...[
                const Text("Stage"),

                const SizedBox(height: 6),

                _stageDropdown(),

                const SizedBox(height: 15),

                if (isOtherStage) ...[
                  const Text("Other Stage *"),

                  const SizedBox(height: 6),

                  TextFormField(
                    controller: _otherStageC,
                    decoration: const InputDecoration(
                      hintText: "Enter Stage",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (isOtherStage && (value == null || value.isEmpty)) {
                        return "Other Stage is required";
                      }
                      return null;
                    },
                  ),
                ],
              ],

              const SizedBox(height: 20),

              const Text("Percentage (%) *"),

              const SizedBox(height: 6),

              TextFormField(
                controller: _percentageC,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  hintText: "Enter Percentage",
                  suffixText: "%",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Percentage is required";
                  }

                  final percent = double.tryParse(value);

                  if (percent == null || percent <= 0 || percent > 100) {
                    return "Enter valid percentage";
                  }

                  return null;
                },
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text("Add"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
