import 'dart:io';
import '../../core/api/api_result.dart';
import '../../core/api/api_service.dart';
import '../models/story.dart';

class StoryRepository {
  final ApiService _apiService;

  StoryRepository(this._apiService);

  Future<Result<List<Story>>> getStories({int page = 1, int size = 10}) async {
    return await _apiService.getStories(page: page, size: size);
  }

  Future<Result<Story>> getStoryDetail(String id) async {
    return await _apiService.getStoryDetail(id);
  }

  Future<Result<bool>> addStory(File photo, String description) async {
    return await _apiService.addStory(photo, description);
  }
}
