// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 카테고리별 공고 목록 Provider

@ProviderFor(announcementsByCategory)
const announcementsByCategoryProvider = AnnouncementsByCategoryFamily._();

/// 카테고리별 공고 목록 Provider

final class AnnouncementsByCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Announcement>>,
          List<Announcement>,
          FutureOr<List<Announcement>>
        >
    with
        $FutureModifier<List<Announcement>>,
        $FutureProvider<List<Announcement>> {
  /// 카테고리별 공고 목록 Provider
  const AnnouncementsByCategoryProvider._({
    required AnnouncementsByCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'announcementsByCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$announcementsByCategoryHash();

  @override
  String toString() {
    return r'announcementsByCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Announcement>> create(Ref ref) {
    final argument = this.argument as String;
    return announcementsByCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementsByCategoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$announcementsByCategoryHash() =>
    r'c5c9c2bb22e286622a46faeb3474b737201db7c4';

/// 카테고리별 공고 목록 Provider

final class AnnouncementsByCategoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Announcement>>, String> {
  const AnnouncementsByCategoryFamily._()
    : super(
        retry: null,
        name: r'announcementsByCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 카테고리별 공고 목록 Provider

  AnnouncementsByCategoryProvider call(String categoryId) =>
      AnnouncementsByCategoryProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'announcementsByCategoryProvider';
}

/// 공고 상세 Provider

@ProviderFor(announcementDetail)
const announcementDetailProvider = AnnouncementDetailFamily._();

/// 공고 상세 Provider

final class AnnouncementDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<Announcement>,
          Announcement,
          FutureOr<Announcement>
        >
    with $FutureModifier<Announcement>, $FutureProvider<Announcement> {
  /// 공고 상세 Provider
  const AnnouncementDetailProvider._({
    required AnnouncementDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'announcementDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$announcementDetailHash();

  @override
  String toString() {
    return r'announcementDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Announcement> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Announcement> create(Ref ref) {
    final argument = this.argument as String;
    return announcementDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$announcementDetailHash() =>
    r'99df2895a661059a41e967d357181751dc978749';

/// 공고 상세 Provider

final class AnnouncementDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Announcement>, String> {
  const AnnouncementDetailFamily._()
    : super(
        retry: null,
        name: r'announcementDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 공고 상세 Provider

  AnnouncementDetailProvider call(String announcementId) =>
      AnnouncementDetailProvider._(argument: announcementId, from: this);

  @override
  String toString() => r'announcementDetailProvider';
}

/// 공고 실시간 스트림 Provider

@ProviderFor(announcementsStream)
const announcementsStreamProvider = AnnouncementsStreamFamily._();

/// 공고 실시간 스트림 Provider

final class AnnouncementsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Announcement>>,
          List<Announcement>,
          Stream<List<Announcement>>
        >
    with
        $FutureModifier<List<Announcement>>,
        $StreamProvider<List<Announcement>> {
  /// 공고 실시간 스트림 Provider
  const AnnouncementsStreamProvider._({
    required AnnouncementsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'announcementsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$announcementsStreamHash();

  @override
  String toString() {
    return r'announcementsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Announcement>> create(Ref ref) {
    final argument = this.argument as String;
    return announcementsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$announcementsStreamHash() =>
    r'10fa2c5ed093c2ab2c5bf5cfb5002c42710cc1a0';

/// 공고 실시간 스트림 Provider

final class AnnouncementsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Announcement>>, String> {
  const AnnouncementsStreamFamily._()
    : super(
        retry: null,
        name: r'announcementsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 공고 실시간 스트림 Provider

  AnnouncementsStreamProvider call(String categoryId) =>
      AnnouncementsStreamProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'announcementsStreamProvider';
}

/// 공고 검색 Provider

@ProviderFor(searchAnnouncements)
const searchAnnouncementsProvider = SearchAnnouncementsFamily._();

/// 공고 검색 Provider

final class SearchAnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Announcement>>,
          List<Announcement>,
          FutureOr<List<Announcement>>
        >
    with
        $FutureModifier<List<Announcement>>,
        $FutureProvider<List<Announcement>> {
  /// 공고 검색 Provider
  const SearchAnnouncementsProvider._({
    required SearchAnnouncementsFamily super.from,
    required ({String query, String? categoryId}) super.argument,
  }) : super(
         retry: null,
         name: r'searchAnnouncementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchAnnouncementsHash();

  @override
  String toString() {
    return r'searchAnnouncementsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Announcement>> create(Ref ref) {
    final argument = this.argument as ({String query, String? categoryId});
    return searchAnnouncements(
      ref,
      query: argument.query,
      categoryId: argument.categoryId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchAnnouncementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchAnnouncementsHash() =>
    r'f0e94364f1d86b625021d4809506e1faa27447ac';

/// 공고 검색 Provider

final class SearchAnnouncementsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Announcement>>,
          ({String query, String? categoryId})
        > {
  const SearchAnnouncementsFamily._()
    : super(
        retry: null,
        name: r'searchAnnouncementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 공고 검색 Provider

  SearchAnnouncementsProvider call({
    required String query,
    String? categoryId,
  }) => SearchAnnouncementsProvider._(
    argument: (query: query, categoryId: categoryId),
    from: this,
  );

  @override
  String toString() => r'searchAnnouncementsProvider';
}

/// 인기 공고 Provider

@ProviderFor(popularAnnouncements)
const popularAnnouncementsProvider = PopularAnnouncementsFamily._();

/// 인기 공고 Provider

final class PopularAnnouncementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Announcement>>,
          List<Announcement>,
          FutureOr<List<Announcement>>
        >
    with
        $FutureModifier<List<Announcement>>,
        $FutureProvider<List<Announcement>> {
  /// 인기 공고 Provider
  const PopularAnnouncementsProvider._({
    required PopularAnnouncementsFamily super.from,
    required ({String? categoryId, int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'popularAnnouncementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$popularAnnouncementsHash();

  @override
  String toString() {
    return r'popularAnnouncementsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Announcement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Announcement>> create(Ref ref) {
    final argument = this.argument as ({String? categoryId, int limit});
    return popularAnnouncements(
      ref,
      categoryId: argument.categoryId,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PopularAnnouncementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$popularAnnouncementsHash() =>
    r'75844dc11d85b1a52e5df6aa4d3e0d45c7e9f132';

/// 인기 공고 Provider

final class PopularAnnouncementsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Announcement>>,
          ({String? categoryId, int limit})
        > {
  const PopularAnnouncementsFamily._()
    : super(
        retry: null,
        name: r'popularAnnouncementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 인기 공고 Provider

  PopularAnnouncementsProvider call({String? categoryId, int limit = 10}) =>
      PopularAnnouncementsProvider._(
        argument: (categoryId: categoryId, limit: limit),
        from: this,
      );

  @override
  String toString() => r'popularAnnouncementsProvider';
}
