// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedAgeFilter)
const selectedAgeFilterProvider = SelectedAgeFilterProvider._();

final class SelectedAgeFilterProvider
    extends $NotifierProvider<SelectedAgeFilter, HomeAgeFilter> {
  const SelectedAgeFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedAgeFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedAgeFilterHash();

  @$internal
  @override
  SelectedAgeFilter create() => SelectedAgeFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeAgeFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeAgeFilter>(value),
    );
  }
}

String _$selectedAgeFilterHash() => r'0768d8cbf413961a7c090b952605cb4b2ab0474a';

abstract class _$SelectedAgeFilter extends $Notifier<HomeAgeFilter> {
  HomeAgeFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HomeAgeFilter, HomeAgeFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeAgeFilter, HomeAgeFilter>,
              HomeAgeFilter,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(filteredBooks)
const filteredBooksProvider = FilteredBooksProvider._();

final class FilteredBooksProvider
    extends $FunctionalProvider<List<Book>, List<Book>, List<Book>>
    with $Provider<List<Book>> {
  const FilteredBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredBooksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredBooksHash();

  @$internal
  @override
  $ProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Book> create(Ref ref) {
    return filteredBooks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Book> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Book>>(value),
    );
  }
}

String _$filteredBooksHash() => r'17849b3a0ff6f8db1737560289dfd9218de2e5a7';

@ProviderFor(recommendedBooks)
const recommendedBooksProvider = RecommendedBooksProvider._();

final class RecommendedBooksProvider
    extends $FunctionalProvider<List<Book>, List<Book>, List<Book>>
    with $Provider<List<Book>> {
  const RecommendedBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendedBooksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendedBooksHash();

  @$internal
  @override
  $ProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Book> create(Ref ref) {
    return recommendedBooks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Book> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Book>>(value),
    );
  }
}

String _$recommendedBooksHash() => r'53dff7408159ea9134fc26e7b228abd074ec1b1f';

@ProviderFor(rankedBooks)
const rankedBooksProvider = RankedBooksProvider._();

final class RankedBooksProvider
    extends $FunctionalProvider<List<Book>, List<Book>, List<Book>>
    with $Provider<List<Book>> {
  const RankedBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rankedBooksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rankedBooksHash();

  @$internal
  @override
  $ProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Book> create(Ref ref) {
    return rankedBooks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Book> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Book>>(value),
    );
  }
}

String _$rankedBooksHash() => r'bdbfbe5a2ebddaf6c7e80a7fcf3d878f5166a7c9';
