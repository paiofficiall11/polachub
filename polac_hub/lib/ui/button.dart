import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.onTap,
    required this.text,
    this.color = const Color.fromARGB(255, 80, 185, 134),
    this.textColor = Colors.white,
    this.loading = false,
    required this.width,
    required this.height,
    this.borderColor,
    this.borderWidth = 0,
    this.borderRadius = 25,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
    this.disabledColor,
    this.disabledTextColor,
  });

  final Function()? onTap;
  final String text;
  final Color color;
  final Color textColor;
  final bool loading;
  final double width;
  final double height;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? disabledColor;
  final Color? disabledTextColor;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.loading && widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.loading || widget.onTap == null;
    final Color buttonColor = isDisabled 
        ? (widget.disabledColor ?? widget.color.withOpacity(0.5))
        : widget.color;
    
    final Color textColor = isDisabled 
        ? (widget.disabledTextColor ?? widget.textColor.withOpacity(0.7))
        : widget.textColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isDisabled ? null : widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.borderColor != null
                ? Border.all(
                    color: widget.borderColor!,
                    width: widget.borderWidth,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.text,
                    style: GoogleFonts.montserrat(
                      color: textColor,
                      fontWeight: widget.fontWeight,
                      fontSize: widget.fontSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}