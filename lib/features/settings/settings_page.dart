import 'package:flutter/material.dart';

import '../../core/settings/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  final ThemeController? themeController;

  const SettingsPage({super.key, this.themeController});

  @override
  Widget build(BuildContext context) {
    final controller = themeController ?? ThemeController.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Görünüm',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uygulamanın görünüm temasını seçin. Tercihiniz uygulama '
                  'yeniden başlatıldığında korunur.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    return RadioGroup<ThemeMode>(
                      groupValue: controller.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setThemeMode(value);
                        }
                      },
                      child: Card(
                        child: Column(
                          children: const [
                            RadioListTile<ThemeMode>(
                              value: ThemeMode.system,
                              title: Text('Sistem'),
                              subtitle: Text(
                                'Windows görünüm ayarını kullanır.',
                              ),
                              secondary: Icon(Icons.computer_outlined),
                            ),
                            Divider(height: 1),
                            RadioListTile<ThemeMode>(
                              value: ThemeMode.light,
                              title: Text('Açık'),
                              subtitle: Text('Açık temayı kullanır.'),
                              secondary: Icon(Icons.light_mode_outlined),
                            ),
                            Divider(height: 1),
                            RadioListTile<ThemeMode>(
                              value: ThemeMode.dark,
                              title: Text('Koyu'),
                              subtitle: Text('Koyu temayı kullanır.'),
                              secondary: Icon(Icons.dark_mode_outlined),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
