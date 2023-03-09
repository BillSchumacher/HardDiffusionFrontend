import 'package:flutter/material.dart';
import 'package:hard_diffusion/constants.dart';
import 'package:hard_diffusion/forms/infer_text_to_image.dart';
import 'package:hard_diffusion/generated_images.dart';

class PortraitView extends StatelessWidget {
  const PortraitView({
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
      Column(children: [
        NavigationBar(
          height: 55,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Generate',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) {
            setSelectedIndex(value);
          },
        ),
        Flexible(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: backgroundGradient,
                tileMode: TileMode.mirror,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 5,
                    child: InferTextToImageForm(
                      landscape: false,
                    ),
                  ),
                ),
                Expanded(
                    child: Card(
                        elevation: 5,
                        child: Flexible(child: GeneratedImageListView())))
              ],
            ),
          ),
        )
      ])
    ]);
  }
}
