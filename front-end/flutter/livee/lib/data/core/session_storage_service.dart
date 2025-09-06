import 'package:universal_html/html.dart' as html;

// 웹 브라우저의 sessionStorage를 관리하는 서비스 클래스
class SessionStorageService {
  // 세션 스토리지에 데이터를 저장
  static void write(String key, String value) {
    html.window.sessionStorage[key] = value;
  }

  // 세션 스토리지에서 데이터를 읽어오기
  static String? read(String key) {
    return html.window.sessionStorage[key];
  }

  // 세션 스토리지에서 데이터를 삭제
  static void delete(String key) {
    html.window.sessionStorage.remove(key);
  }
}
