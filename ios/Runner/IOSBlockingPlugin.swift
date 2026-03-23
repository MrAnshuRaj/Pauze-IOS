import Flutter
import UIKit

final class IOSBlockingPlugin: NSObject, FlutterPlugin {
  private var manager: ScreenTimeManagerProtocol?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "scrollrok/ios_blocking", binaryMessenger: registrar.messenger())
    let instance = IOSBlockingPlugin()

    if #available(iOS 16.0, *) {
      instance.manager = ScreenTimeManager.shared
    }

    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.0, *) else {
      result(
        FlutterError(
          code: "unsupported_ios_version",
          message: "FamilyControls requires iOS 16.0 or newer.",
          details: nil
        )
      )
      return
    }

    guard let manager else {
      result(
        FlutterError(
          code: "manager_unavailable",
          message: "ScreenTime manager failed to initialize.",
          details: nil
        )
      )
      return
    }

    switch call.method {
    case "requestAuthorization":
      manager.requestAuthorization { granted, error in
        if let error {
          result(
            FlutterError(
              code: "authorization_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
          return
        }
        result(granted)
      }

    case "selectApps":
      guard let presenter = UIApplication.shared.topMostViewController() else {
        result(
          FlutterError(
            code: "ui_unavailable",
            message: "Unable to present FamilyActivityPicker.",
            details: nil
          )
        )
        return
      }

      manager.presentPicker(from: presenter) { pickerResult in
        switch pickerResult {
        case .success(let summary):
          result(
            [
              "selectedCount": summary.selectedCount,
              "selectedLabels": summary.selectedLabels,
            ]
          )
        case .failure(let error):
          result(
            FlutterError(
              code: "picker_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }

    case "blockApps":
      manager.applyShields()
      result(nil)

    case "unblockApps":
      let args = call.arguments as? [String: Any]
      let durationMinutes = (args?["durationMinutes"] as? NSNumber)?.intValue ?? 10
      manager.unblockTemporarily(durationMinutes: max(durationMinutes, 1))
      result(nil)

    case "scheduleBlocking":
      let args = call.arguments as? [String: Any] ?? [:]
      let startHour = (args["startHour"] as? NSNumber)?.intValue ?? 9
      let startMinute = (args["startMinute"] as? NSNumber)?.intValue ?? 0
      let endHour = (args["endHour"] as? NSNumber)?.intValue ?? 18
      let endMinute = (args["endMinute"] as? NSNumber)?.intValue ?? 0
      let enabled = (args["enabled"] as? Bool) ?? true

      do {
        try manager.scheduleBlocking(
          startHour: startHour,
          startMinute: startMinute,
          endHour: endHour,
          endMinute: endMinute,
          enabled: enabled
        )
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "schedule_error",
            message: error.localizedDescription,
            details: nil
          )
        )
      }

    case "getUsageData":
      result(manager.usageSnapshot())

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

extension UIApplication {
  func topMostViewController(
    base: UIViewController? = nil
  ) -> UIViewController? {
    let root = base ?? connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })?
      .rootViewController

    if let nav = root as? UINavigationController {
      return topMostViewController(base: nav.visibleViewController)
    }

    if let tab = root as? UITabBarController,
       let selected = tab.selectedViewController {
      return topMostViewController(base: selected)
    }

    if let presented = root?.presentedViewController {
      return topMostViewController(base: presented)
    }

    return root
  }
}

