
import 'package:flutter/material.dart';
import 'package:hard_diffusion/constants.dart';
import 'package:hard_diffusion/forms/infer_text_to_image.dart';
import 'package:hard_diffusion/generated_images.dart';

class LandscapeView extends StatelessWidget {
  const LandscapeView({
    super.key,
    required this.setSelectedIndex,
    required this.selectedIndex,
    required this.constraints,
  });
  final Function(int) setSelectedIndex;
  final int selectedIndex;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: backgroundGradient, // Gradient from https://learnui.design/tools/gradient-generator.html
            tileMode: TileMode.mirror,
          ),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              NavigationRail(
                extended: constraints.maxWidth >= 800,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Generate'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setSelectedIndex(value);
                },
              ),
              Expanded(
                child: Card(
                  elevation: 5,
                  child: InferTextToImageForm(
                    landscape: true,
                  ),
                ),
              ),
              Expanded(
                  child: Card(elevation: 5, child: GeneratedImageListView()))
            ]),
      )
    ]);
  }
}
