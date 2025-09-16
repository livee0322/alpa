import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:livee/data/core/api_client.dart';

class CloudinaryUploader {
  final ApiClient _apiClient = ApiClient();
  final String _uploadApi = 'https://api.cloudinary.com/v1_1/dis1og9uq';

  Future<String> uploadFile(
    Uint8List fileBytes, {
    String? fileName,
    String type = 'image', // 'image' 또는 'raw'
  }) async {
    try {
      final response = await _apiClient.get('/uploads/signature?type=$type');
      if (response.statusCode != 200) {
        throw Exception('Failed to get upload signature');
      }

      final signatureData = jsonDecode(utf8.decode(response.bodyBytes));
      // [수정] sig의 타입을 명확히 Map<String, dynamic>으로 지정합니다.
      final sig =
          (signatureData['data'] ?? signatureData) as Map<String, dynamic>;

      final uploadUrl = type == 'image'
          ? '$_uploadApi/image/upload'
          : '$_uploadApi/raw/upload';
      final uri = Uri.parse(uploadUrl);

      final request = http.MultipartRequest('POST', uri);

      // [수정] Cloudinary가 요구하는 api_key를 명시적으로 추가합니다.
      // 백엔드 응답의 'apiKey' 값을 사용합니다.
      request.fields['api_key'] = sig['apiKey'].toString();

      // 나머지 파라미터들은 동적으로 추가합니다.
      sig.forEach((key, value) {
        // api_key는 이미 추가했으므로 건너뜁니다.
        if (key != 'apiKey') {
          request.fields[key] = value.toString();
        }
      });

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName ?? 'upload',
      ));
      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final json = jsonDecode(res.body);
        if (json['secure_url'] == null) {
          throw Exception('File URL not found in response');
        }
        return json['secure_url'] as String;
      } else {
        final errorJson = jsonDecode(res.body);
        throw Exception(
            errorJson['error']['message'] ?? 'Cloudinary upload failed');
      }
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }
}
