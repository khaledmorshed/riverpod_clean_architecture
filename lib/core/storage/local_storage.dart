import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static const String _keyTenant = 'tenant';
  static const String _keyToken = 'token';
  static const String _keyRoleId = 'role_id';
  static const String _keyWarehouseId = 'warehouse_id';

  Future<void> saveTenant(String tenant) async {
    await _prefs.setString(_keyTenant, tenant);
  }

  String? getTenant() {
    return _prefs.getString(_keyTenant);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> saveRoleId(String roleId) async {
    await _prefs.setString(_keyRoleId, roleId);
  }

  String? getRoleId() {
    return _prefs.getString(_keyRoleId);
  }

  Future<void> saveWarehouseId(String warehouseId) async {
    await _prefs.setString(_keyWarehouseId, warehouseId);
  }

  String? getWarehouseId() {
    return _prefs.getString(_keyWarehouseId);
  }

  Future<void> clear() async {
    await _prefs.remove(_keyTenant);
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyRoleId);
    await _prefs.remove(_keyWarehouseId);
  }
}
