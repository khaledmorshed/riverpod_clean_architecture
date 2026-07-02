import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';

// To be overridden in main() on startup
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final localStorageProvider = Provider<LocalStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorage(prefs);
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.trialfirewoodlpg.com/api/v1/', // Default fallback base URL
  ));
});

final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(dioProvider);
  final localStorage = ref.watch(localStorageProvider);
  return DioClient(dio, localStorage);
});
