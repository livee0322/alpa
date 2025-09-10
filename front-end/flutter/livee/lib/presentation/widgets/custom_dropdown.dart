import 'package:flutter/material.dart';

// 앱 전역에서 사용할 공통 드롭다운 컴포넌트
class CustomDropdown extends StatefulWidget {
  final String? label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Offset menuOffset;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;

  const CustomDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.menuOffset = const Offset(0, 8),
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.fontWeight = FontWeight.normal,
    this.borderRadius,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  BorderRadius get _borderRadius => widget.borderRadius ?? BorderRadius.circular(12);

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 외부 클릭 감지기: 화면 전체를 덮는 투명한 위젯
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay, // 외부를 탭하면 메뉴를 닫음
              behavior: HitTestBehavior.opaque, // 투명한 영역에서도 탭을 감지
              child: Container(color: Colors.transparent), // 시각적으로는 보이지 않음
            ),
          ),
          // 기존 드롭다운 메뉴 UI
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: widget.menuOffset, // 버튼과 메뉴 사이 간격
              child: Material(
                elevation: 4.0,
                color: Colors.white,
                borderRadius: _borderRadius,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: _borderRadius,
                    border: Border.all(color: Colors.grey.shade300, width: 1.0),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          widget.onChanged(widget.items[index]);
                          _removeOverlay();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Text(
                            widget.items[index],
                            style: TextStyle(
                              color: widget.items[index] == widget.value ? const Color(0xFF6C63FF) : Colors.black,
                              fontWeight: widget.items[index] == widget.value ? FontWeight.bold : FontWeight.normal,
                              fontSize: widget.fontSize,
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 8, endIndent: 8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            onTap: _toggleDropdown,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _borderRadius,
                border: Border.all(
                  color: _isOpen ? const Color(0xFF6C63FF) : Colors.grey.shade300,
                  width: _isOpen ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.value,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
