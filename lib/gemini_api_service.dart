// data/gemini_api_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiApiService {
  // GeminiApiService({required this.apiKey});

  Stream<String> streamBotReply(String prompt) async* {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyBvNOmL4_nHWcItYXiE02WPAjFP9CD_CYM',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final candidates = data['candidates'] as List<dynamic>? ?? [];
        if (candidates.isEmpty) {
          throw Exception('No candidates found in response');
        }

        final content = candidates[0]['content'] as Map<String, dynamic>? ?? {};
        final parts = content['parts'] as List<dynamic>? ?? [];

        if (parts.isEmpty) {
          throw Exception('No parts found in content');
        }

        final fullText = parts[0]['text'] as String? ?? '';

        // Simulate typing effect by yielding chunks
        for (int i = 1; i <= fullText.length; i++) {
          await Future.delayed(const Duration(milliseconds: 30));
          yield fullText.substring(0, i);
        }
      } else {
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    } catch (e) {
      yield "❌ Error: ${e.toString()}";
    }
  }
}
