// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentsNotifierHash() => r'5553f14cc40b887f92c1e6e598a13ba2ad2db414';

/// Provider que gestiona la lógica de la sección de comentarios.
///
/// Copied from [CommentsNotifier].
@ProviderFor(CommentsNotifier)
final commentsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CommentsNotifier, List<Comment>>.internal(
  CommentsNotifier.new,
  name: r'commentsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commentsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CommentsNotifier = AutoDisposeAsyncNotifier<List<Comment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
