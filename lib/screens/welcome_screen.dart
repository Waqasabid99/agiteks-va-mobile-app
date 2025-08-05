import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;
import 'package:agiteks_va/controllers/app_ctrl.dart' as ctrl;
import 'package:agiteks_va/widgets/button.dart' as buttons;

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext ctx) => Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Image.asset(
                  'assets/agiteks.png',
                  width: 150,
                  height: 150,
                  // color: Theme.brightnessOf(ctx) == Brightness.light ? Colors.black : Colors.white,
                ),
                
                // User info section
                if (ctx.watch<ctrl.AppCtrl>().isAuthenticated) ...[
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: ctx.watch<ctrl.AppCtrl>().userPhotoURL != null
                        ? NetworkImage(ctx.watch<ctrl.AppCtrl>().userPhotoURL!)
                        : null,
                    child: ctx.watch<ctrl.AppCtrl>().userPhotoURL == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, ${ctx.watch<ctrl.AppCtrl>().userDisplayName ?? 'User'}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (ctx.watch<ctrl.AppCtrl>().userEmail != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      ctx.watch<ctrl.AppCtrl>().userEmail!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
                
                Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Built by Agiteks. Visit us at ',
                      ),
                      TextSpan(
                        text: 'Agiteks.com',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          decorationThickness: 1,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('https://agiteks.com'));
                          },
                      ),
                      const TextSpan(
                        text: '.',
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (ctx) {
                    final isProgressing = [
                      ctrl.ConnectionState.connecting,
                      ctrl.ConnectionState.connected,
                    ].contains(ctx.watch<ctrl.AppCtrl>().connectionState);
                    return buttons.Button(
                      text: isProgressing ? 'Connecting' : 'Start call',
                      isProgressing: isProgressing,
                      onPressed: () => ctx.read<ctrl.AppCtrl>().connect(),
                    );
                  },
                ),
                
                // Sign out button
                if (ctx.watch<ctrl.AppCtrl>().isAuthenticated) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => ctx.read<ctrl.AppCtrl>().signOut(),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
