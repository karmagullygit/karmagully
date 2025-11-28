import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomPageTransitions {
  static const Duration _defaultDuration = Duration(milliseconds: 400);

  // Slide transition from right
  static PageRouteBuilder slideFromRight<T>(
    Widget page, {
    Duration duration = _defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Slide transition from bottom
  static PageRouteBuilder slideFromBottom<T>(
    Widget page, {
    Duration duration = _defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Scale and fade transition
  static PageRouteBuilder scaleAndFade<T>(
    Widget page, {
    Duration duration = _defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        
        var scaleTween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  // Rotation and scale transition
  static PageRouteBuilder rotationScale<T>(
    Widget page, {
    Duration duration = _defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.elasticOut;
        
        var scaleTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        
        var rotationTween = Tween(begin: 0.5, end: 0.0).chain(
          CurveTween(curve: curve),
        );

        return Transform.scale(
          scale: animation.drive(scaleTween).value,
          child: Transform.rotate(
            angle: animation.drive(rotationTween).value * math.pi,
            child: child,
          ),
        );
      },
    );
  }

  // Flip transition
  static PageRouteBuilder flip<T>(
    Widget page, {
    Duration duration = _defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final isShowingFrontSide = animation.value < 0.5;
            if (isShowingFrontSide) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(animation.value * math.pi),
                child: child,
              );
            } else {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY((animation.value - 1) * math.pi),
                child: page,
              );
            }
          },
          child: child,
        );
      },
    );
  }

  // Slide with parallax effect
  static PageRouteBuilder slideWithParallax<T>(
    Widget page, {
    Duration duration = _defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        
        var primarySlide = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));
        
        var secondarySlide = Tween(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).chain(CurveTween(curve: curve));

        return Stack(
          children: [
            SlideTransition(
              position: secondaryAnimation.drive(secondarySlide),
              child: child,
            ),
            SlideTransition(
              position: animation.drive(primarySlide),
              child: page,
            ),
          ],
        );
      },
    );
  }

  // Zoom and blur transition
  static PageRouteBuilder zoomBlur<T>(
    Widget page, {
    Duration duration = _defaultDuration,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        
        var scaleTween = Tween(begin: 1.5, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: page,
          ),
        );
      },
    );
  }

  // Bouncy entrance
  static PageRouteBuilder bouncy<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 600),
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.elasticOut;
        
        var scaleTween = Tween(begin: 0.3, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        
        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        );

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: page,
          ),
        );
      },
    );
  }
}

// Extension to make navigation easier
extension NavigationExtension on BuildContext {
  Future<T?> pushSlideRight<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CustomPageTransitions.slideFromRight<T>(page) as Route<T>,
    );
  }

  Future<T?> pushSlideBottom<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CustomPageTransitions.slideFromBottom<T>(page) as Route<T>,
    );
  }

  Future<T?> pushScaleFade<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CustomPageTransitions.scaleAndFade<T>(page) as Route<T>,
    );
  }

  Future<T?> pushRotationScale<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CustomPageTransitions.rotationScale<T>(page) as Route<T>,
    );
  }

  Future<T?> pushFlip<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CustomPageTransitions.flip<T>(page) as Route<T>,
    );
  }

  Future<T?> pushParallax<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CustomPageTransitions.slideWithParallax<T>(page) as Route<T>,
    );
  }

  Future<T?> pushZoomBlur<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CustomPageTransitions.zoomBlur<T>(page) as Route<T>,
    );
  }

  Future<T?> pushBouncy<T>(Widget page) {
    return Navigator.of(this).push<T>(
      CustomPageTransitions.bouncy<T>(page) as Route<T>,
    );
  }
}