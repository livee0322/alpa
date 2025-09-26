import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    switch (widget.clip.provider) {
      case 'youtube':
        final cleanUrl = widget.clip.url.split('?').first;
        final videoId = YoutubePlayerController.convertUrlToId(cleanUrl);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController.fromVideoId(
            videoId: videoId,
            autoPlay: true,
            // 유튜브 기본 컨트롤러 UI를 모두 숨깁
            params: const YoutubePlayerParams(
              showControls: false,
              showFullscreenButton: false,
              strictRelatedVideos: true,
            ),
          );
        }
        break;
      case 'instagram':
        // 인스타그램은 embed URL을 사용
        _webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse('${widget.clip.url}/embed'));
        break;
      case 'tiktok':
        // 틱톡은 원본 URL을 사용
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
    // [복원] 9:16 비율의 팝업 모달 UI로 복원합니다.
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // [복원] FittedBox를 사용하여 영상을 세로로 꽉 채웁니다.
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: _buildPlayer(),
                  ),
                ),
                _buildHeader(),
                // Positioned(
                //   top: 10,
                //   right: 10,
                //   child: IconButton(
                //     icon:
                //         const Icon(Icons.close, color: Colors.white, size: 30),
                //     onPressed: () => context.pop(),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// [복원] 각 플랫폼에 맞는 플레이어를 반환하는 헬퍼 메소드
  Widget _buildPlayer() {
    if (_youtubeController != null) {
      return SizedBox(
        width: 16 * 100, // 16:9 비율
        height: 9 * 100,
        child: YoutubePlayer(controller: _youtubeController!),
      );
    }
    if (_webViewController != null) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: WebViewWidget(controller: _webViewController!));
    }
    return _buildErrorView();
  }

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

  Widget _buildHeader() {
    return Positioned(
      top: 20,
      left: 20,
      right: 60,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage:
                NetworkImage('https://picsum.photos/seed/user/100/100'),
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
