// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(booksRepository)
const booksRepositoryProvider = BooksRepositoryProvider._();

final class BooksRepositoryProvider
    extends
        $FunctionalProvider<BooksRepository, BooksRepository, BooksRepository>
    with $Provider<BooksRepository> {
  const BooksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'booksRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$booksRepositoryHash();

  @$internal
  @override
  $ProviderElement<BooksRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BooksRepository create(Ref ref) {
    return booksRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BooksRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BooksRepository>(value),
    );
  }
}

String _$booksRepositoryHash() => r'82de27b59ef6bbcb0c06eca6b0a19a3dd293adc6';

@ProviderFor(books)
const booksProvider = BooksProvider._();

final class BooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          FutureOr<List<Book>>
        >
    with $FutureModifier<List<Book>>, $FutureProvider<List<Book>> {
  const BooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'booksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$booksHash();

  @$internal
  @override
  $FutureProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Book>> create(Ref ref) {
    return books(ref);
  }
}

String _$booksHash() => r'8fb9c1d97ca3dde66598cf5c3d96fcd07fc6f649';
