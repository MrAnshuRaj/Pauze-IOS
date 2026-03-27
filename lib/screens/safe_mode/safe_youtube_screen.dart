import '../../services/safe_web_controller_logic.dart';
import 'safe_webview_screen.dart';

class SafeYouTubeScreen extends SafeWebViewScreen {
  const SafeYouTubeScreen({super.key})
      : super(logic: const SafeWebControllerLogic(SafeSocialPlatform.youtube));
}

