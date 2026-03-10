import 'package:path_provider/path_provider.dart';
import 'package:proxishare/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadSettings {
  static const _autoAskMediaKey = 'upload_auto_ask_media';
  static const _filesDestKey = 'upload_files_destination';
  static const _alwaysAskSaveLocationKey = 'upload_always_ask_save_location';
  static const String askEveryTimePath = 'ciao';

  static UploadSettings? _instance;

  final SharedPreferences _prefs;

  UploadSettings(this._prefs);

  static Future<UploadSettings> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = UploadSettings(prefs);
    logger.debug("UploadSettings initializing instance $_instance");
    return _instance!;
  }

  static UploadSettings get instance {
    if (_instance == null) {
      throw StateError('UploadSettings not initialized. Call init() first.');
    }
    return _instance!;
  }

  static Future<String> getDefaultFilesDestination() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/ProxiShare';
  }

  Future<String> getFilesDestinationWithDefault() async {
    final saved = filesDestination;
    if (saved.isEmpty || saved == askEveryTimePath) {
      return getDefaultFilesDestination();
    }
    return saved;
  }

  bool get saveMediaToGallery {
    return _prefs.getBool(_autoAskMediaKey) ?? false;
  }

  Future<void> setSaveMediaToGallery(bool value) async {
    await _prefs.setBool(_autoAskMediaKey, value);
  }

  String get filesDestination {
    final dest = _prefs.getString(_filesDestKey) ?? '';
    logger.debug("Files destination $dest");
    return dest;
  }

  Future<void> setFilesDestination(String path) async {
    await _prefs.setString(_filesDestKey, path);
  }

  bool get alwaysAskSaveLocation {
    return _prefs.getBool(_alwaysAskSaveLocationKey) ?? false;
  }

  Future<void> setAlwaysAskSaveLocation(bool value) async {
    await _prefs.setBool(_alwaysAskSaveLocationKey, value);
  }
}
