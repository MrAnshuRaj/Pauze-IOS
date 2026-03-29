import '../../services/safe_web_controller_logic.dart';
import 'safe_webview_screen.dart';

class SafeFacebookScreen extends SafeWebViewScreen {
  const SafeFacebookScreen({super.key})
      : super(logic: const SafeWebControllerLogic(SafeSocialPlatform.facebook));
}
