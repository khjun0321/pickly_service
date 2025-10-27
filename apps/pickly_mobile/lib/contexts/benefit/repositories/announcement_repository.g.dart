// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 공고 Repository Provider

@ProviderFor(announcementRepository)
const announcementRepositoryProvider = AnnouncementRepositoryProvider._();

/// 공고 Repository Provider

final class AnnouncementRepositoryProvider
    extends
        $FunctionalProvider<
          AnnouncementRepository,
          AnnouncementRepository,
          AnnouncementRepository
        >
    with $Provider<AnnouncementRepository> {
  /// 공고 Repository Provider
  const AnnouncementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnnouncementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnnouncementRepository create(Ref ref) {
    return announcementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnouncementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnouncementRepository>(value),
    );
  }
}

String _$announcementRepositoryHash() =>
    r'e056cd7f6d100a6cb5c4be2157046dba97a828c8';
