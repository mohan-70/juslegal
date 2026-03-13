import 'dart:async';
import 'package:flutter/material.dart';

class LoadingMessageWidget extends StatefulWidget {
  const LoadingMessageWidget({super.key});

  @override
  State<LoadingMessageWidget> createState() => _LoadingMessageWidgetState();
}

class _LoadingMessageWidgetState extends State<LoadingMessageWidget>
    with TickerProviderStateMixin {
  final List<String> _messages = [
    'Analyzing your situation...',
    'Checking applicable laws...',
    'Preparing your action plan...',
  ];
  
  int _currentIndex = 0;
  late Timer _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _messages.length;
        _fadeController.reset();
        _fadeController.forward();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
