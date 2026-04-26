import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'package:camera/camera.dart';
import 'add_story_provider.dart';
import '../list/story_list_provider.dart';
import 'camera_screen.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Compress image
      final dir = Directory.systemTemp;
      final targetPath =
          '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        targetPath,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedFile != null && mounted) {
        context.read<AddStoryProvider>().setImageFile(
          File(compressedFile.path),
        );
      }
    }
  }

  Future<void> _openCamera() async {
    final cameras = await availableCameras();
    if (!mounted) return;
    final XFile? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CameraScreen(cameras: cameras)),
    );
    if (result != null && mounted) {
      final dir = Directory.systemTemp;
      final targetPath =
          '${dir.absolute.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        result.path,
        targetPath,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
      );
      if (compressedFile != null && mounted) {
        context.read<AddStoryProvider>().setImageFile(
          File(compressedFile.path),
        );
      }
    }
  }

  void _showImageSourceBottomSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.camera_button),
                onTap: () {
                  Navigator.pop(context);
                  _openCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.gallery_button),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AddStoryProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (provider.selectedImageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.error_no_image)));
      return;
    }

    final success = await provider.uploadStory(_descriptionController.text);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.upload_success)));
        context.read<StoryListProvider>().fetchStories();
        context.pop();
      } else if (provider.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.add_story_title)),
      body: Consumer<AddStoryProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceBottomSheet(context, l10n),
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: provider.selectedImageFile == null
                            ? Border.all(
                                color: colorScheme.outline,
                                style: BorderStyle.solid,
                              )
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: provider.selectedImageFile != null
                          ? Image.file(
                              provider.selectedImageFile!,
                              fit: BoxFit.cover,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.tap_to_select,
                                  style: TextStyle(color: colorScheme.outline),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(l10n.camera_button),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image),
                          label: Text(l10n.gallery_button),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.description_hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.error_empty_description;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed:
                          (provider.isLoading ||
                              provider.selectedImageFile == null)
                          ? null
                          : _upload,
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.upload_button),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
