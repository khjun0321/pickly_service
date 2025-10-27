import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/lh_repository.dart';

final lhRepositoryProvider = Provider((ref) => LhRepository());

/// LH API 동기화 상태
final lhSyncProvider =
    FutureProvider.family<int, int>((ref, numOfRows) async {
  final repository = ref.read(lhRepositoryProvider);
  return await repository.syncAll(numOfRows: numOfRows);
});
