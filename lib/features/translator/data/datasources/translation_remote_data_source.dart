import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_client.dart';
import '../models/translation_option_model.dart';
import '../models/word_translation_model.dart';

abstract class TranslationRemoteDataSource {
  Future<WordTranslationModel> getTranslations({
    required String word,
    required String sourceLang,
    required String targetLang,
  });
}

class TranslationRemoteDataSourceImpl implements TranslationRemoteDataSource {
  final NetworkClient client;

  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  const TranslationRemoteDataSourceImpl({required this.client});

  @override
  Future<WordTranslationModel> getTranslations({
    required String word,
    required String sourceLang,
    required String targetLang,
  }) async {
    final langpair = '$sourceLang|$targetLang';

    try {
      final response = await client.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'q': word,
          'langpair': langpair,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const ServerException('Пустой ответ от сервера словаря');
      }

      final model = WordTranslationModel.fromApiResponse(
        json: data,
        sourceWord: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );

      if (model.options.isEmpty) {
        // Check fallback dictionary
        final fallback = _getFallbackTranslation(word, sourceLang, targetLang);
        if (fallback != null) {
          return fallback;
        }
        throw const NotFoundException('Перевод для этого слова не найден');
      }

      return model;
    } on AppException {
      // In case of network/server error, try offline fallback
      final fallback = _getFallbackTranslation(word, sourceLang, targetLang);
      if (fallback != null) {
        return fallback;
      }
      rethrow;
    } catch (e) {
      final fallback = _getFallbackTranslation(word, sourceLang, targetLang);
      if (fallback != null) {
        return fallback;
      }
      throw ServerException('Не удалось получить перевод: $e');
    }
  }

  /// Built-in fallback dictionary for common German words in case of network issues or offline mode
  WordTranslationModel? _getFallbackTranslation(
    String word,
    String sourceLang,
    String targetLang,
  ) {
    if (sourceLang != 'de' || targetLang != 'ru') return null;

    final normalized = word.trim().toLowerCase();
    final Map<String, List<String>> dict = {
      'apfel': ['яблоко', 'яблочный'],
      'buch': ['книга', 'разговорник', 'книжка'],
      'haus': ['дом', 'здание', 'жилище'],
      'katze': ['кошка', 'кот'],
      'hund': ['собака', 'пёс'],
      'laufen': ['бегать', 'идти', 'бежать', 'ходить'],
      'gehen': ['идти', 'ходить', 'уходить'],
      'essen': ['кушать', 'есть', 'еда'],
      'trinken': ['пить', 'напиток'],
      'gut': ['хороший', 'добрый', 'хорошо'],
      'schön': ['красивый', 'прекрасный', 'замечательный'],
      'zeit': ['время', 'период', 'эпоха'],
      'leben': ['жить', 'жизнь', 'существовать'],
      'machen': ['делать', 'совершать', 'мастерить'],
      'sehen': ['видеть', 'смотреть', 'глядеть'],
      'hallo': ['здравствуйте', 'привет'],
      'danke': ['спасибо', 'благодарю'],
      'bitte': ['пожалуйста', 'просьба'],
      'wasser': ['вода', 'водный'],
      'sonne': ['солнце', 'солнечный'],
    };

    if (!dict.containsKey(normalized)) return null;

    final options = dict[normalized]!.asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value;
      return TranslationOptionModel(
        id: 'fallback_${normalized}_$index',
        text: text,
        quality: (1.0 - (index * 0.05)).clamp(0.7, 1.0),
        usageCount: 10 - index,
      );
    }).toList();

    return WordTranslationModel(
      sourceWord: word,
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
      options: options,
    );
  }
}
