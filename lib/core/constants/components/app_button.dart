import 'package:flutter/material.dart';

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isDisabled;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonConfig = _getButtonConfig(colorScheme);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                width: double.infinity,
                height: buttonConfig.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    buttonConfig.borderRadius,
                  ),
                  gradient: widget.isDisabled || widget.isLoading
                      ? null
                      : buttonConfig.gradient,
                  color: widget.isDisabled || widget.isLoading
                      ? buttonConfig.disabledColor
                      : null,
                  boxShadow: widget.isDisabled || widget.isLoading
                      ? null
                      : buttonConfig.boxShadow,
                  border: buttonConfig.border,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: (widget.isDisabled || widget.isLoading)
                        ? null
                        : widget.onPressed,
                    borderRadius: BorderRadius.circular(
                      buttonConfig.borderRadius,
                    ),
                    splashColor: buttonConfig.splashColor,
                    highlightColor: buttonConfig.highlightColor,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonConfig.horizontalPadding,
                        vertical: buttonConfig.verticalPadding,
                      ),
                      child: widget.isLoading
                          ? _buildLoadingIndicator(buttonConfig)
                          : _buildButtonContent(buttonConfig),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(ButtonConfig config) {
    return Center(
      child: SizedBox(
        width: config.loadingSize,
        height: config.loadingSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(config.foregroundColor),
        ),
      ),
    );
  }

  Widget _buildButtonContent(ButtonConfig config) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: config.iconSize,
            color: config.foregroundColor,
          ),
          SizedBox(width: config.iconSpacing),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: config.fontSize,
              fontWeight: config.fontWeight,
              color: config.foregroundColor,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  ButtonConfig _getButtonConfig(ColorScheme colorScheme) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ButtonConfig(
          height: widget.size.height,
          borderRadius: 16,
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          foregroundColor: colorScheme.onPrimary,
          disabledColor: colorScheme.primary.withOpacity(0.3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
          splashColor: colorScheme.onPrimary.withOpacity(0.1),
          highlightColor: colorScheme.onPrimary.withOpacity(0.05),
          fontSize: widget.size.fontSize,
          fontWeight: FontWeight.w600,
          iconSize: widget.size.iconSize,
          loadingSize: widget.size.loadingSize,
          horizontalPadding: widget.size.horizontalPadding,
          verticalPadding: widget.size.verticalPadding,
          iconSpacing: 8,
        );
      case AppButtonVariant.secondary:
        return ButtonConfig(
          height: widget.size.height,
          borderRadius: 16,
          gradient: null,
          foregroundColor: colorScheme.primary,
          disabledColor: colorScheme.surface.withOpacity(0.5),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
          splashColor: colorScheme.primary.withOpacity(0.08),
          highlightColor: colorScheme.primary.withOpacity(0.04),
          fontSize: widget.size.fontSize,
          fontWeight: FontWeight.w500,
          iconSize: widget.size.iconSize,
          loadingSize: widget.size.loadingSize,
          horizontalPadding: widget.size.horizontalPadding,
          verticalPadding: widget.size.verticalPadding,
          iconSpacing: 8,
        );
      case AppButtonVariant.ghost:
        return ButtonConfig(
          height: widget.size.height,
          borderRadius: 12,
          gradient: null,
          foregroundColor: colorScheme.primary,
          disabledColor: Colors.transparent,
          splashColor: colorScheme.primary.withOpacity(0.08),
          highlightColor: colorScheme.primary.withOpacity(0.04),
          fontSize: widget.size.fontSize,
          fontWeight: FontWeight.w500,
          iconSize: widget.size.iconSize,
          loadingSize: widget.size.loadingSize,
          horizontalPadding: widget.size.horizontalPadding,
          verticalPadding: widget.size.verticalPadding,
          iconSpacing: 8,
        );
    }
  }
}

enum AppButtonVariant { primary, secondary, ghost }

enum AppButtonSize {
  small(
    height: 36,
    fontSize: 14,
    iconSize: 16,
    loadingSize: 16,
    horizontalPadding: 16,
    verticalPadding: 8,
  ),
  medium(
    height: 48,
    fontSize: 16,
    iconSize: 20,
    loadingSize: 20,
    horizontalPadding: 24,
    verticalPadding: 12,
  ),
  large(
    height: 56,
    fontSize: 18,
    iconSize: 24,
    loadingSize: 24,
    horizontalPadding: 32,
    verticalPadding: 16,
  );

  const AppButtonSize({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.loadingSize,
    required this.horizontalPadding,
    required this.verticalPadding,
  });

  final double height;
  final double fontSize;
  final double iconSize;
  final double loadingSize;
  final double horizontalPadding;
  final double verticalPadding;
}

class ButtonConfig {
  final double height;
  final double borderRadius;
  final LinearGradient? gradient;
  final Color foregroundColor;
  final Color disabledColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Color splashColor;
  final Color highlightColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;
  final double loadingSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSpacing;

  ButtonConfig({
    required this.height,
    required this.borderRadius,
    this.gradient,
    required this.foregroundColor,
    required this.disabledColor,
    this.boxShadow,
    this.border,
    required this.splashColor,
    required this.highlightColor,
    required this.fontSize,
    required this.fontWeight,
    required this.iconSize,
    required this.loadingSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSpacing,
  });
}
