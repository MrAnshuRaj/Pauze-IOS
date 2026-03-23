import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import SwiftUI
import UIKit

struct PickerSummary {
  let selectedCount: Int
  let selectedLabels: [String]
}

protocol ScreenTimeManagerProtocol: AnyObject {
  func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
  func presentPicker(from presenter: UIViewController, completion: @escaping (Result<PickerSummary, Error>) -> Void)
  func applyShields()
  func unblockTemporarily(durationMinutes: Int)
  func scheduleBlocking(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, enabled: Bool) throws
  func usageSnapshot() -> [String: Any]
}

@available(iOS 16.0, *)
final class ScreenTimeManager: ScreenTimeManagerProtocol {
  static let shared = ScreenTimeManager()

  private let authorizationCenter = AuthorizationCenter.shared
  private let managedStore = ManagedSettingsStore()
  private let deviceActivityCenter = DeviceActivityCenter()
  private let deviceActivityName = DeviceActivityName("ScrollRokDailyFocus")
  private let defaults = UserDefaults.standard

  private let selectionKey = "scrollrok.selection"
  private let labelsKey = "scrollrok.selection.labels"
  private let unlockUntilKey = "scrollrok.unlockUntil"

  private let usageUnlocksKey = "scrollrok.usage.unlocks"
  private let usageSessionsKey = "scrollrok.usage.sessions"
  private let usageSecondsKey = "scrollrok.usage.seconds"
  private let usageOpenedKey = "scrollrok.usage.opened"

  private var selection = FamilyActivitySelection()
  private var relockWorkItem: DispatchWorkItem?

  private init() {
    loadPersistedSelection()
    resumePendingRelockIfNeeded()
  }

