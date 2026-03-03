import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    try {
      _settings = await UploadSettings.init();
      setState(() {});
    } catch (e) {
      logger.error('Failed to initialize upload settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState?.validate() == true) {
      try {
        await _settings?.setGalleryDestination(_galleryController.text.trim());
        await _settings?.setFilesDestination(_filesController.text.trim());
        await _settings?.setSaveMediaToGallery(_autoSaveGallery);
        showToast(context, 'Settings saved successfully');
      } catch (e) {
        logger.error('Failed to save settings: $e');
        showToast(context, 'Failed to save settings');
      }
    }
  }

  final _galleryController = TextEditingController();
  final _filesController = TextEditingController();
  bool _autoSaveGallery = false;

  @override
  void dispose() {
    _galleryController.dispose();
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
                'Gallery Destination',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextFormField(
                controller: _galleryController,
                decoration: const InputDecoration(
                  hintText: 'Enter gallery folder path',
                  labelText: 'Gallery Path',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gallery path';
                  }
                  return null;
                },
              ),

              const Text(
                'Files Destination',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              TextFormField(
                controller: _filesController,
                decoration: const InputDecoration(
                  hintText: 'Enter files folder path',
                  labelText: 'Files Path',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a files path';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Auto-save media to gallery: '),
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
                      onPressed: () {
                        _galleryController.text = _settings!.galleryDestination;
                        _filesController.text = _settings!.filesDestination;
                        _autoSaveGallery = _settings!.saveMediaToGallery;
                        setState(() {});
                      },
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
