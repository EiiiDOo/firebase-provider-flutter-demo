import 'package:flutter/material.dart';

customDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actionsPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        ),
  );
}

showLoading(context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("Loading", textAlign: TextAlign.center),
          content: SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
  );
}
