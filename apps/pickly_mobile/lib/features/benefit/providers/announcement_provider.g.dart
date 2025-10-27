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
    r'fc0ffe729b782929b9bc40ce610276a7b4e1b8a8';

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
/// 캐시 무효화: keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

@ProviderFor(announcementDetail)
const announcementDetailProvider = AnnouncementDetailFamily._();

/// 공고 상세 Provider
/// 캐시 무효화: keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

final class AnnouncementDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<Announcement>,
          Announcement,
          FutureOr<Announcement>
        >
    with $FutureModifier<Announcement>, $FutureProvider<Announcement> {
  /// 공고 상세 Provider
  /// 캐시 무효화: keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch
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
    r'a4fc190d43571dcde0c2a38cdca66edede3770f8';

/// 공고 상세 Provider
/// 캐시 무효화: keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

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
  /// 캐시 무효화: keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

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
    r'519d80f930a5e561b2f3a683cb1be3590cf26ce1';

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
    r'0d1d4fe4b4e8886b6128cc84c5c7288c702e1930';

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
    r'6078b0d612485faf03334b7171e0efafd20089a3';

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

/// 공고 탭 목록 Provider (평형별/연령별)
/// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

@ProviderFor(announcementTabs)
const announcementTabsProvider = AnnouncementTabsFamily._();

/// 공고 탭 목록 Provider (평형별/연령별)
/// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

final class AnnouncementTabsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnnouncementTab>>,
          List<AnnouncementTab>,
          FutureOr<List<AnnouncementTab>>
        >
    with
        $FutureModifier<List<AnnouncementTab>>,
        $FutureProvider<List<AnnouncementTab>> {
  /// 공고 탭 목록 Provider (평형별/연령별)
  /// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch
  const AnnouncementTabsProvider._({
    required AnnouncementTabsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'announcementTabsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$announcementTabsHash();

  @override
  String toString() {
    return r'announcementTabsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AnnouncementTab>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AnnouncementTab>> create(Ref ref) {
    final argument = this.argument as String;
    return announcementTabs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementTabsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$announcementTabsHash() => r'f732c55369805516529e8a2ed3b804d8308ba101';

/// 공고 탭 목록 Provider (평형별/연령별)
/// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

final class AnnouncementTabsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<AnnouncementTab>>, String> {
  const AnnouncementTabsFamily._()
    : super(
        retry: null,
        name: r'announcementTabsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 공고 탭 목록 Provider (평형별/연령별)
  /// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

  AnnouncementTabsProvider call(String announcementId) =>
      AnnouncementTabsProvider._(argument: announcementId, from: this);

  @override
  String toString() => r'announcementTabsProvider';
}

/// 공고 섹션 목록 Provider (모듈식)
/// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

@ProviderFor(announcementSections)
const announcementSectionsProvider = AnnouncementSectionsFamily._();

/// 공고 섹션 목록 Provider (모듈식)
/// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

final class AnnouncementSectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AnnouncementSection>>,
          List<AnnouncementSection>,
          FutureOr<List<AnnouncementSection>>
        >
    with
        $FutureModifier<List<AnnouncementSection>>,
        $FutureProvider<List<AnnouncementSection>> {
  /// 공고 섹션 목록 Provider (모듈식)
  /// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch
  const AnnouncementSectionsProvider._({
    required AnnouncementSectionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'announcementSectionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$announcementSectionsHash();

  @override
  String toString() {
    return r'announcementSectionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<AnnouncementSection>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<AnnouncementSection>> create(Ref ref) {
    final argument = this.argument as String;
    return announcementSections(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AnnouncementSectionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$announcementSectionsHash() =>
    r'119823dcdf103056810fbf4a87d3ec0fba488f3e';

/// 공고 섹션 목록 Provider (모듈식)
/// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

final class AnnouncementSectionsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<AnnouncementSection>>, String> {
  const AnnouncementSectionsFamily._()
    : super(
        retry: null,
        name: r'announcementSectionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 공고 섹션 목록 Provider (모듈식)
  /// keepAlive = false로 설정하여 화면 진입 시마다 새로 fetch

  AnnouncementSectionsProvider call(String announcementId) =>
      AnnouncementSectionsProvider._(argument: announcementId, from: this);

  @override
  String toString() => r'announcementSectionsProvider';
}
