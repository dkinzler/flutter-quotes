import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_sample/quote/provider.dart';
import 'package:flutter_sample/quote/quote.dart';
import 'package:flutter_sample/explore/random_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockQuoteProvider extends Mock implements QuoteProvider {}

void main() {
  group('RandomCubit', () {
    late QuoteProvider quoteProvider;

    setUp(() {
      quoteProvider = MockQuoteProvider();
    });

    blocTest<RandomCubit, RandomState>(
      'loading quotes fails',
      build: () => RandomCubit(
        quoteProvider: quoteProvider,
      ),
      setUp: () {
        when(() => quoteProvider.random(any())).thenThrow(Exception());
      },
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await c.loadMore();
      },
      verify: (c) {
        verify(() => quoteProvider.random(any())).called(1);
      },
      expect: () => [
        const RandomState(
          status: LoadingStatus.loading,
          quote: null,
        ),
        const RandomState(
          status: LoadingStatus.error,
          quote: null,
        )
      ],
    );

    var exampleQuotes = <Quote>[
      for (int i = 0; i < 10; i++)
        Quote(
          text: 'Quote $i',
          author: 'Author',
          source: 'test',
          sourceId: '$i',
        )
    ];

    blocTest<RandomCubit, RandomState>(
      'loading quotes and moving to next quote works',
      build: () => RandomCubit(
        quoteProvider: quoteProvider,
      ),
      setUp: () {
        when(() => quoteProvider.random(any()))
            .thenAnswer((_) async => exampleQuotes);
      },
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await c.loadMore();
        c.next();
        c.next();
        c.next();
      },
      verify: (c) {
        verify(() => quoteProvider.random(any())).called(1);
      },
      expect: () => [
        const RandomState(
          status: LoadingStatus.loading,
          quote: null,
        ),
        const RandomState(
          status: LoadingStatus.idle,
          quote: null,
        ),
        RandomState(
          status: LoadingStatus.idle,
          quote: exampleQuotes[0],
        ),
        RandomState(
          status: LoadingStatus.idle,
          quote: exampleQuotes[1],
        ),
        RandomState(
          status: LoadingStatus.idle,
          quote: exampleQuotes[2],
        ),
        RandomState(
          status: LoadingStatus.idle,
          quote: exampleQuotes[3],
        ),
      ],
    );

    blocTest<RandomCubit, RandomState>(
      'more quotes will be loaded when cache runs out',
      build: () => RandomCubit(
        quoteProvider: quoteProvider,
      ),
      setUp: () {
        when(() => quoteProvider.random(any()))
            .thenAnswer((_) async => exampleQuotes);
      },
      wait: const Duration(milliseconds: 10),
      act: (c) async {
        await c.loadMore();
        when(() => quoteProvider.random(any()))
            .thenAnswer((_) async => exampleQuotes);
        for (int i = 0; i < 7; i++) {
          c.next();
        }
      },
      verify: (c) {
        verify(() => quoteProvider.random(any())).called(2);
      },
      expect: () => [
        const RandomState(
          status: LoadingStatus.loading,
          quote: null,
        ),
        const RandomState(
          status: LoadingStatus.idle,
          quote: null,
        ),
        for (int i = 0; i < 10; i++) isA<RandomState>(),
      ],
    );
  });
}
