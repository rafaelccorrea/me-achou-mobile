import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class LoadingSkeletons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(5, (index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: ListTile(
            leading: SkeletonAnimation(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                ),
              ),
            ),
            title: SkeletonAnimation(
              child: Container(
                width: double.infinity,
                height: 10,
                color: Colors.grey[300],
              ),
            ),
            subtitle: SkeletonAnimation(
              child: Container(
                width: double.infinity,
                height: 10,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 5),
              ),
            ),
          ),
        );
      }),
    );
  }
}
