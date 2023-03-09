import 'package:flutter/material.dart';
import 'package:hard_diffusion/forms/advanced_column.dart';

class ShowAdvancedOptionsButton extends StatelessWidget {
  const ShowAdvancedOptionsButton({
    super.key,
    required this.landscape,
  });

  final bool landscape;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return SingleChildScrollView(
                child: AlertDialog(
                  //scrollable: true,
                  content: AdvancedColumn(
                    landscape: landscape,
                  ),
                ),
              );
            }),
        child: Text("Show Advanced"));
  }
}
