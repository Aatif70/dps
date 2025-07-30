import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  static void show(
      BuildContext context, {
        required String message,
        SnackbarType type = SnackbarType.info,
        Duration duration = const Duration(seconds: 3),
        String? actionLabel,
        VoidCallback? onActionPressed,
        bool showCloseIcon = true,
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CustomSnackbarWidget(
        message: message,
        type: type,
        duration: duration,
        actionLabel: actionLabel,
        onActionPressed: onActionPressed,
        showCloseIcon: showCloseIcon,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void showSuccess(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
        String? actionLabel,
        VoidCallback? onActionPressed,
      }) {
    show(
      context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showError(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 4),
        String? actionLabel,
        VoidCallback? onActionPressed,
      }) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showWarning(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
        String? actionLabel,
        VoidCallback? onActionPressed,
      }) {
    show(
      context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showInfo(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 3),
        String? actionLabel,
        VoidCallback? onActionPressed,
      }) {
    show(
      context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
}

class _CustomSnackbarWidget extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool showCloseIcon;
  final VoidCallback onDismiss;

  const _CustomSnackbarWidget({
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onActionPressed,
    required this.showCloseIcon,
    required this.onDismiss,
  });

  @override
  State<_CustomSnackbarWidget> createState() => _CustomSnackbarWidgetState();
}

class _CustomSnackbarWidgetState extends State<_CustomSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case SnackbarType.success:
        return const Color(0xFF10B981);
      case SnackbarType.error:
        return const Color(0xFFEF4444);
      case SnackbarType.warning:
        return const Color(0xFFF59E0B);
      case SnackbarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle_outline_rounded;
      case SnackbarType.error:
        return Icons.error_outline_rounded;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _getBackgroundColor().withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null && widget.onActionPressed != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        widget.onActionPressed?.call();
                        _dismiss();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  if (widget.showCloseIcon) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
