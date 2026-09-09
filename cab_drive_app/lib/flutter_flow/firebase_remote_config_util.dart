/// Локальный конфиг приложения (замена Firebase Remote Config).
/// PDF пока по legacy URL; позже можно перенести на свой files/.
const Map<String, String> _kAppConfigStrings = {
  'poll':
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/политика_конфеденциальности_приложение.pdf?alt=media&token=061471ea-ed01-4bf8-87b4-3693a45391b8',
  'usl':
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/условия%20использования.pdf?alt=media&token=dc68fba9-2d07-4d19-8732-2e5836391528',
};

Future initializeFirebaseRemoteConfig() async {
  // no-op: конфиг локальный, без Google Remote Config
}

String getRemoteConfigString(String key) => _kAppConfigStrings[key] ?? '';

bool getRemoteConfigBool(String key) => false;

int getRemoteConfigInt(String key) => 0;

double getRemoteConfigDouble(String key) => 0.0;
