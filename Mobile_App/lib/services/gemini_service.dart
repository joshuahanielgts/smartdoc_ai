import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final Dio _dio;
  late final GeminiClient _client;
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    _initializeService();
  }

  void _initializeService() {
    if (apiKey.isEmpty) {
      throw Exception(
          'GEMINI_API_KEY must be provided via --dart-define or environment variables');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1',
        headers: {
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _client = GeminiClient(_dio, apiKey);
  }

  Dio get dio => _dio;
  String get authApiKey => apiKey;
  GeminiClient get client => _client;
}

class GeminiClient {
  final Dio dio;
  final String apiKey;

  GeminiClient(this.dio, this.apiKey);

  Future<Completion> createChat({
    required List<Message> messages,
    String model = 'gemini-1.5-flash-002',
    int maxTokens = 1024,
    double temperature = 1.0,
  }) async {
    try {
      final contents = messages
          .map((m) => {
                'role': m.role,
                'parts': m.content is String
                    ? [
                        {'text': m.content}
                      ]
                    : m.content,
              })
          .toList();

      final response = await dio.post(
        '/models/$model:generateContent',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'contents': contents,
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': temperature,
          },
        },
      );

      if (response.data['candidates'] != null &&
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0]['content'] != null) {
        final parts = response.data['candidates'][0]['content']['parts'];
        final text = parts.isNotEmpty ? parts[0]['text'] : '';
        return Completion(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to parse response or empty response',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Unknown error',
      );
    }
  }

  Stream<String> streamChat({
    required List<Message> messages,
    String model = 'gemini-1.5-flash-002',
    int maxTokens = 1024,
    double temperature = 1.0,
  }) async* {
    try {
      final contents = messages
          .map((m) => {
                'role': m.role,
                'parts': m.content is String
                    ? [
                        {'text': m.content}
                      ]
                    : m.content,
              })
          .toList();

      final response = await dio.post(
        '/models/$model:streamGenerateContent',
        queryParameters: {
          'key': apiKey,
          'alt': 'sse',
        },
        data: {
          'contents': contents,
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': temperature,
          },
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data as ResponseBody;
      await for (var line
          in LineSplitter().bind(utf8.decoder.bind(stream.stream))) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            if (json.containsKey('candidates') &&
                json['candidates'].isNotEmpty &&
                json['candidates'][0].containsKey('content') &&
                json['candidates'][0]['content'].containsKey('parts') &&
                json['candidates'][0]['content']['parts'].isNotEmpty) {
              final text = json['candidates'][0]['content']['parts'][0]['text'];
              if (text != null && text.isNotEmpty) {
                yield text;
              }
            }
          } catch (e) {
            // Skip malformed data
          }
        }
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Stream error',
      );
    }
  }

  Future<Completion> createMultimodal({
    required String prompt,
    required File image,
    String model = 'gemini-1.5-flash-002',
    int maxTokens = 1024,
  }) async {
    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    try {
      final response = await dio.post(
        '/models/$model:generateContent',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt},
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': maxTokens,
          },
        },
      );

      if (response.data['candidates'] != null &&
          response.data['candidates'].isNotEmpty &&
          response.data['candidates'][0]['content'] != null) {
        final parts = response.data['candidates'][0]['content']['parts'];
        final text = parts.isNotEmpty ? parts[0]['text'] : '';
        return Completion(text: text);
      } else {
        throw GeminiException(
          statusCode: response.statusCode ?? 500,
          message: 'Failed to parse response or empty response',
        );
      }
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Multimodal error',
      );
    }
  }

  Future<List<String>> listModels() async {
    try {
      final response = await dio.get(
        '/models',
        queryParameters: {
          'key': apiKey,
        },
      );

      final modelList = (response.data['models'] as List)
          .map((model) => model['name'] as String)
          .toList();
      return modelList;
    } on DioException catch (e) {
      throw GeminiException(
        statusCode: e.response?.statusCode ?? 500,
        message: e.response?.data?['error']?['message'] ??
            e.message ??
            'Failed to fetch models',
      );
    } catch (e) {
      throw GeminiException(
        statusCode: 500,
        message: 'Unexpected error fetching models: ${e.toString()}',
      );
    }
  }

  /// Generate AI summary for driving data
  Future<String> generateDrivingDataSummary({
    required Map<String, dynamic> weeklyStats,
    required List<Map<String, dynamic>> weeklyDRIData,
    required List<Map<String, dynamic>> recentSessions,
  }) async {
    try {
      // Create a comprehensive prompt for driving data analysis
      final prompt = '''
Analyze the following driving safety data and provide a concise, actionable AI safety insight (maximum 2-3 sentences):

Weekly Statistics:
- Total Sessions: ${weeklyStats['totalSessions']}
- Average DRI Score: ${weeklyStats['avgDRI']}
- Total Hours: ${weeklyStats['totalHours']}
- Performance Improvement: ${weeklyStats['improvement']}%

Daily DRI Trends:
${weeklyDRIData.map((day) => "- ${day['day']}: ${day['dri']}").join('\n')}

Recent Sessions Summary:
${recentSessions.take(3).map((session) => "- ${session['date']}: ${session['duration']}, Peak DRI: ${session['peakDRI']}, Rating: ${session['safetyRating']}").join('\n')}

Please provide:
1. Key insight about driving patterns
2. One specific actionable recommendation
3. Focus on safety and performance improvement

Keep the response professional, concise, and focused on driver safety.
''';

      final message = Message(role: 'user', content: prompt);
      final response = await createChat(
        messages: [message],
        model: 'gemini-1.5-flash-002',
        maxTokens: 200,
        temperature: 0.7,
      );

      return response.text.trim();
    } catch (e) {
      // Return fallback insight if AI generation fails
      return _getFallbackInsight(weeklyStats);
    }
  }

  String _getFallbackInsight(Map<String, dynamic> weeklyStats) {
    final improvement = weeklyStats['improvement'] as double;
    final avgDRI = weeklyStats['avgDRI'] as double;

    if (improvement > 10) {
      return "Your driving performance has improved significantly by ${improvement.toStringAsFixed(1)}% this week. Continue maintaining your current driving habits for optimal safety.";
    } else if (avgDRI >= 8.0) {
      return "Excellent driving performance with an average DRI of ${avgDRI.toStringAsFixed(1)}. Your consistent focus levels indicate strong safety awareness.";
    } else if (avgDRI >= 6.0) {
      return "Good driving performance this week. Consider taking regular breaks every 90 minutes to maintain optimal focus levels during longer trips.";
    } else {
      return "Your DRI scores suggest room for improvement. Consider reviewing your driving patterns and take more frequent breaks to enhance safety.";
    }
  }
}

class Message {
  final String role;
  final dynamic content; // String or List<Map<String, dynamic>>

  Message({required this.role, required this.content});
}

class Completion {
  final String text;

  Completion({required this.text});
}

class GeminiException implements Exception {
  final int statusCode;
  final String message;

  GeminiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GeminiException: $statusCode - $message';
}
