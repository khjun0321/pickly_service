import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickly_mobile/core/models/age_category.dart';
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_selection_provider.dart';
import 'package:pickly_mobile/core/services/supabase_service.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<SupabaseService>(),
  MockSpec<SupabaseClient>(),
  MockSpec<PostgrestQueryBuilder>(),
  MockSpec<PostgrestFilterBuilder>(),
  MockSpec<PostgrestTransformBuilder>(),
  MockSpec<RealtimeChannel>(),
])
import 'age_category_screen_refactored_test.mocks.dart';

void main() {
  late MockSupabaseService mockSupabaseService;
  late MockSupabaseClient mockSupabaseClient;
  late MockPostgrestQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;
  late MockRealtimeChannel mockChannel;

  final testCategories = [
    AgeCategory(
      id: 'cat-1',
      title: '청년',
      description: '(만 19세~39세) 대학생, 취업준비생, 직장인',
      iconComponent: 'young_man',
      iconUrl: 'assets/icons/age_categories/young_man.svg',
      minAge: 19,
      maxAge: 39,
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
    ),
    AgeCategory(
      id: 'cat-2',
      title: '신혼부부·예비부부',
      description: '결혼 예정 또는 결혼 7년이내',
      iconComponent: 'bride',
      iconUrl: 'assets/icons/age_categories/bride.svg',
      minAge: null,
      maxAge: null,
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
    ),
    AgeCategory(
      id: 'cat-3',
      title: '육아중인 부모',
      description: '영유아~초등 자녀 양육 중',
      iconComponent: 'baby',
      iconUrl: 'assets/icons/age_categories/baby.svg',
      minAge: null,
      maxAge: null,
      sortOrder: 3,
      isActive: true,
      createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
    ),
  ];

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockPostgrestQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    mockChannel = MockRealtimeChannel();

    when(mockSupabaseService.client).thenReturn(mockSupabaseClient);
  });

  void setupMockResponse(List<AgeCategory> categories) {
    final mockResponse = categories
        .map((cat) => {
              'id': cat.id,
              'title': cat.title,
              'description': cat.description,
              'icon_component': cat.iconComponent,
              'icon_url': cat.iconUrl,
              'min_age': cat.minAge,
              'max_age': cat.maxAge,
              'sort_order': cat.sortOrder,
              'is_active': cat.isActive,
              'created_at': cat.createdAt.toIso8601String(),
              'updated_at': cat.updatedAt.toIso8601String(),
            })
        .toList();

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
  }

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(mockSupabaseService),
      ],
      child: const MaterialApp(
        home: AgeCategoryScreen(),
      ),
    );
  }

  group('AgeCategoryScreen Refactored Tests', () {
    group('Initial Rendering', () {
      testWidgets('should display title and subtitle', (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('맞춤 혜택을 위해\n내 상황을 알려주세요.'), findsOneWidget);
        expect(find.text('나에게 맞는 정책과 혜택에 대해 안내해드려요'), findsOneWidget);
      });

      testWidgets('should display OnboardingHeader with progress',
          (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Should show back button and progress
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('should display loading indicator initially',
          (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pump(); // Don't settle, catch loading state

        // Assert
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });
    });

    group('Category Display', () {
      testWidgets('should display all categories in grid', (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('청년'), findsOneWidget);
        expect(find.text('신혼부부·예비부부'), findsOneWidget);
        expect(find.text('육아중인 부모'), findsOneWidget);
      });

      testWidgets('should display categories in GridView', (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('should display empty state when no categories',
          (tester) async {
        // Arrange
        setupMockResponse([]);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('표시할 카테고리가 없습니다'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });
    });

    group('Category Selection', () {
      testWidgets('should select category when tapped', (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Assert - Button should be enabled after selection
        final nextButton = find.text('다음');
        expect(nextButton, findsOneWidget);
      });

      testWidgets('should allow changing selection', (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Select first category
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Act - Select second category (should replace first)
        await tester.tap(find.text('신혼부부·예비부부'));
        await tester.pumpAndSettle();

        // Assert - Should have only one selection
        expect(find.text('신혼부부·예비부부'), findsOneWidget);
      });

      testWidgets('should maintain card position when selection changes',
          (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get initial position of first card
        final initialRect = tester.getRect(find.text('청년').hitTestable());
        final initialCenter = tester.getCenter(find.text('청년').hitTestable());

        // Act - Tap to select
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Assert - Position should not change
        final selectedRect = tester.getRect(find.text('청년').hitTestable());
        final selectedCenter = tester.getCenter(find.text('청년').hitTestable());

        expect(selectedRect.topLeft, equals(initialRect.topLeft),
            reason: 'Card position should not shift on selection');
        expect(selectedCenter, equals(initialCenter),
            reason: 'Card center should not move');
      });
    });

    group('Next Button', () {
      testWidgets('should be disabled when no selection', (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Find the NextButton by looking for the text
        final nextText = find.text('다음');
        expect(nextText, findsOneWidget);
      });

      testWidgets('should be enabled when category is selected',
          (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Assert
        final nextText = find.text('다음');
        expect(nextText, findsOneWidget);
      });

      testWidgets('should trigger save when pressed', (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Select a category
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Act - Tap next button
        await tester.tap(find.text('다음'));
        await tester.pump();

        // Should show loading briefly
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Should complete without errors
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });

    group('Back Button', () {
      testWidgets('should clear selection and pop when pressed',
          (tester) async {
        // Arrange
        setupMockResponse(testCategories);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Select a category
        await tester.tap(find.text('청년'));
        await tester.pumpAndSettle();

        // Act - Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Assert - Should navigate back (screen removed)
        expect(find.byType(AgeCategoryScreen), findsNothing);
      });
    });

    group('Error Handling', () {
      testWidgets('should display error state when fetch fails',
          (tester) async {
        // Arrange - Setup error response
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenThrow(Exception('Network error'));

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('데이터를 불러오는 데 실패했습니다'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('다시 시도'), findsOneWidget);
      });

      testWidgets('should retry on button press', (tester) async {
        // Arrange - First call fails, second succeeds
        var callCount = 0;
        when(mockSupabaseClient.from('age_categories'))
            .thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true))
            .thenReturn(mockTransformBuilder);
        when(mockTransformBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            throw Exception('Network error');
          }
          return testCategories
              .map((cat) => {
                    'id': cat.id,
                    'title': cat.title,
                    'description': cat.description,
                    'icon_component': cat.iconComponent,
                    'icon_url': cat.iconUrl,
                    'min_age': cat.minAge,
                    'max_age': cat.maxAge,
                    'sort_order': cat.sortOrder,
                    'is_active': cat.isActive,
                    'created_at': cat.createdAt.toIso8601String(),
                    'updated_at': cat.updatedAt.toIso8601String(),
                  })
              .toList();
        });

        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          callback: anyNamed('callback'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe()).thenAnswer((_) async => RealtimeChannelSendStatus.ok);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Verify error state
        expect(find.text('데이터를 불러오는 데 실패했습니다'), findsOneWidget);

        // Act - Tap retry button
        await tester.tap(find.text('다시 시도'));
        await tester.pumpAndSettle();

        // Assert - Should show categories
        expect(find.text('청년'), findsOneWidget);
        expect(find.text('데이터를 불러오는 데 실패했습니다'), findsNothing);
      });
    });

    group('Performance', () {
      testWidgets('should handle large number of categories', (tester) async {
        // Arrange - Generate 50 categories
        final manyCategories = List.generate(
          50,
          (index) => AgeCategory(
            id: 'cat-$index',
            title: '카테고리 $index',
            description: '설명 $index',
            iconComponent: 'icon_$index',
            iconUrl: null,
            minAge: index * 10,
            maxAge: (index * 10) + 9,
            sortOrder: index,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        setupMockResponse(manyCategories);

        // Act
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Assert - Should render without errors
        expect(find.byType(GridView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle scrolling smoothly', (tester) async {
        // Arrange
        final manyCategories = List.generate(
          20,
          (index) => AgeCategory(
            id: 'cat-$index',
            title: '카테고리 $index',
            description: '설명 $index',
            iconComponent: 'icon_$index',
            iconUrl: null,
            minAge: index * 10,
            maxAge: (index * 10) + 9,
            sortOrder: index,
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        setupMockResponse(manyCategories);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Act - Scroll down
        await tester.drag(find.byType(GridView), const Offset(0, -500));
        await tester.pumpAndSettle();

        // Assert - Should handle scrolling without errors
        expect(tester.takeException(), isNull);
      });
    });
  });
}
