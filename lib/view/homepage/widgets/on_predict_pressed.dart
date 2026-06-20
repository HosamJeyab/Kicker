import 'package:flutter/material.dart';

void onPredictPressed({
  required BuildContext context,
  required String? teamA,
  required String? teamB,
  required VoidCallback onSuccess,
}) {
  if (teamA != null && teamB != null) {
    if (teamA == teamB) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "الرجاء اختيار فريقين مختلفين",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          backgroundColor: Colors.amber,
          behavior: SnackBarBehavior.floating,
          elevation: 20,
          duration: Duration(seconds: 1),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    // إذا كل شيء تمام، نفذ دالة النجاح التي ستحدث الـ State في الـ Homepage
    onSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            "الرجاء اختيار فريقين لتحليلهم",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        backgroundColor: Colors.amber,
        behavior: SnackBarBehavior.floating,
        elevation: 20,
        duration: Duration(seconds: 1),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
