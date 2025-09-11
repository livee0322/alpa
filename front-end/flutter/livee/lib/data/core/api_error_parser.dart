import 'dart:convert';

/// API 에러 응답을 파싱하여 사용자에게 보여줄 메시지를 추출하는 함수
String parseApiError(Object error) {
  try {
    // Exception 객체에서 실제 메시지 문자열을 추출
    final errorMessage = error.toString().replaceFirst('Exception: ', '');
    // 메시지 문자열을 JSON으로 디코딩합니다.
    final json = jsonDecode(errorMessage);
    // 'userMessage' 필드가 있는지 확인하고, 있다면 그 값을 반환
    if (json['userMessage'] != null) {
      return json['userMessage'] as String;
    }
    // 'userMessage'가 없다면 개발자용 메시지라도 반환
    if (json['message'] != null) {
      return json['message'] as String;
    }
    // JSON 파싱은 성공했지만 원하는 필드가 없다면 원본 에러 메시지를 반환
    return errorMessage;
  } catch (e) {
    // JSON 파싱에 실패하면 (에러가 JSON 형식이 아니면) 원본 에러를 그대로 반환
    return error.toString();
  }
}
