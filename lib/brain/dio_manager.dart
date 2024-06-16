import 'package:dio/dio.dart';

Dio dio() {
  return Dio()..options = BaseOptions(validateStatus: (status) => true);
}
