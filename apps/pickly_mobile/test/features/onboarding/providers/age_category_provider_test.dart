import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/core/models/age_category.dart';
import 'package:pickly_mobile/core/services/supabase_service.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';

// Generate mocks for Supabase dependencies
@GenerateNiceMocks([
  MockSpec<SupabaseService>(),
  MockSpec<SupabaseClient>(),
  MockSpec<PostgrestQueryBuilder>(),
  MockSpec<PostgrestFilterBuilder>(),
  MockSpec<PostgrestTransformBuilder>(),
  MockSpec<RealtimeChannel>(),
])
import 'age_category_provider_test.mocks.dart';

void main() {
  late MockSupabaseService mockSupabaseService;
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;
  late MockRealtimeChannel mockChannel;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    mockChannel = MockRealtimeChannel();

    // Default mock behavior
    when(mockSupabaseService.client).thenReturn(mockSupabaseClient);
  });

  group('AgeCategoryNotifier Tests', () {
    group('build() - Initial Data Fetching', () {
      test('should fetch categories successfully on initialization', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'cat-1',
            'title': '청년',
            'description': '(만 19세~39세) 대학생, 취업준비생, 직장인',
            'icon_component': 'young_man',
            'icon_url': 'assets/icons/age_categories/young_man.svg',
            'min_age': 19,
            'max_age': 39,
            'sort_order': 1,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
          {
            'id': 'cat-2',
            'title': '신혼부부·예비부부',
            'description': '결혼 예정 또는 결혼 7년이내',
            'icon_component': 'bride',
            'icon_url': 'assets/icons/age_categories/bride.svg',
            'min_age': null,
            'max_age': null,
            'sort_order': 2,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Act
        final result = await container.read(ageCategoryProvider.future);

        // Assert
        expect(result, isA<List<AgeCategory>>());
        expect(result.length, 2);
        expect(result[0].title, '청년');
        expect(result[1].title, '신혼부부·예비부부');

        verify(mockSupabaseClient.from('age_categories')).called(1);
        verify(mockFilterBuilder.eq('is_active', true)).called(1);
        verify(mockTransformBuilder.order('sort_order', ascending: true)).called(1);

        container.dispose();
      });

      test('should handle empty categories list', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => []);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Act
        final result = await container.read(ageCategoryProvider.future);

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<AgeCategory>>());

        container.dispose();
      });

      test('should throw AgeCategoryException on database error', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenThrow(PostgrestException(message: 'Connection error'));

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Act & Assert
        expect(
          () => container.read(ageCategoryProvider.future),
          throwsA(isA<AgeCategoryException>()),
        );

        container.dispose();
      });

      test('should filter only active categories', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'cat-active',
            'title': '청년',
            'description': '활성 카테고리',
            'icon_component': 'young_man',
            'icon_url': null,
            'min_age': 19,
            'max_age': 39,
            'sort_order': 1,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Act
        await container.read(ageCategoryProvider.future);

        // Assert
        verify(mockFilterBuilder.eq('is_active', true)).called(1);

        container.dispose();
      });
    });

    group('refresh() - Manual Refresh', () {
      test('should reload categories when refresh is called', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'cat-refresh',
            'title': 'Refreshed',
            'description': 'Test',
            'icon_component': 'test',
            'icon_url': null,
            'min_age': 20,
            'max_age': 30,
            'sort_order': 1,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Act - Initial load
        await container.read(ageCategoryProvider.future);

        // Refresh
        await container.read(ageCategoryProvider.notifier).refresh();

        final result = await container.read(ageCategoryProvider.future);

        // Assert - Should call database twice (initial + refresh)
        verify(mockSupabaseClient.from('age_categories')).called(2);
        expect(result.length, 1);
        expect(result[0].title, 'Refreshed');

        container.dispose();
      });
    });

    group('retry() - Error Retry', () {
      test('should retry after error', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);

        var callCount = 0;
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return [
            {
              'id': 'cat-retry',
              'title': 'Retry Success',
              'description': 'Test',
              'icon_component': 'test',
              'icon_url': null,
              'min_age': 20,
              'max_age': 30,
              'sort_order': 1,
              'is_active': true,
              'created_at': '2024-01-01T00:00:00Z',
              'updated_at': '2024-01-01T00:00:00Z',
            },
          ];
        });

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Act - First call fails
        try {
          await container.read(ageCategoryProvider.future);
        } catch (_) {}

        // Retry
        await container.read(ageCategoryProvider.notifier).retry();

        final result = await container.read(ageCategoryProvider.future);

        // Assert
        expect(result.length, 1);
        expect(result[0].title, 'Retry Success');

        container.dispose();
      });
    });
  });

  group('Computed Providers Tests', () {
    group('ageCategoriesListProvider', () {
      test('should return categories when data is loaded', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'cat-1',
            'title': 'Test Category',
            'description': 'Test',
            'icon_component': 'test',
            'icon_url': null,
            'min_age': 20,
            'max_age': 30,
            'sort_order': 1,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Wait for provider to load
        await container.read(ageCategoryProvider.future);

        // Act
        final result = container.read(ageCategoriesListProvider);

        // Assert
        expect(result, isA<List<AgeCategory>>());
        expect(result.length, 1);
        expect(result[0].title, 'Test Category');

        container.dispose();
      });

      test('should return empty list when loading', () {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => Future.delayed(
                  const Duration(seconds: 1),
                  () => [],
                ));

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Act - Don't wait for future
        final result = container.read(ageCategoriesListProvider);

        // Assert
        expect(result, isEmpty);

        container.dispose();
      });

      test('should return empty list on error', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenThrow(Exception('Error'));

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Wait for error
        try {
          await container.read(ageCategoryProvider.future);
        } catch (_) {}

        // Act
        final result = container.read(ageCategoriesListProvider);

        // Assert
        expect(result, isEmpty);

        container.dispose();
      });
    });

    group('ageCategoriesLoadingProvider', () {
      test('should return true when loading', () {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => Future.delayed(
                  const Duration(seconds: 1),
                  () => [],
                ));

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Act - Don't wait
        final result = container.read(ageCategoriesLoadingProvider);

        // Assert
        expect(result, isTrue);

        container.dispose();
      });

      test('should return false when loaded', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => []);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Wait for load
        await container.read(ageCategoryProvider.future);

        // Act
        final result = container.read(ageCategoriesLoadingProvider);

        // Assert
        expect(result, isFalse);

        container.dispose();
      });
    });

    group('ageCategoriesErrorProvider', () {
      test('should return null when no error', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => []);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Wait for load
        await container.read(ageCategoryProvider.future);

        // Act
        final result = container.read(ageCategoriesErrorProvider);

        // Assert
        expect(result, isNull);

        container.dispose();
      });

      test('should return error when fetch fails', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenThrow(AgeCategoryException('Test error'));

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Wait for error
        try {
          await container.read(ageCategoryProvider.future);
        } catch (_) {}

        // Act
        final result = container.read(ageCategoriesErrorProvider);

        // Assert
        expect(result, isNotNull);
        expect(result, isA<AgeCategoryException>());

        container.dispose();
      });
    });

    group('ageCategoryByIdProvider', () {
      test('should return category when ID exists', () async {
        // Arrange
        final mockResponse = [
          {
            'id': 'test-id-123',
            'title': 'Found Category',
            'description': 'Test',
            'icon_component': 'test',
            'icon_url': null,
            'min_age': 20,
            'max_age': 30,
            'sort_order': 1,
            'is_active': true,
            'created_at': '2024-01-01T00:00:00Z',
            'updated_at': '2024-01-01T00:00:00Z',
          },
        ];

        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => mockResponse);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Wait for load
        await container.read(ageCategoryProvider.future);

        // Act
        final result = container.read(ageCategoryByIdProvider('test-id-123'));

        // Assert
        expect(result, isNotNull);
        expect(result?.title, 'Found Category');

        container.dispose();
      });

      test('should return null when ID does not exist', () async {
        // Arrange
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => []);

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        final container = ProviderContainer(
          overrides: [
            supabaseServiceProvider.overrideWithValue(mockSupabaseService),
          ],
        );

        // Wait for load
        await container.read(ageCategoryProvider.future);

        // Act
        final result = container.read(ageCategoryByIdProvider('non-existent-id'));

        // Assert
        expect(result, isNull);

        container.dispose();
      });
    });
  });

  group('AgeCategoryException Tests', () {
    test('should format exception message correctly', () {
      // Arrange
      const message = 'Test error message';
      const cause = 'Cause details';

      // Act
      final exception = AgeCategoryException(message, cause);

      // Assert
      expect(exception.message, message);
      expect(exception.cause, cause);
      expect(
        exception.toString(),
        'AgeCategoryException: $message\nCaused by: $cause',
      );
    });

    test('should handle exception without cause', () {
      // Arrange
      const message = 'Test error message';

      // Act
      final exception = AgeCategoryException(message);

      // Assert
      expect(exception.message, message);
      expect(exception.cause, isNull);
      expect(exception.toString(), 'AgeCategoryException: $message');
    });
  });
}
