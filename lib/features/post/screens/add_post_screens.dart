import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/Theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerStatefulWidget {
  const AddPostScreen({super.key});

  @override
  ConsumerState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends ConsumerState<AddPostScreen> {
  final cardHeightWidth = 120.0;
  final iconSize = 60.0;
  
  void navigateToAddPostTypeScreen(String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => navigateToAddPostTypeScreen('image'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: Pallete.darkModeAppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                  child: Icon(
                Icons.image_outlined,
                size: iconSize,
              )),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToAddPostTypeScreen('text'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: Pallete.darkModeAppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                  child: Icon(
                Icons.font_download_outlined,
                size: iconSize,
              )),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => navigateToAddPostTypeScreen('link'),
          child: SizedBox(
            height: cardHeightWidth,
            width: cardHeightWidth,
            child: Card(
              color: Pallete.darkModeAppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 16,
              child: Center(
                  child: Icon(
                Icons.link_outlined,
                size: iconSize,
              )),
            ),
          ),
        )
      ],
    );
  }
}
