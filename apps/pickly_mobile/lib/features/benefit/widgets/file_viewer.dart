import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:go_router/go_router.dart';

/// 파일 뷰어 위젯
///
/// 이미지와 PDF를 표시하는 위젯입니다.
/// - 이미지: 확대/축소 가능한 갤러리 뷰
/// - PDF: 웹뷰 또는 외부 뷰어로 열기
/// - 스와이프로 여러 파일 탐색
class FileViewer extends StatefulWidget {
  final List<FileViewerItem> files;
  final int initialIndex;

  const FileViewer({
    super.key,
    required this.files,
    this.initialIndex = 0,
  });

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 파일 갤러리
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              pageController: _pageController,
              itemCount: widget.files.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              builder: (context, index) {
                final file = widget.files[index];

                if (file.type == FileType.image) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(file.url),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '이미지를 불러올 수 없습니다',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  // PDF는 미리보기 표시하고 탭하면 외부 뷰어로 열기
                  return PhotoViewGalleryPageOptions.customChild(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf,
                            size: 80,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            file.name ?? 'PDF 파일',
                            style: PicklyTypography.titleMedium.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: PDF 외부 뷰어로 열기
                              debugPrint('Open PDF: ${file.url}');
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('PDF 열기'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),

            // 상단 툴바
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(Spacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // 닫기 버튼
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // 페이지 인디케이터
                    if (widget.files.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.files.length}',
                          style: PicklyTypography.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 하단 파일명
            if (widget.files[_currentIndex].name != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(Spacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    widget.files[_currentIndex].name!,
                    style: PicklyTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 파일 뷰어 아이템
class FileViewerItem {
  final String url;
  final FileType type;
  final String? name;

  const FileViewerItem({
    required this.url,
    required this.type,
    this.name,
  });

  /// URL 확장자로부터 파일 타입 추론
  factory FileViewerItem.fromUrl(String url, {String? name}) {
    final extension = url.split('.').last.toLowerCase();
    final type = extension == 'pdf' ? FileType.pdf : FileType.image;

    return FileViewerItem(
      url: url,
      type: type,
      name: name,
    );
  }
}

/// 파일 타입
enum FileType {
  image,
  pdf,
}

/// 파일 뷰어를 풀스크린으로 여는 헬퍼 함수
void showFileViewer(
  BuildContext context, {
  required List<FileViewerItem> files,
  int initialIndex = 0,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => FileViewer(
        files: files,
        initialIndex: initialIndex,
      ),
    ),
  );
}
