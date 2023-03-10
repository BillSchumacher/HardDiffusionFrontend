import 'package:flutter/material.dart';
import 'package:hard_diffusion/components/show_advanced_options_button.dart';
import 'package:hard_diffusion/forms/advanced_column.dart';
import 'package:hard_diffusion/forms/fields/prompts.dart';
import 'package:hard_diffusion/forms/fields/toggle_switch.dart';
import 'package:hard_diffusion/state/text_to_image_form.dart';
import 'package:hard_diffusion/state/text_to_image_websocket.dart';
import 'package:provider/provider.dart';

class PromptColumn extends StatelessWidget {
  const PromptColumn({
    super.key,
    required this.landscape,
  });

  final bool landscape;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.all(15.0),
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: PromptForm(
              landscape: landscape,
            ),
          ),
        ],
      ),
    );
  }
}

class PromptForm extends StatelessWidget {
  const PromptForm({
    super.key,
    required this.landscape,
  });

  final bool landscape;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<TextToImageFormState>();
    var websocketState = context.watch<TextToImageWebsocketState>();
    var channel = websocketState.channel;
    var connected = websocketState.webSocketConnected;
    var prompt = appState.prompt;
    var negativePrompt = appState.negativePrompt;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child:
              Text("Generate", style: Theme.of(context).textTheme.titleLarge),
        ),
        PromptField(
            landscape: landscape,
            promptValue: prompt,
            setPrompt: appState.setPrompt),
        NegativePromptField(
            landscape: landscape,
            negativePromptValue: negativePrompt,
            setNegativePrompt: appState.setNegativePrompt),
        if (landscape) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    ShowAdvancedOptionsButton(landscape: landscape),
                    /*
                    ToggleSwitch(
                        value: appState.useAdvanced,
                        setValue: appState.setUseAdvanced,
                        label: "Advanced"),*/
                    ToggleSwitch(
                        value: appState.usePreview,
                        setValue: appState.setUsePreview,
                        label: "Preview"),
                    ToggleSwitch(
                        value: appState.useNsfw,
                        setValue: appState.setUseNsfw,
                        label: "NSFW"),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () => appState.generate(context),
                      child: Text('Generate')),
                  if (connected && channel != null) ...[
                    Text("Connected"),
                  ] else ...[
                    Text("Not connected"),
                  ],
                ],
              ),
            ],
          )
        ] else ...[
          ElevatedButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: AdvancedColumn(
                        landscape: landscape,
                      ),
                    );
                  }),
              child: Text("Show Advanced")),
          ToggleSwitch(
              value: appState.usePreview,
              setValue: appState.setUsePreview,
              label: "Preview"),
          ToggleSwitch(
              value: appState.useNsfw,
              setValue: appState.setUseNsfw,
              label: "NSFW"),
          ElevatedButton(
              onPressed: () => appState.generate(context),
              child: Text('Generate')),
          Column(
            children: [
              if (connected && channel != null) ...[
                Text("Connected"),
              ] else ...[
                Text("Not connected"),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
