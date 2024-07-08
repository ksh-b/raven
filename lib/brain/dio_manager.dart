import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

Dio dio() {
  final dio_ = Dio();
  dio_.options = BaseOptions(validateStatus: (status) => true);
  dio_.interceptors.add(
    RetryInterceptor(
      dio: dio_,
      logPrint: print,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 2),
        Duration(seconds: 3),
        Duration(seconds: 5),
      ],
    ),
  );
  return dio_;
}
