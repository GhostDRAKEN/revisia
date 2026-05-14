import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/document_service.dart';
import 'result_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _progress = 0;
  String? _errorMessage;

  Future<void> _pickFile() async {
    setState(() => _errorMessage = null);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _selectedFile = result.files.single);
  }

  Future<void> _upload() async {
    final file = _selectedFile;

    if (file == null || file.path == null) return;

    setState(() {
      _isUploading = true;
      _progress = 0;
      _errorMessage = null;
    });

    try {
      final document = await context.read<DocumentService>().uploadPdf(
        filePath: file.path!,
        fileName: file.name,
        onSendProgress: (sent, total) {
          if (total <= 0) return;
          setState(() => _progress = sent / total);
        },
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(document: document)),
      );
    } on ApiException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(() => _errorMessage = 'Une erreur est survenue, réessayez');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _formatSize(int size) {
    final mb = size / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    return '${(size / 1024).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final file = _selectedFile;

    return Scaffold(
      appBar: AppBar(title: const Text('Importer un cours')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: _isUploading ? null : _pickFile,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: file == null
                          ? const Color(0xFFD1D5DB)
                          : AppTheme.primaryColor,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        file == null
                            ? Icons.picture_as_pdf_outlined
                            : Icons.check_circle_outline,
                        color: file == null
                            ? Colors.black45
                            : AppTheme.secondaryColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        file?.name ?? 'Sélectionner un fichier PDF',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (file != null) ...[
                        const SizedBox(height: 6),
                        Text(_formatSize(file.size)),
                      ],
                    ],
                  ),
                ),
              ),
              if (_isUploading) ...[
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress,
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: file == null || _isUploading ? null : _upload,
                child: _isUploading
                    ? const Text('Analyse en cours...')
                    : const Text('Analyser'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
