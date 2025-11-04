import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:leavify/features/Leave/models/request/apply_leave_request_model.dart';

class DocumentHelper {
  static const _allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'jpg',
    'jpeg',
    'png',
  ];

  /// Opens file picker and returns the updated list of documents.
  static Future<List<PlatformFile>> pickDocuments(
    BuildContext context,
    List<PlatformFile> existingFiles,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );

      if (result == null) return existingFiles;

      final newFiles = <PlatformFile>[];
      for (final file in result.files) {
        final alreadyExists = existingFiles.any((f) => f.name == file.name);
        if (!alreadyExists) {
          newFiles.add(file);
        } else {
          // showInfo(context, 'File "${file.name}" already selected');
        }
      }

      return [...existingFiles, ...newFiles];
    } catch (e) {
      // showError(context, 'Failed to pick files');
      return existingFiles;
    }
  }

  /// Removes a file by index and returns the updated list.
  static List<PlatformFile> removeDocument(
    List<PlatformFile> files,
    int index,
  ) {
    if (index < 0 || index >= files.length) return files;
    final updated = List<PlatformFile>.from(files);
    updated.removeAt(index);
    return updated;
  }

  /// Converts picked files into LeaveDocumentForApply objects.
  static Future<List<LeaveDocumentForApply>> convertToLeaveDocuments(
    List<PlatformFile> files,
  ) async {
    final leaveDocuments = <LeaveDocumentForApply>[];

    for (final file in files) {
      Uint8List? bytes;
      if (file.bytes != null) {
        bytes = file.bytes;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }

      if (bytes == null) continue;

      final base64String = base64Encode(bytes);
      final extension = file.extension?.toLowerCase() ?? '';
      final docType = _getDocumentType(extension);

      leaveDocuments.add(
        LeaveDocumentForApply(docType: docType, docBytes: base64String),
      );
    }

    return leaveDocuments;
  }

  static String _getDocumentType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'doc';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      default:
        return 'unknown';
    }
  }
}
