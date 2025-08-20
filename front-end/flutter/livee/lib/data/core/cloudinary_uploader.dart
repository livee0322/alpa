import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:livee/data/core/api_client.dart';

class CloudinaryUploader {
  final ApiClient _apiClient = ApiClient();
  final String _uploadApi = 'https://api.cloudinary.com/v1_1/dis1og9uq/image/upload';

  Future<String> uploadImage(Uint8List fileBytes, {String? fileName}) async {
    try {
      final response = await _apiClient.get('/uploads/signature');
      if (response.statusCode != 200) {
        throw Exception('Failed to get upload signature');
      }

      final signatureData = jsonDecode(utf8.decode(response.bodyBytes));
      final sig = signatureData['data'] ?? signatureData;
      final String cloudName = sig['cloudName'] as String;
      final String apiKey = sig['apiKey'] as String;
      final int timestamp = sig['timestamp'] as int;
      final String signature = sig['signature'] as String;
      final String? folder = sig['folder'] as String?;

      final uri = Uri.parse(_uploadApi);
      final request = http.MultipartRequest('POST', uri)
        ..fields['api_key'] = apiKey
        ..fields['timestamp'] = timestamp.toString()
        ..fields['signature'] = signature;

      if (folder != null) {
        request.fields['folder'] = folder;
      }

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName ?? 'upload.png',
      ));

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final json = jsonDecode(res.body);
        if (json['secure_url'] == null) {
          throw Exception('Image URL not found in response');
        }
        return json['secure_url'] as String;
      } else {
        final errorJson = jsonDecode(res.body);
        throw Exception(errorJson['error']['message'] ?? 'Cloudinary upload failed');
      }
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}
