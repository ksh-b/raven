import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:raven/repository/preferences/internal.dart';
import 'package:raven/repository/store.dart';

CacheOptions _cacheOptions() {

  return CacheOptions(
    store: Hive.isBoxOpen("settings")?HiveCacheStore(Internal.appDirectory):MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(minutes: 60),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: true,
  );
}

Dio dio() {
  Dio dio_ = Dio();

  List<String> retryBlacklist = ["SocketException: Failed host lookup"];

  var cacheInterceptor = DioCacheInterceptor(
    options: _cacheOptions(),
  );

  dio_.options = BaseOptions(
    validateStatus: (status) => true,
    connectTimeout: const Duration(seconds: 15),
  );

  dio_.interceptors.add(PrettyDioLogger(
    requestHeader: false,
    requestBody: false,
    responseBody: false,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 200,
    enabled: kDebugMode,
    filter: (options, args) {
      return !args.isResponse || !args.hasUint8ListData;
    },
  ));

  dio_.interceptors.add(
    RetryInterceptor(
      dio: dio_,
      logPrint: print,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 5),
      ],
      retryEvaluator: (error, attempt) {
        if (retryBlacklist.any((e) => error.error.toString().contains(e))) {
          return false;
        }
        return true;
      },
    ),
  );

  dio_.interceptors.add(cacheInterceptor);

  return dio_;
}
