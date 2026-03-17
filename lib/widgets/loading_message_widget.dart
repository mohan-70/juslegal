import 'dart:async';
import 'package:flutter/material.dart';

class LoadingMessageWidget extends StatefulWidget {
  final String? message;
  const LoadingMessageWidget({super.key, this.message});

  @override
  State<LoadingMessageWidget> createState() => _LoadingMessageWidgetState();
}

class _LoadingMessageWidgetState extends State<LoadingMessageWidget>
    with TickerProviderStateMixin {
  late final List<String> _messages;
  
  int _currentIndex = 0;
  late Timer _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _messages = widget.message != null 
        ? [widget.message!] 
        : [
            'Analyzing your situation...',
            'Checking applicable laws...',
            'Preparing your action plan...',
          ];
          
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    
    // Only cycle messages if there are multiple
    if (_messages.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _messages.length;
            _fadeController.reset();
            _fadeController.forward();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (_messages.length > 1) {
      _timer.cancel();
    }
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _messages[_currentIndex],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
