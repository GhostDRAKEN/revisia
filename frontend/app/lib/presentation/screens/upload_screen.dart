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
    final hasFile = file != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Importer un cours')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppTheme.softBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedScale(
                  scale: hasFile ? 1.02 : 1,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: InkWell(
                    onTap: _isUploading ? null : _pickFile,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.premiumCardDecoration(
                        gradient: hasFile
                            ? const LinearGradient(
                                colors: [Colors.white, Color(0xFFEFFDF9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Colors.white, Color(0xFFEFF6FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderColor: hasFile
                            ? AppTheme.secondaryColor
                            : Colors.white,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              gradient: hasFile
                                  ? const LinearGradient(
                                      colors: [
                                        AppTheme.secondaryColor,
                                        Color(0xFF34D399),
                                      ],
                                    )
                                  : AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: Icon(
                              hasFile
                                  ? Icons.check_rounded
                                  : Icons.picture_as_pdf_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            file?.name ?? 'Sélectionner un fichier PDF',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hasFile
                                ? _formatSize(file.size)
                                : 'PDF uniquement, jusqu’à 10 MB',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.mutedTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isUploading) ...[
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.premiumCardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analyse du document',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: _progress == 0 ? null : _progress,
                            minHeight: 10,
                            color: AppTheme.primaryColor,
                            backgroundColor: const Color(0xFFE0E7FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const Spacer(),
                GradientButton(
                  onPressed: hasFile && !_isUploading ? _upload : null,
                  isLoading: _isUploading,
                  child: const Text('Analyser'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
