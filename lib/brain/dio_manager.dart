import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';


Dio dio() {
  late CacheStore cacheStore;
  cacheStore = HiveCacheStore(null);
  var cacheOptions = CacheOptions(
    keyBuilder: (request) {
      return request.baseUrl + request.extra.toString();
    },
    store: cacheStore,
    hitCacheOnErrorExcept: [],
    maxStale: Duration(minutes: 2),
  );
  final dio = Dio()
    ..interceptors.add(
      DioCacheInterceptor(options: cacheOptions),
    );
  return Dio();
}
