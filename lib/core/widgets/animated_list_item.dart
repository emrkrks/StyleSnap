import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final int delay; // Delay in milliseconds per index
  final Axis slideDirection;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = 50,
    this.slideDirection = Axis.vertical,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    final offset = widget.slideDirection == Axis.vertical
        ? const Offset(0, 0.2)
        : const Offset(0.2, 0);

    _slideAnimation = Tween<Offset>(
      begin: offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation with delay based on index
    Future.delayed(Duration(milliseconds: widget.index * widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

// Convenient wrapper for GridView items
class AnimatedGridItem extends StatelessWidget {
  final Widget child;
  final int index;
  final int columnsCount;
  final int delay;

  const AnimatedGridItem({
    super.key,
    required this.child,
    required this.index,
    this.columnsCount = 2,
    this.delay = 50,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate row to create wave effect
    final row = (index / columnsCount).floor();
    return AnimatedListItem(index: row, delay: delay, child: child);
  }
}
