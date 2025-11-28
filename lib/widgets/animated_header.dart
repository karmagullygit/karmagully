import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedHeader extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String) onSearch;
  final VoidCallback onCartTap;
  final int cartItemCount;

  const AnimatedHeader({
    Key? key,
    required this.scrollController,
    required this.onSearch,
    required this.onCartTap,
    this.cartItemCount = 0,
  }) : super(key: key);

  @override
  _AnimatedHeaderState createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<AnimatedHeader>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _searchController;
  late AnimationController _gradientController;
  late Animation<double> _headerAnimation;
  late Animation<double> _searchAnimation;
  late Animation<double> _gradientAnimation;
  
  bool _isSearchExpanded = false;
  final TextEditingController _searchTextController = TextEditingController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.elasticOut,
    ));
    
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_gradientController);
    
    widget.scrollController.addListener(_handleScroll);
    _animationController.forward();
  }

  void _handleScroll() {
    setState(() {
      _scrollOffset = widget.scrollController.offset;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _gradientController.dispose();
    _searchTextController.dispose();
    widget.scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
    
    if (_isSearchExpanded) {
      _searchController.forward();
    } else {
      _searchController.reverse();
      _searchTextController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parallaxOffset = _scrollOffset * 0.5;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_headerAnimation, _gradientAnimation]),
      builder: (context, child) {
        return Container(
          height: 120 + (40 * (1 - math.min(_scrollOffset / 100, 1))),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (0.3 * math.sin(_gradientAnimation.value * 2 * math.pi)),
                0.7 + (0.2 * math.cos(_gradientAnimation.value * 2 * math.pi)),
                1.0,
              ],
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.6),
                theme.primaryColor.withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row with logo and cart
                  Transform.translate(
                    offset: Offset(0, -parallaxOffset),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(_headerAnimation),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo section
                          FadeTransition(
                            opacity: _headerAnimation,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'KarmaShop',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Cart button with animation
                          ScaleTransition(
                            scale: _headerAnimation,
                            child: _AnimatedCartButton(
                              onTap: widget.onCartTap,
                              itemCount: widget.cartItemCount,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Search bar
                  Transform.translate(
                    offset: Offset(0, parallaxOffset * 0.3),
                    child: _AnimatedSearchBar(
                      controller: _searchTextController,
                      isExpanded: _isSearchExpanded,
                      animation: _searchAnimation,
                      onToggle: _toggleSearch,
                      onSearch: widget.onSearch,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedCartButton extends StatefulWidget {
  final VoidCallback onTap;
  final int itemCount;

  const _AnimatedCartButton({
    required this.onTap,
    required this.itemCount,
  });

  @override
  _AnimatedCartButtonState createState() => _AnimatedCartButtonState();
}

class _AnimatedCartButtonState extends State<_AnimatedCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(_AnimatedCartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != oldWidget.itemCount && widget.itemCount > 0) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  if (widget.itemCount > 0)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.itemCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isExpanded;
  final Animation<double> animation;
  final VoidCallback onToggle;
  final Function(String) onSearch;

  const _AnimatedSearchBar({
    required this.controller,
    required this.isExpanded,
    required this.animation,
    required this.onToggle,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search icon/button
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isExpanded ? Icons.close : Icons.search,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Search input field
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isExpanded ? double.infinity : 0,
                  child: isExpanded
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: controller,
                            onSubmitted: onSearch,
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              
              // Voice search button
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.mic,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}