import 'package:bloc/bloc.dart';

import '../../services/di/injection_container_common.dart';
import '../../services/storage/storage_service.dart';

class ThemePreferenceService {
  final _storage = serviceLocator<StorageService>();

  Future<void> setTheme(bool isDark) async {
    _storage.saveToDisk('isDarkTheme', isDark);
  }

  Future<bool?> getTheme() async {
    return _storage.getFromDisk('isDarkTheme');
  }
}

class ThemeCubit extends Cubit<bool> {
  final ThemePreferenceService _preferenceService;

  ThemeCubit(this._preferenceService) : super(false) {
    loadTheme();
  }

  void toggleTheme(bool isDark) {
    final isDark = !state;
    _preferenceService.setTheme(isDark);
    emit(isDark);
  }

  Future<void> loadTheme() async {
    final savedTheme = await _preferenceService.getTheme();
    emit(savedTheme ?? false);
  }
}
