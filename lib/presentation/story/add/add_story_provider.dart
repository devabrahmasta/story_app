import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/api/api_result.dart';
import '../../../data/repositories/story_repository.dart';

class AddStoryProvider extends ChangeNotifier {
  final StoryRepository _storyRepository;

  AddStoryProvider(this._storyRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  File? _selectedImageFile;
  File? get selectedImageFile => _selectedImageFile;

  void setImageFile(File file) {
    _selectedImageFile = file;
    notifyListeners();
  }

  void clearImage() {
    _selectedImageFile = null;
    notifyListeners();
  }

  Future<bool> uploadStory(String description) async {
    if (_selectedImageFile == null) {
      _errorMessage = 'Please select an image';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _storyRepository.addStory(
      _selectedImageFile!,
      description,
    );

    _isLoading = false;
    if (result is Success<bool>) {
      notifyListeners();
      return true;
    } else if (result is Error<bool>) {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }
}
