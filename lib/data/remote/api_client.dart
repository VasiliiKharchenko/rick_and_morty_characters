import 'package:dio/dio.dart';
import '../../domain/dtos.dart';
import '../../domain/models.dart';

class RickAndMortyApiClient {
  final Dio dio;

  RickAndMortyApiClient(this.dio);

  Future<Paginated<CharacterDto>> getCharacters({required int page}) async {
    final response = await dio.get(
      '/character',
      queryParameters: {'page': page},
    );
    final data = response.data as Map<String, dynamic>;
    final info = data['info'] as Map<String, dynamic>;
    final results = (data['results'] as List)
        .map((e) => CharacterDto.fromJson(e as Map<String, dynamic>))
        .toList();
    final pageInfo = PageInfo(
      count: info['count'] as int? ?? 0,
      pages: info['pages'] as int? ?? 0,
      next: info['next'] as String?,
      prev: info['prev'] as String?,
    );
    return Paginated(info: pageInfo, results: results);
  }
}


