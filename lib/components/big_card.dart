import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      elevation: 5,
      color: theme.colorScheme.primary, //Color(0xFFA0FF00), //Color.fromRGBO(
      // 0, 255, 0, 1.0), //Colors.amber, //theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asPascalCase /*pair.asLowerCase*/,
          style: style,
          // For screenreadeers if text was lower case.
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}
