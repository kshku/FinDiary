import '../../generated/findiary/v1/transaction_service.pbgrpc.dart';
import '../../generated/findiary/v1/common.pb.dart';
import '../client/grpc_client.dart';

class TransactionGrpcService {
  final TransactionServiceClient _stub;

  TransactionGrpcService(GrpcClient grpcClient)
      : _stub = TransactionServiceClient(grpcClient.channel);

  Future<Transaction> createTransaction({
    String? familyId,
    required String type,
    required double amount,
    String currency = 'INR',
    required String categoryId,
    String? description,
    required String date,
  }) async {
    final request = CreateTransactionRequest()
      ..type = type
      ..amount = amount
      ..currency = currency
      ..categoryId = categoryId
      ..date = date;
    if (description != null) request.description = description;
    if (familyId != null) request.familyId = familyId;
    final response = await _stub.createTransaction(request);
    return response.transaction;
  }

  Future<Transaction> getTransaction(String id) async {
    final request = GetTransactionRequest()..id = id;
    final response = await _stub.getTransaction(request);
    return response.transaction;
  }

  Future<Transaction> updateTransaction({
    required String id,
    required String type,
    required double amount,
    String currency = 'INR',
    required String categoryId,
    String? description,
    required String date,
  }) async {
    final request = UpdateTransactionRequest()
      ..id = id
      ..type = type
      ..amount = amount
      ..currency = currency
      ..categoryId = categoryId
      ..date = date;
    if (description != null) request.description = description;
    final response = await _stub.updateTransaction(request);
    return response.transaction;
  }

  Future<void> deleteTransaction(String id) async {
    final request = DeleteTransactionRequest()..id = id;
    await _stub.deleteTransaction(request);
  }

  Future<({List<Transaction> transactions, int total, int nextPageToken})>
      listTransactions({
    String? familyId,
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    int pageSize = 50,
    int pageToken = 0,
  }) async {
    final request = ListTransactionsRequest()
      ..type = type ?? ''
      ..categoryId = categoryId ?? ''
      ..startDate = startDate ?? ''
      ..endDate = endDate ?? ''
      ..pageSize = pageSize
      ..pageToken = pageToken;
    if (familyId != null) {
      request.familyId = familyId;
    }
    final response = await _stub.listTransactions(request);
    return (
      transactions: response.transactions,
      total: response.total,
      nextPageToken: response.nextPageToken,
    );
  }
}
