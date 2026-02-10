import 'package:k3h_erp_app/features/sales/enquiry/data/datasource/enquiry.datasource.dart';

abstract interface class EnquiryRepository {}

class EnquiryRepositoryImpl extends EnquiryRepository {
  EnquiryDatasource enquiryDatasource;
  EnquiryRepositoryImpl({required this.enquiryDatasource});
}
