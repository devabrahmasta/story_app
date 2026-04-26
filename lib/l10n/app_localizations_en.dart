// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Story App';

  @override
  String get login_title => 'Sign In';

  @override
  String get register_title => 'Create Account';

  @override
  String get email_hint => 'Email';

  @override
  String get password_hint => 'Password';

  @override
  String get name_hint => 'Full Name';

  @override
  String get sign_in_button => 'Sign In';

  @override
  String get register_button => 'Register';

  @override
  String get logout_button => 'Logout';

  @override
  String get logout_confirm => 'Are you sure you want to logout?';

  @override
  String get stories_title => 'Story';

  @override
  String get add_story_title => 'New Story';

  @override
  String get description_hint => 'Description';

  @override
  String get upload_button => 'Upload';

  @override
  String get camera_button => 'Camera';

  @override
  String get gallery_button => 'Gallery';

  @override
  String get error_no_image => 'Please select an image';

  @override
  String get error_empty_description => 'Description cannot be empty';

  @override
  String get loading_text => 'Loading...';

  @override
  String get no_stories => 'No stories yet';

  @override
  String get retry_button => 'Retry';

  @override
  String get upload_success => 'Story uploaded successfully!';

  @override
  String get logout_cancel => 'Cancel';

  @override
  String get take_photo => 'Take Photo';

  @override
  String get select_language => 'Language';
}
