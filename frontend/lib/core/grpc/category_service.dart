import '../../generated/findiary/v1/category_service.pbgrpc.dart';
import '../../generated/findiary/v1/common.pb.dart';
import '../client/grpc_client.dart';

class CategoryGrpcService {
  final CategoryServiceClient _stub;

  CategoryGrpcService(GrpcClient grpcClient)
      : _stub = CategoryServiceClient(grpcClient.channel);

  Future<Category> createPersonalCategory(String name, String type,
      {String? icon, String? color}) async {
    final request = CreateCategoryRequest()
      ..name = name
      ..type = type
      ..scope = 'personal';
    if (icon != null) request.icon = icon;
    if (color != null) request.color = color;
    final response = await _stub.createCategory(request);
    return response.category;
  }

  Future<Category> createFamilyCategory(String familyId, String name,
      String type, {String? icon, String? color}) async {
    final request = CreateCategoryRequest()
      ..name = name
      ..type = type
      ..scope = 'family'
      ..familyId = familyId;
    if (icon != null) request.icon = icon;
    if (color != null) request.color = color;
    final response = await _stub.createCategory(request);
    return response.category;
  }

  Future<Category> getCategory(String id) async {
    final request = GetCategoryRequest()..id = id;
    final response = await _stub.getCategory(request);
    return response.category;
  }

  Future<List<Category>> listCategories(
      {String? scope, String? familyId, String? type}) async {
    final request = ListCategoriesRequest()
      ..scope = scope ?? ''
      ..type = type ?? '';
    if (familyId != null) request.familyId = familyId;
    final response = await _stub.listCategories(request);
    return response.categories;
  }

  Future<void> deleteCategory(String id) async {
    final request = DeleteCategoryRequest()..id = id;
    await _stub.deleteCategory(request);
  }
}
