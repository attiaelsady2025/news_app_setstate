import 'package:news_app/data/data_source/dio_service.dart';
import 'package:news_app/data/models/news_model.dart';

class NewsListService {
  final DioService _dioService = DioService();

  /// Fetch news from API based on search item
  Future<List<NewsModel>> getNewsFromApi({required String searchedItem}) async {
    try {
      final List<NewsModel> newsResponse = await _dioService.getNews(
        searchedItem: searchedItem,
      );
      return newsResponse;
    } catch (error) {
      throw Exception('Failed to fetch news: $error');
    }
  }
}
