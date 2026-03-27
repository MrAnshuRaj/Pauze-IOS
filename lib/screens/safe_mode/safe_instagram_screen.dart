import '../../services/safe_web_controller_logic.dart';
import 'safe_webview_screen.dart';

class SafeInstagramScreen extends SafeWebViewScreen {
  const SafeInstagramScreen({super.key})
      : super(logic: const SafeWebControllerLogic(SafeSocialPlatform.instagram));
}

