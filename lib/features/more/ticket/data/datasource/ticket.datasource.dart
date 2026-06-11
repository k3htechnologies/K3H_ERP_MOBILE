import 'package:k3h_erp_app/features/more/ticket/data/model/ticket.model.dart';
import 'package:k3h_erp_app/features/more/ticket/data/model/ticket_employee.model.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/service/exceptions.dart';

abstract interface class TicketDatasource {
  Future<Map<String, dynamic>> apicallPullTicket({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
  Future<Map<String, dynamic>> pullEmployeeActiveTickets({
    required int pageNumber,
    required int pageSize,
  });
  Future<Map<String, dynamic>> apicallAssignTicket({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallAddUpdateTicket({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  });
  Future<Map<String, dynamic>> apicallDeleteTicket({
    required int ticketId,
    required String uniqueKey,
  });
  Future<Map<String, dynamic>> apicallPullTicketForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  });
}

class TicketDatasourceImpl implements TicketDatasource {
  final BaseClient baseClient = BaseClient();

  @override
  Future<Map<String, dynamic>> apicallPullTicket({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTicketUrl({
      required int pageNumber,
      required int pageSize,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Ticket/PullTicket?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTicketUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': List<TicketModel>.from(
          networkResponse["data"].map((e) => TicketModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallPullTicket(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> pullEmployeeActiveTickets({
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await baseClient.getRequestWithAuthentication(
      "Ticket/PullEmployeeActiveTickets"
      "?PageSize=$pageSize"
      "&PageNumber=$pageNumber"
      "&SortBy=DESC",
    );

    return {
      "data": List<TicketEmployeeModel>.from(
        response["data"].map((e) => TicketEmployeeModel.fromJson(e)),
      ),
      "totalNumberOfRecord": response["totalNumberOfRecord"],
    };
  }

  @override
  Future<Map<String, dynamic>> apicallAssignTicket({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String url = "Ticket/AssignTicket";
    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(url, fileList, body);
      return {
        'data': List<TicketModel>.from(
          networkResponse["data"].map((e) => TicketModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAssignTicket(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallAddUpdateTicket({
    required Map<String, String> body,
    required List<Map<String, dynamic>> fileList,
  }) async {
    String url = "Ticket/AddUpdateTicket";
    try {
      var networkResponse = await baseClient
          .multipartRequestWithAuthenticationBytes(url, fileList, body);
      return {
        'data': List<TicketModel>.from(
          networkResponse["data"].map((e) => TicketModel.fromJson(e)),
        ),
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
        'message': networkResponse['message'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallAddUpdateTicket(body: body, fileList: fileList);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallDeleteTicket({
    required int ticketId,
    required String uniqueKey,
  }) async {
    String deleteTicketUrl({required int ticketId, required String uniqueKey}) {
      return "Ticket/DeleteTicket?TicketId=$ticketId&Uniquekey=$uniqueKey";
    }

    try {
      var networkResponse = await baseClient.deleteRequestWithAuthentication(
        deleteTicketUrl(ticketId: ticketId, uniqueKey: uniqueKey),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['TotalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        return apicallDeleteTicket(ticketId: ticketId, uniqueKey: uniqueKey);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> apicallPullTicketForExport({
    required int pageNumber,
    required int pageSize,
    Map<String, dynamic>? queryParams,
  }) async {
    String pullTicketExportUrl({
      required int pageSize,
      required int pageNumber,
      Map<String, dynamic>? queryParams,
    }) {
      String url =
          "Ticket/PullTicket?PageSize=$pageSize&PageNumber=$pageNumber";
      queryParams?.forEach((key, value) => url += "&$key=$value");
      return url;
    }

    try {
      var networkResponse = await baseClient.getRequestWithAuthentication(
        pullTicketExportUrl(
          pageSize: pageSize,
          pageNumber: pageNumber,
          queryParams: queryParams,
        ),
      );
      return {
        'data': networkResponse["data"],
        'totalNumberOfRecord': networkResponse['totalNumberOfRecord'],
      };
    } catch (error) {
      if (error is TokenExpiredException) {
        apicallPullTicketForExport(
          pageNumber: pageNumber,
          pageSize: pageSize,
          queryParams: queryParams,
        );
      }
      rethrow;
    }
  }
}
