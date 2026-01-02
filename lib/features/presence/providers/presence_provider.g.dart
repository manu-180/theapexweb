// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presence_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presenceNotifierHash() => r'9c5b09ada073585ca975aa350e26b3170f646d7f';

/// See also [PresenceNotifier].
@ProviderFor(PresenceNotifier)
final presenceNotifierProvider =
    AutoDisposeNotifierProvider<PresenceNotifier, List<ConnectedUser>>.internal(
  PresenceNotifier.new,
  name: r'presenceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$presenceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PresenceNotifier = AutoDisposeNotifier<List<ConnectedUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
