import 'package:flutter/material.dart';

class MyAppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final void Function(bool)? onFocusChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Color fillColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const MyAppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.validator,
    this.focusNode,
    this.onFocusChanged,
    this.readOnly = false,
    this.onTap,
    this.contentPadding,
    this.fillColor = Colors.white,
    this.borderRadius = 12,
    this.boxShadow,
  });

  @override
  State<MyAppTextField> createState() => _MyAppTextFieldState();
}

class _MyAppTextFieldState extends State<MyAppTextField> {
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (widget.onFocusChanged != null) {
      widget.onFocusChanged!(_internalFocusNode.hasFocus);
    }
    setState(() {}); // For UI changes on focus
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.fillColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow:
            widget.boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
      ),
      child: TextFormField(
        controller: widget.controller,
        maxLines: widget.maxLines,
        focusNode: _internalFocusNode,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none, // no extra border needed
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: widget.validator,
      ),
    );
  }
}
