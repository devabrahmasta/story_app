import 'package:flutter/material.dart';
import '../../../core/api/api_result.dart';
import '../../../core/utils/result_state.dart';
import '../../../data/models/story.dart';
import '../../../data/repositories/story_repository.dart';

class StoryListProvider extends ChangeNotifier {
  final StoryRepository _storyRepository;

  StoryListProvider(this._storyRepository);

  ResultState _state = ResultState.loading;
  ResultState get state => _state;

  List<Story> _stories = [];
  List<Story> get stories => _stories;

  String _message = '';
  String get message => _message;

  Future<void> fetchStories() async {
    _state = ResultState.loading;
    notifyListeners();

    final result = await _storyRepository.getStories();

    if (result is Success<List<Story>>) {
      final data = result.data;
      if (data.isEmpty) {
        _state = ResultState.noData;
        _message = 'No stories yet';
      } else {
        _state = ResultState.hasData;
        _stories = data;
      }
    } else if (result is Error<List<Story>>) {
      _state = ResultState.error;
      _message = result.message;
    }
    notifyListeners();
  }
}
