// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'benefit_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Benefit Repository Provider

@ProviderFor(benefitRepository)
const benefitRepositoryProvider = BenefitRepositoryProvider._();

/// Benefit Repository Provider

final class BenefitRepositoryProvider
    extends
        $FunctionalProvider<
          BenefitRepository,
          BenefitRepository,
          BenefitRepository
        >
    with $Provider<BenefitRepository> {
  /// Benefit Repository Provider
  const BenefitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'benefitRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$benefitRepositoryHash();

  @$internal
  @override
  $ProviderElement<BenefitRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BenefitRepository create(Ref ref) {
    return benefitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BenefitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BenefitRepository>(value),
    );
  }
}

String _$benefitRepositoryHash() => r'bb29d0983b8ba94f072726b44f136a04856b70d2';
