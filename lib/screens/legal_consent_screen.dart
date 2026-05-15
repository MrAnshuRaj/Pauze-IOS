import 'package:flutter/material.dart';

enum LegalDocumentType { privacy, terms }

class LegalConsentFlow extends StatefulWidget {
  const LegalConsentFlow({
    super.key,
    required this.onAccepted,
  });

  final Future<void> Function() onAccepted;

  @override
  State<LegalConsentFlow> createState() => _LegalConsentFlowState();
}

class _LegalConsentFlowState extends State<LegalConsentFlow> {
  int _step = 0;
  bool _privacyChecked = false;
  bool _termsChecked = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final bool isPrivacy = _step == 0;
    final bool canConfirm = isPrivacy ? _privacyChecked : _termsChecked;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPrivacy ? 'Privacy Policy' : 'Terms & Conditions'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: <Widget>[
                _stepDot(active: _step == 0, label: 'Privacy'),
                const SizedBox(width: 8),
                _stepDot(active: _step == 1, label: 'Terms'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Text(
                isPrivacy ? _privacyPolicyText : _termsText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: <Widget>[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: isPrivacy ? _privacyChecked : _termsChecked,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (isPrivacy) {
                          _privacyChecked = checked ?? false;
                        } else {
                          _termsChecked = checked ?? false;
                        }
                      });
                    },
                    title: Text(
                      isPrivacy
                          ? 'I have read and agree to the Privacy Policy.'
                          : 'I have read and agree to the Terms & Conditions.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!canConfirm || _submitting) ? null : _onConfirm,
                      child: Text(
                        isPrivacy ? 'Confirm and Continue' : 'Confirm and Start App',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot({required bool active, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF00796B) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.onAccepted();
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    final bool privacy = type == LegalDocumentType.privacy;

    return Scaffold(
      appBar: AppBar(
        title: Text(privacy ? 'Privacy Policy' : 'Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          privacy ? _privacyPolicyText : _termsText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ),
    );
  }
}

const String _privacyPolicyText = '''
Pauze Privacy Policy
Effective date: March 2026

1. Scope
This Privacy Policy explains how Pauze handles information when you use the app on iOS and Android.

2. Data We Process
- App configuration data: selected social app labels, focus settings, and block settings.
- Usage analytics inside the app: unlock count, sessions, and duration values used to show your dashboard.
- On iOS, Screen Time / FamilyControls selections and control state are handled through Apple frameworks.

3. Data We Do Not Sell
We do not sell personal data. We do not use data brokers.

4. Where Data Is Stored
By default, Pauze stores app data locally on your device using platform storage APIs.

5. Permissions
- iOS: FamilyControls / Screen Time authorization is requested to apply shields and schedules.
- Android: Accessibility permission is requested to enforce app-blocking behavior.

6. Children
If required by your jurisdiction, parental/guardian consent must be obtained before use by minors.

7. Security
We apply reasonable technical measures for local app data handling, but no system is guaranteed to be 100% secure.

8. Your Choices
You can revoke permissions in iOS Settings / Android Settings and clear app data from device settings.

9. App Store Compliance Notes (iOS)
Pauze uses Apple’s FamilyControls/ManagedSettings APIs for digital wellbeing controls and not for advertising profiling.

10. Contact
For support or privacy requests, contact the app publisher through the support channel listed with the app release.
''';

const String _termsText = '''
Pauze Terms & Conditions
Effective date: March 2026

1. Acceptance
By confirming these Terms, you agree to use Pauze responsibly and in compliance with local law.

2. Intended Use
Pauze is a productivity and digital wellbeing tool designed to help reduce social media overuse.

3. No Guarantee
We do not guarantee uninterrupted access or specific outcomes (for example, guaranteed productivity changes).

4. User Responsibilities
- Keep your device security settings enabled.
- Use permissions only on devices/accounts you are authorized to manage.
- Do not misuse the app to violate platform policies or laws.

5. Platform Permissions
Core features depend on platform permissions (FamilyControls on iOS, Accessibility on Android). Disabling required permissions may limit functionality.

6. Limitation of Liability
To the maximum extent permitted by law, the app is provided “as is” without warranties, and liability is limited for indirect or consequential damages.

7. Changes
We may update these Terms and Privacy Policy in future app versions. Material updates should be reviewed by users.

8. Termination
You may stop using the app at any time by uninstalling it. Permissions can be revoked in device settings.

9. Apple-Specific Terms
For iOS, usage must remain consistent with Apple App Store Review Guidelines and FamilyControls intended purposes.

10. Contact
For legal/support requests, use the support contact published with the app listing.
''';
