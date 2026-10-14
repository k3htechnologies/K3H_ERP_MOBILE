part of '../add_tenant_booking_screen.dart';

// ═══════════════════════════ TERMS & CONDITION TAB ═══════════════════════════
extension _TermsTab on _AddTenantBookingScreenState {
  // BUILD TERMS AND CONDITION
  Widget _buildTermsAndCondition() {
    return Form(
      key: _termsFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpacing(),
            BlocBuilder<TenantBookingCubit, TenantBookingState>(
              bloc: _bookingCubit,
              builder: (context, state) {
                return ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _selectedTermsNotifier,
                  builder: (context, selectedTerms, child) {
                    return CustomMultipleSelectPopup(
                      title: "Terms & Conditions",
                      isRequired: true,
                      isMultiSelect: false,
                      initialValue: selectedTerms,
                      dataList: const [],
                      onSelected: (value) {
                        final copied =
                            value
                                .map((e) => Map<String, dynamic>.from(e))
                                .toList();
                        _selectedTermsNotifier.value = copied;
                        if (copied.isNotEmpty) {
                          _termsAndConditionDescriptionC.text = copied
                              .map((e) => e['Description'] ?? '')
                              .join('\n\n');
                        } else {
                          _termsAndConditionDescriptionC.clear();
                        }
                      },
                      dataFetchCallBack: _fetchTerms,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Terms & Conditions is required.";
                        }
                        return null;
                      },
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedTermsNotifier,
              builder: (context, selectedTerms, child) {
                if (selectedTerms.isEmpty) return SizedBox.shrink();
                return Column(
                  children:
                      selectedTerms.map((term) {
                        final title = term['DisplayName']?.toString() ?? '';
                        final desc = term['Description']?.toString() ?? '';
                        if (desc.isEmpty && title.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 8),
                          decoration: commonCardDecoration(),
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [if (desc.isNotEmpty) Html(data: desc)],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
