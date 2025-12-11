import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubmitButton extends StatelessWidget {
  final Function()? onSubmit;
  final String label;
  final double width;
  final Color color;

  const SubmitButton({
    super.key,
    this.onSubmit,
    this.label = 'Submit',
    this.width = 220,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onSubmit ?? () => context.pop(),
        //  onSubmit ?? () => context.pop(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: color,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
