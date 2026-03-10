import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:proxishare/components/toast.dart';
import 'package:proxishare/server/upload_settings.dart';
import 'package:proxishare/logger.dart';

class UploadSettingsWidget extends StatefulWidget {
  const UploadSettingsWidget({super.key});

  @override
  State<UploadSettingsWidget> createState() => _UploadSettingsWidgetState();
}

class _UploadSettingsWidgetState extends State<UploadSettingsWidget> {
  UploadSettings? _settings;
  final _formKey = GlobalKey<FormState>();

  static bool get _supportsGallery => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    try {
      _settings = await UploadSettings.init();
      final savedPath = _settings!.filesDestination;
      _filesController.text = savedPath.isEmpty
          ? await UploadSettings.getDefaultFilesDestination()
          : savedPath;
      _autoSaveGallery = _settings!.saveMediaToGallery;
      _alwaysAskSaveLocation = _settings!.alwaysAskSaveLocation;
      setState(() {});
    } catch (e) {
      logger.error('Failed to initialize upload settings: $e');
    }
  }

  Future<void> _resetToDefault() async {
    final defaultPath = await UploadSettings.getDefaultFilesDestination();
    _filesController.text = defaultPath;
    _autoSaveGallery = _settings!.saveMediaToGallery;
    _alwaysAskSaveLocation = _settings!.alwaysAskSaveLocation;
    setState(() {});
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      _filesController.text = result;
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState?.validate() == true) {
      try {
        final filesPath = _filesController.text.trim();
        await _settings?.setFilesDestination(
          filesPath == UploadSettings.askEveryTimePath ? '' : filesPath,
        );
        await _settings?.setSaveMediaToGallery(_autoSaveGallery);
        await _settings?.setAlwaysAskSaveLocation(_alwaysAskSaveLocation);
        showToast(context, 'Settings saved successfully');
      } catch (e) {
        logger.error('Failed to save settings: $e');
        showToast(context, 'Failed to save settings');
      }
    }
  }

  final _filesController = TextEditingController();
  bool _autoSaveGallery = false;
  bool _alwaysAskSaveLocation = false;

  @override
  void dispose() {
    _filesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              const Text(
                'Files Destination',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _filesController,
                      decoration: const InputDecoration(
                        hintText: 'Select a folder',
                        labelText: 'Files Path',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a folder';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _pickFolder,
                    icon: const Icon(Icons.folder_open),
                    tooltip: 'Browse',
                  ),
                ],
              ),

              if (_supportsGallery) ...[
                const SizedBox(height: 16),
                const Text(
                  'Gallery',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Auto-save media to gallery'),
                    const SizedBox(width: 8),
                    Switch(
                      value: _autoSaveGallery,
                      onChanged: (value) {
                        setState(() {
                          _autoSaveGallery = value;
                        });
                      },
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Always ask where to save'),
                  const SizedBox(width: 8),
                  Switch(
                    value: _alwaysAskSaveLocation,
                    onChanged: (value) {
                      setState(() {
                        _alwaysAskSaveLocation = value;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveSettings();
                      },
                      child: const Text('Save Settings'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetToDefault,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
