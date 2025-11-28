import 'package:flutter/material.dart';

class AnimatedBottomNavigation extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double height;

  const AnimatedBottomNavigation({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height = 70,
  }) : super(key: key);

  @override
  _AnimatedBottomNavigationState createState() => _AnimatedBottomNavigationState();
}

class _AnimatedBottomNavigationState extends State<AnimatedBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rippleController;
  late Animation<double> _animation;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconAnimations;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Initialize icon controllers for each item
    _iconControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    
    _iconAnimations = _iconControllers.map((controller) =>
      Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      ),
    ).toList();
    
    // Start with the current index selected
    _iconControllers[widget.currentIndex].forward();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _iconControllers[oldWidget.currentIndex].reverse();
      _iconControllers[widget.currentIndex].forward();
      _rippleController.forward().then((_) => _rippleController.reset());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.bottomAppBarTheme.color ?? theme.cardColor;
    final selectedColor = widget.selectedColor ?? theme.primaryColor;
    final unselectedColor = widget.unselectedColor ?? theme.unselectedWidgetColor;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              return _buildNavItem(
                index,
                widget.items[index],
                selectedColor,
                unselectedColor,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    BottomNavItem item,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final isSelected = index == widget.currentIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _animation,
            _iconAnimations[index],
            _rippleController,
          ]),
          builder: (context, child) {
            return Container(
              height: widget.height - 16,
              child: Stack(
                children: [
                  // Ripple effect
                  if (isSelected && _rippleController.value > 0)
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 60 * _rippleController.value,
                          height: 60 * _rippleController.value,
                          decoration: BoxDecoration(
                            color: selectedColor.withOpacity(0.2 * (1 - _rippleController.value)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with animation
                        Transform.scale(
                          scale: _iconAnimations[index].value,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: isSelected ? BoxDecoration(
                              color: selectedColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ) : null,
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? selectedColor : unselectedColor,
                              size: 24,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Label with fade animation
                        AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.7,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? selectedColor : unselectedColor,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection indicator
                  if (isSelected)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget? badge;

  BottomNavItem({
    required this.icon,
    IconData? activeIcon,
    required this.label,
    this.badge,
  }) : activeIcon = activeIcon ?? icon;
}

class FloatingBottomNavigation extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const FloatingBottomNavigation({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  _FloatingBottomNavigationState createState() => _FloatingBottomNavigationState();
}

class _FloatingBottomNavigationState extends State<FloatingBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late List<AnimationController> _bounceControllers;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _bounceControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    
    _slideController.forward();
  }

  @override
  void didUpdateWidget(FloatingBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _bounceControllers[widget.currentIndex].forward().then((_) {
        _bounceControllers[widget.currentIndex].reverse();
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    for (var controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.cardColor;
    final selectedColor = widget.selectedColor ?? theme.primaryColor;
    final unselectedColor = widget.unselectedColor ?? theme.unselectedWidgetColor;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final isSelected = index == widget.currentIndex;
            
            return AnimatedBuilder(
              animation: _bounceControllers[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_bounceControllers[index].value * 0.2),
                  child: GestureDetector(
                    onTap: () => widget.onTap(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: isSelected ? BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(20),
                      ) : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? Colors.white : unselectedColor,
                            size: 24,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class MorphingBottomNavigation extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;
  final Color? selectedColor;

  const MorphingBottomNavigation({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
  }) : super(key: key);

  @override
  _MorphingBottomNavigationState createState() => _MorphingBottomNavigationState();
}

class _MorphingBottomNavigationState extends State<MorphingBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(MorphingBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _morphController.forward().then((_) => _morphController.reverse());
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.cardColor;
    final selectedColor = widget.selectedColor ?? theme.primaryColor;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _morphAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: MorphingPainter(
                currentIndex: widget.currentIndex,
                itemCount: widget.items.length,
                animation: _morphAnimation.value,
                selectedColor: selectedColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final isSelected = index == widget.currentIndex;
                  
                  return GestureDetector(
                    onTap: () => widget.onTap(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MorphingPainter extends CustomPainter {
  final int currentIndex;
  final int itemCount;
  final double animation;
  final Color selectedColor;

  MorphingPainter({
    required this.currentIndex,
    required this.itemCount,
    required this.animation,
    required this.selectedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.fill;

    final itemWidth = size.width / itemCount;
    final centerX = (currentIndex + 0.5) * itemWidth;
    final morphWidth = itemWidth * 0.8;
    final morphHeight = size.height * 0.6;

    final path = Path();
    final morphRadius = morphHeight / 2;
    
    // Create morphing shape
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, size.height / 2),
          width: morphWidth,
          height: morphHeight,
        ),
        Radius.circular(morphRadius),
      ),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MorphingPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
           oldDelegate.animation != animation;
  }
}