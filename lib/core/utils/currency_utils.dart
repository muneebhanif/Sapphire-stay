import '../constants/app_constants.dart';

abstract final class CurrencyUtils {
  static int usdToPkr(double usd) {
    return (usd * AppConstants.usdToPkrRate).round();
  }

  static String formatPkr(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    var count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }

    return 'PKR ${buffer.toString().split('').reversed.join()}';
  }
}
