import 'package:flutter/material.dart';
import 'package:livee/domain/models/clip.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// 숏클립 영상을 재생하는 팝업 모달 위젯
class ClipPlayerModal extends StatefulWidget {
  final Clip clip;

  const ClipPlayerModal({super.key, required this.clip});

  @override
  State<ClipPlayerModal> createState() => _ClipPlayerModalState();
}

class _ClipPlayerModalState extends State<ClipPlayerModal> {
  YoutubePlayerController? _youtubeController;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    // 클립의 플랫폼(provider)에 따라 적절한 컨트롤러를 초기화
    switch (widget.clip.provider) {
      case 'youtube':
        // 유튜브 URL에서 영상 ID를 추출합니다.
        final videoId = YoutubePlayerController.convertUrlToId(widget.clip.url);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController.fromVideoId(
            videoId: videoId,
            autoPlay: true,
            params: const YoutubePlayerParams(showFullscreenButton: true),
          );
        }
        break;
      case 'instagram':
      case 'tiktok':
        // 인스타그램, 틱톡은 웹뷰로 재생
        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(widget.clip.url));
        break;
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 9 / 16, // 세로 영상 비율
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // --- 1. 비디오 플레이어 영역 ---
                if (_youtubeController != null)
                  Center(child: YoutubePlayer(controller: _youtubeController!))
                else if (_webViewController != null)
                  WebViewWidget(controller: _webViewController!)
                else
                  _buildErrorView(), // 지원하지 않는 URL 처리

                // --- 2. 상단 정보 (제목 등) ---
                _buildHeader(),

                // --- 3. 닫기 버튼 ---
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 영상 재생 실패 시 보여줄 화면
  Widget _buildErrorView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 48),
          SizedBox(height: 16),
          Text(
            '영상을 재생할 수 없습니다.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// 모달 상단의 헤더 UI
  Widget _buildHeader() {
    // 현재 Clip 모델에는 사용자 정보가 없으므로 임시 데이터를 사용합니다.
    return Positioned(
      top: 20,
      left: 20,
      right: 60, // 닫기 버튼 영역 확보
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            // TODO: 실제 사용자 프로필 이미지로 교체 필요
            backgroundImage: NetworkImage('https://picsum.photos/seed/user/100/100'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.clip.title ?? '제목 없음',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
