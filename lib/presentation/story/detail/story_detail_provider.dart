import 'package:flutter/material.dart';
import '../../../core/api/api_result.dart';
import '../../../core/utils/result_state.dart';
import '../../../data/models/story.dart';
import '../../../data/repositories/story_repository.dart';

class StoryDetailProvider extends ChangeNotifier {
  final StoryRepository _storyRepository;
  final String storyId;

  StoryDetailProvider(this._storyRepository, this.storyId) {
    fetchDetail();
  }

  ResultState _state = ResultState.loading;
  ResultState get state => _state;

  Story? _story;
  Story? get story => _story;

  String _message = '';
  String get message => _message;

  Future<void> fetchDetail() async {
    _state = ResultState.loading;
    notifyListeners();

    final result = await _storyRepository.getStoryDetail(storyId);

    if (result is Success<Story>) {
      _state = ResultState.hasData;
      _story = result.data;
    } else if (result is Error<Story>) {
      _state = ResultState.error;
      _message = result.message;
    }
    notifyListeners();
  }
}
