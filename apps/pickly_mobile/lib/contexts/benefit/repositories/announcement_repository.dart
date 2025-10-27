import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/announcement.dart';
import '../exceptions/announcement_exception.dart';

/// 공고 데이터 Repository
class AnnouncementRepository {
  final SupabaseClient _client;

  const AnnouncementRepository(this._client);

  /// 카테고리별 공고 목록 조회
  Future<List<Announcement>> getAnnouncementsByCategory(
    String categoryId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('announcements')
          .select()
          .eq('category_id', categoryId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// 공고 상세 조회
  Future<Announcement> getAnnouncementById(String id) async {
    try {
      final response = await _client
          .from('announcements')
          .select()
          .eq('id', id)
          .single();

      return Announcement.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const AnnouncementNotFoundException();
      }
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// 공고 실시간 구독 (카테고리별)
  Stream<List<Announcement>> watchAnnouncementsByCategory(String categoryId) {
    return _client
        .from('announcements')
        .stream(primaryKey: ['id'])
        .eq('category_id', categoryId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList());
  }

  /// 공고 검색
  Future<List<Announcement>> searchAnnouncements(
    String query, {
    String? categoryId,
    int limit = 50,
  }) async {
    try {
      var queryBuilder = _client.from('announcements').select();

      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      final response = await queryBuilder
          .or('title.ilike.%$query%,summary.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// 인기 공고 조회 (조회수 기준)
  Future<List<Announcement>> getPopularAnnouncements({
    int limit = 10,
    String? categoryId,
  }) async {
    try {
      var queryBuilder = _client.from('announcements').select();

      if (categoryId != null) {
        queryBuilder = queryBuilder.eq('category_id', categoryId);
      }

      final response = await queryBuilder
          .eq('status', 'recruiting')
          .order('views_count', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AnnouncementNetworkException(e.message);
    } catch (e, stackTrace) {
      throw AnnouncementException(e.toString(), stackTrace);
    }
  }

  /// 조회수 증가
  Future<void> incrementViewCount(String announcementId) async {
    try {
      await _client.rpc('increment_announcement_view_count', params: {
        'announcement_id': announcementId,
      });
    } catch (e) {
      // 조회수 증가 실패는 무시 (사용자 경험에 영향 없음)
      print('Failed to increment view count: $e');
    }
  }
}

/// 공고 Repository Provider
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(Supabase.instance.client);
});
