import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:proxishare/logger.dart';

/// Handles a single HTTP request containing multipart/form-data (file upload)
/// and saves uploaded files to [saveDirectory].
/// Returns a list of saved file paths.
Future<List<String>> handleFileUpload(
  HttpRequest request,
  String saveDirectory,
) async {
  final savedFiles = <String>[];

  // Only POST requests with multipart/form-data
  if (request.method != 'POST' ||
      request.headers.contentType?.mimeType != 'multipart/form-data') {
    request.response
      ..statusCode = HttpStatus.methodNotAllowed
      ..write('Only POST with multipart/form-data supported');
    await request.response.close();
    return savedFiles;
  }

  // Get boundary from Content-Type header
  final boundary = request.headers.contentType?.parameters['boundary'];
  if (boundary == null) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..write('Missing boundary in Content-Type');
    await request.response.close();
    return savedFiles;
  }

  // Create directory if it doesn't exist
  final directory = Directory(saveDirectory);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  // Parse multipart parts
  final transformer = MimeMultipartTransformer(boundary);
  await for (final part in transformer.bind(request)) {
    final contentDisposition = part.headers['content-disposition'];
    if (contentDisposition == null) continue;

    final filename = RegExp(
      r'filename="(.+)"',
    ).firstMatch(contentDisposition)?.group(1);

    if (filename != null) {
      // Read binary data
      final fileBytes = await part.fold<List<int>>([], (prev, element) {
        prev.addAll(element);
        return prev;
      });

      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(fileBytes);
      savedFiles.add(file.path);
      logger.debug('✅ File saved: ${file.path} (${fileBytes.length} bytes)');
    } else {
      // Non-file form field (optional)
      final fieldContent = await utf8.decoder.bind(part).join();
      logger.debug('Field content: $fieldContent');
    }
  }

  request.response.write('Uploaded ${savedFiles.length} file(s)');
  await request.response.close();

  return savedFiles;
}
