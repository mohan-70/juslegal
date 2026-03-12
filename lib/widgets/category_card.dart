import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_animations.dart';

class CategoryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final int index;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.curveSharp,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.curveSharp,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimations.staggeredListItem(
      Card(
        elevation: _isHovered ? 8 : 4,
        shadowColor: AppColors.shadow,
        surfaceTintColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _isHovered ? AppColors.primary : AppColors.border,
            width: _isHovered ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
            widget.onTap();
          },
          onHover: (hovering) {
            setState(() {
              _isHovered = hovering;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _isHovered
                          ? AppColors.cardGradient
                          : const LinearGradient(
                              colors: [AppColors.surface, AppColors.surface],
                            ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Container with Animation
                        AnimatedContainer(
                          duration: AppAnimations.fast,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: _isHovered
                                ? AppColors.heroGradient
                                : LinearGradient(
                                    colors: [
                                      AppColors.trustNavy.withOpacity(0.1),
                                      AppColors.trustNavy.withOpacity(0.05),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isHovered
                                ? [
                                    BoxShadow(
                                      color: AppColors.trustNavy.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            widget.icon,
                            color: _isHovered ? AppColors.surfaceWhite : AppColors.trustNavy,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Title with Animation
                        AnimatedDefaultTextStyle(
                          duration: AppAnimations.fast,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: _isHovered ? AppColors.trustNavy : AppColors.textDarkGrey,
                            fontWeight: FontWeight.w700,
                            fontSize: _isHovered ? 17 : 16,
                          ),
                          child: Text(widget.title),
                        ),
                        const SizedBox(height: 8),
                        
                        // Description with Animation
                        AnimatedDefaultTextStyle(
                          duration: AppAnimations.fast,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.textMediumGrey,
                            height: 1.4,
                            fontSize: _isHovered ? 13 : 12,
                          ),
                          child: Text(
                            widget.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Arrow Indicator
                        AnimatedAlign(
                          duration: AppAnimations.fast,
                          alignment: _isHovered ? Alignment.centerRight : Alignment.center,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: _isHovered ? AppColors.trustNavy : AppColors.textMediumGrey,
                            size: _isHovered ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      widget.index,
      delay: Duration(milliseconds: widget.index * 100),
    );
  }
}
