import 'package:calender/utils/request.dart'; 

Future<dynamic> getListCategories(String id) async {
  final result = await ApiService.get('categories?userId=$id');
  return result;
}
