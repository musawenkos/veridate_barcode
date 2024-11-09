// lib/service/config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static final String goUPCApiBaseUrl = dotenv.env['GO_UPC_API_BASE_URL'] ?? "";
  static final String goUPCApiKey = dotenv.env['GO_UPC_API_KEY'] ?? "";
  static final String manufacturerApiKey = dotenv.env['MANUFACTURER_API_KEY'] ?? "";
}