  func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
    Task {
      do {
        try await authorizationCenter.requestAuthorization(for: .individual)
        completion(true, nil)
      } catch {
        completion(false, error)
      }
    }
  }

  func presentPicker(from presenter: UIViewController, completion: @escaping (Result<PickerSummary, Error>) -> Void) {
    let model = SelectionModel(initial: selection)

    let pickerView = FamilyPickerContainer(
      model: model,
      onCancel: { [weak presenter] in
        presenter?.dismiss(animated: true)
        let summary = PickerSummary(
          selectedCount: self.currentSelectionCount(),
          selectedLabels: self.currentReadableLabels()
        )
        completion(.success(summary))
      },
      onDone: { [weak presenter] in
        self.selection = model.selection
        self.persistSelection()
        presenter?.dismiss(animated: true)

        let summary = PickerSummary(
          selectedCount: self.currentSelectionCount(),
          selectedLabels: self.currentReadableLabels()
        )
        completion(.success(summary))
      }
    )

    let host = UIHostingController(rootView: pickerView)
    host.modalPresentationStyle = .pageSheet
    presenter.present(host, animated: true)
  }

  func applyShields() {
    if selection.applicationTokens.isEmpty,
       selection.categoryTokens.isEmpty,
       selection.webDomainTokens.isEmpty {
      clearShields()
      return
    }

    managedStore.shield.applications = selection.applicationTokens
    managedStore.shield.webDomains = selection.webDomainTokens
    managedStore.shield.applicationCategories = .specific(selection.categoryTokens)
  }

  func unblockTemporarily(durationMinutes: Int) {
    clearShields()

    let totalSeconds = max(durationMinutes, 1) * 60
    let endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
    defaults.set(endDate.timeIntervalSince1970, forKey: unlockUntilKey)

    scheduleRelock(afterSeconds: totalSeconds)
    incrementUsage(unlocks: 1, sessions: 1, seconds: totalSeconds, openedCount: currentSelectionCount())
  }

  func scheduleBlocking(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, enabled: Bool) throws {
    deviceActivityCenter.stopMonitoring(Set([deviceActivityName]))

    guard enabled else {
      return
    }

    let schedule = DeviceActivitySchedule(
      intervalStart: DateComponents(hour: clampHour(startHour), minute: clampMinute(startMinute)),
      intervalEnd: DateComponents(hour: clampHour(endHour), minute: clampMinute(endMinute)),
      repeats: true
    )

    try deviceActivityCenter.startMonitoring(deviceActivityName, during: schedule)
  }

  func usageSnapshot() -> [String: Any] {
    return [
      "unlocks": defaults.integer(forKey: usageUnlocksKey),
      "sessions": defaults.integer(forKey: usageSessionsKey),
      "secondsSpent": defaults.integer(forKey: usageSecondsKey),
      "openedCount": defaults.integer(forKey: usageOpenedKey),
    ]
  }

  private func clearShields() {
    managedStore.shield.applications = nil
    managedStore.shield.webDomains = nil
    managedStore.shield.applicationCategories = nil
  }

  private func loadPersistedSelection() {
    guard let data = defaults.data(forKey: selectionKey) else {
      return
    }
    do {
      selection = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    } catch {
      selection = FamilyActivitySelection()
    }
  }

  private func persistSelection() {
    do {
      let data = try JSONEncoder().encode(selection)
      defaults.set(data, forKey: selectionKey)
      defaults.set(currentReadableLabels(), forKey: labelsKey)
    } catch {
      defaults.removeObject(forKey: selectionKey)
    }
  }

  private func currentSelectionCount() -> Int {
    return selection.applicationTokens.count
      + selection.categoryTokens.count
      + selection.webDomainTokens.count
  }

  private func currentReadableLabels() -> [String] {
    if let stored = defaults.stringArray(forKey: labelsKey), !stored.isEmpty {
      return stored
    }

    let count = currentSelectionCount()
    if count == 0 {
      return []
    }

    let logical = [
      "Instagram",
      "Instagram Lite",
      "YouTube",
      "Facebook",
      "Snapchat",
      "LinkedIn",
    ]

    return Array(logical.prefix(min(count, logical.count)))
  }

  private func resumePendingRelockIfNeeded() {
    let timestamp = defaults.double(forKey: unlockUntilKey)
    guard timestamp > 0 else {
      return
    }

    let endDate = Date(timeIntervalSince1970: timestamp)
    if endDate <= Date() {
      applyShields()
      defaults.removeObject(forKey: unlockUntilKey)
      return
    }

    let remainingSeconds = Int(endDate.timeIntervalSinceNow)
    scheduleRelock(afterSeconds: max(remainingSeconds, 1))
  }

  private func scheduleRelock(afterSeconds seconds: Int) {
    relockWorkItem?.cancel()

    let item = DispatchWorkItem { [weak self] in
      guard let self else { return }
      self.applyShields()
      self.defaults.removeObject(forKey: self.unlockUntilKey)
    }

    relockWorkItem = item
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: item)
  }

  private func incrementUsage(unlocks: Int, sessions: Int, seconds: Int, openedCount: Int) {
    defaults.set(defaults.integer(forKey: usageUnlocksKey) + unlocks, forKey: usageUnlocksKey)
    defaults.set(defaults.integer(forKey: usageSessionsKey) + sessions, forKey: usageSessionsKey)
    defaults.set(defaults.integer(forKey: usageSecondsKey) + seconds, forKey: usageSecondsKey)
    defaults.set(defaults.integer(forKey: usageOpenedKey) + openedCount, forKey: usageOpenedKey)
  }

  private func clampHour(_ value: Int) -> Int {
    return min(max(value, 0), 23)
  }

  private func clampMinute(_ value: Int) -> Int {
    return min(max(value, 0), 59)
  }
}

@available(iOS 16.0, *)
final class SelectionModel: ObservableObject {
  @Published var selection: FamilyActivitySelection

  init(initial: FamilyActivitySelection) {
    selection = initial
  }
}

@available(iOS 16.0, *)
struct FamilyPickerContainer: View {
  @ObservedObject var model: SelectionModel
  let onCancel: () -> Void
  let onDone: () -> Void

  var body: some View {
    NavigationStack {
      FamilyActivityPicker(selection: $model.selection)
        .navigationTitle("Select Apps")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { onCancel() }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") { onDone() }
          }
        }
    }
  }
}

