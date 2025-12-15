// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';

// // class SubmitButton extends StatelessWidget {
// //   final Function()? onSubmit;
// //   final String label;
// //   final double width;
// //   final Color color;

// //   const SubmitButton({
// //     super.key,
// //     this.onSubmit,
// //     this.label = 'Submit',
// //     this.width = 220,
// //     this.color = Colors.blue,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       width: width,
// //       child: ElevatedButton(
// //         onPressed: onSubmit ?? () => context.pop(),
// //         //  onSubmit ?? () => context.pop(),
// //         style: ElevatedButton.styleFrom(
// //           padding: const EdgeInsets.symmetric(vertical: 14),
// //           // shape: RoundedRectangleBorder(
// //           //   borderRadius: BorderRadius.circular(10),
// //           // ),
// //           backgroundColor: color,
// //         ),
// //         child: Text(
// //           label,
// //           style: const TextStyle(
// //             fontSize: 15,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class SubmitButton extends StatelessWidget {
//   final VoidCallback? onSubmit;
//   final String label;
//   final double width;
//   final Color color;
//   final IconData? icon;
//   final bool isLoading;

//   const SubmitButton({
//     super.key,
//     this.onSubmit,
//     this.label = 'Submit',
//     this.width = 220,
//     this.color = Colors.red,
//     // const Color(0xFF4C4CFF), // modern blue
//     this.icon,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       height: 48,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onSubmit ?? () => context.pop(),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           foregroundColor: Colors.white,
//           elevation: 3,
//           shadowColor: color.withOpacity(0.35),
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           // shape: RoundedRectangleBorder(
//           //   borderRadius: BorderRadius.circular(14),
//           // ),
//         ),
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 200),
//           child: isLoading
//               ? const SizedBox(
//                   key: ValueKey('loader'),
//                   height: 22,
//                   width: 22,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2.2,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 )
//               : Row(
//                   key: const ValueKey('content'),
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (icon != null) ...[
//                       Icon(icon, size: 18),
//                       const SizedBox(width: 8),
//                     ],
//                     Text(
//                       label,
//                       style: const TextStyle(
//                         fontSize: 15.5,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }
