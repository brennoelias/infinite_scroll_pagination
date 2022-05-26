import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_exception_indicator.dart';

class FirstPageErrorIndicator extends StatelessWidget {
  const FirstPageErrorIndicator({
    required this.title,
    required this.message,
    required this.label,
    this.onTryAgain,
    Key? key,
  }) : super(key: key);

  final String title;
  final String message;
  final String label;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) => FirstPageExceptionIndicator(
        title: title,
        message: message,
        label: label,
        onTryAgain: onTryAgain,
      );
}
