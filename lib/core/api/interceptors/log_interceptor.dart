import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class AppLogInterceptor extends PrettyDioLogger {
  AppLogInterceptor()
      : super(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
          maxWidth: 90,
        );
}