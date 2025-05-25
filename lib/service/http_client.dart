import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:raven/repository/preferences/internal.dart';

CacheOptions _cacheOptions() {
  return CacheOptions(
    store: Hive.isBoxOpen("settings")
        ? HiveCacheStore(Internal.appDirectory)
        : MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnNetworkFailure: true,
    maxStale: const Duration(minutes: 60),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: true,
  );
}

Dio dio() {
  var headers = {
    'User-Agent':
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
  };
  Dio dio_ = Dio();

  List<String> retryBlacklist = ["SocketException: Failed host lookup"];

  var cacheInterceptor = DioCacheInterceptor(
    options: _cacheOptions(),
  );

  dio_.options = BaseOptions(
    headers: headers,
    validateStatus: (status) => true,
    connectTimeout: const Duration(seconds: 5),
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
    logPrint: (object) async {
      var directory = await getTemporaryDirectory();
      File logs = File(
        '${directory.path}/raven_logs.txt',
      );
      String log = "$object\n"
          .replaceAll("║", "")
          .replaceAll("╚", "")
          .replaceAll("╔╣", "")
          .replaceAll("╝", "")
          .replaceAll("═", "")
          .replaceAll("╟", "");
      logs.writeAsStringSync(log, mode: FileMode.append);
    },
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
