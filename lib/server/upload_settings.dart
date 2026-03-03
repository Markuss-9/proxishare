import 'package:proxishare/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proxishare/server/events.dart';

class UploadSettings {
  static const _targetKey = 'upload_default_target';
  static const _folderKey = 'upload_default_folder';
  static const _autoAskMediaKey = 'upload_auto_ask_media';
  static const _galleryDestKey = 'upload_gallery_destination';
  static const _filesDestKey = 'upload_files_destination';

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

  bool get saveMediaToGallery {
    return _prefs.getBool(_autoAskMediaKey) ?? false;
  }

  Future<void> setSaveMediaToGallery(bool value) async {
    await _prefs.setBool(_autoAskMediaKey, value);
  }

  String get galleryDestination {
    return _prefs.getString(_galleryDestKey) ?? 'ProxiShare';
  }

  Future<void> setGalleryDestination(String path) async {
    await _prefs.setString(_galleryDestKey, path);
  }

  String get filesDestination {
    return _prefs.getString(_filesDestKey) ?? 'ProxiShare/files';
  }

  Future<void> setFilesDestination(String path) async {
    await _prefs.setString(_filesDestKey, path);
  }

  UploadDestination get defaultTarget {
    final value = _prefs.getString(_targetKey);
    return value == 'files'
        ? UploadDestination.files
        : UploadDestination.gallery;
  }

  Future<void> setDefaultTarget(UploadDestination target) async {
    await _prefs.setString(
      _targetKey,
      target == UploadDestination.files ? 'files' : 'gallery',
    );
  }

  String? get defaultFolder => _prefs.getString(_folderKey);

  Future<void> setDefaultFolder(String? folder) async {
    if (folder == null || folder.isEmpty) {
      await _prefs.remove(_folderKey);
    } else {
      await _prefs.setString(_folderKey, folder);
    }
  }
}
