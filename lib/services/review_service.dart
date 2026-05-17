import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  final _supabase = Supabase.instance.client;

  Future<void> enviarResena({
    required String placeId,
    required int rating,
    required String comment,
  }) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    await _supabase.from('reviews').insert({
      'place_id': placeId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<List<Map<String, dynamic>>> obtenerResenas(String placeId) async {
    final response = await _supabase
        .from('reviews')
        .select('*, profiles(username)')
        .eq('place_id', placeId)
        .order('created_at', ascending: false);

    return response;
  }
}
