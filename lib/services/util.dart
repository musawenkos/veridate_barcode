import 'dart:math';

class Utils {
  /// Generates a random date within a reasonable range (±30 days from today).
  static DateTime getRandomizedDate() {
    final random = Random();
    // Generate a random number of days between -30 and +30
    int daysOffset = random.nextInt(61) - 30;
    return DateTime.now().add(Duration(days: daysOffset));
  }
}
