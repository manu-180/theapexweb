// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$dynamicThemeHash() => r'e4da4703ff518845ff668d5e2ab9d61ec4b99b17';

/// See also [DynamicTheme].
@ProviderFor(DynamicTheme)
final dynamicThemeProvider =
    AutoDisposeNotifierProvider<DynamicTheme, AppThemeConfig>.internal(
  DynamicTheme.new,
  name: r'dynamicThemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dynamicThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DynamicTheme = AutoDisposeNotifier<AppThemeConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
