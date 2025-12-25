// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'bb20a0e4cb8791d8e1de93afc6fbb890b531afe2';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$currentAppThemeConfigHash() =>
    r'88f97e413458d4fae409b5a4c41a22d7d5b89435';

/// See also [currentAppThemeConfig].
@ProviderFor(currentAppThemeConfig)
final currentAppThemeConfigProvider =
    AutoDisposeProvider<AppThemeConfig>.internal(
  currentAppThemeConfig,
  name: r'currentAppThemeConfigProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAppThemeConfigHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentAppThemeConfigRef = AutoDisposeProviderRef<AppThemeConfig>;
String _$lightThemeHash() => r'42eb8c162fd06a889e939b6e7fe6a33504f85d13';

/// See also [lightTheme].
@ProviderFor(lightTheme)
final lightThemeProvider = AutoDisposeProvider<ThemeData>.internal(
  lightTheme,
  name: r'lightThemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$lightThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LightThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$darkThemeHash() => r'efdb8c5eea4dc04c29a118046d99f2f275d5b78a';

/// See also [darkTheme].
@ProviderFor(darkTheme)
final darkThemeProvider = AutoDisposeProvider<ThemeData>.internal(
  darkTheme,
  name: r'darkThemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$darkThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DarkThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$dynamicThemeHash() => r'a745f48d0330a3114dae3173e44e09c10b808662';

/// See also [DynamicTheme].
@ProviderFor(DynamicTheme)
final dynamicThemeProvider =
    NotifierProvider<DynamicTheme, AppThemeConfig>.internal(
  DynamicTheme.new,
  name: r'dynamicThemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dynamicThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DynamicTheme = Notifier<AppThemeConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
