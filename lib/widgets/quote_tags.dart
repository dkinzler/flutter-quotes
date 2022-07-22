import 'package:flutter/material.dart';
import 'package:flutter_sample/theme/theme.dart';

//TODO show an animation here
class QuoteTagList extends StatefulWidget {
  final List<String> tags;
  //max number of tags to show, if there are more there will be a button to show all
  //if -1 show all tags by default
  final int maxTagsToShow;
  final void Function(String tag)? onTagPressed;

  const QuoteTagList({
    Key? key,
    required this.tags,
    required this.maxTagsToShow,
    this.onTagPressed,
  }) : super(key: key);

  @override
  State<QuoteTagList> createState() => _QuoteTagListState();
}

class _QuoteTagListState extends State<QuoteTagList> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.tags.isEmpty) {
      return const Text('No tags');
    }

    var maxTagsToShow = widget.maxTagsToShow;
    if (widget.maxTagsToShow <= 0 || expanded) {
      maxTagsToShow = widget.tags.length;
    }

    var chips = widget.tags
        .take(maxTagsToShow)
        .map<Widget>((t) => InputChip(
              label: Text(
                t,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: widget.onTagPressed != null
                  ? () {
                      widget.onTagPressed?.call(t);
                    }
                  : null,
            ))
        .toList();

    //TODO this logic is not as easy to follow

    var hasMoreTagsToShow = maxTagsToShow < widget.tags.length;
    if (hasMoreTagsToShow) {
      chips.add(InputChip(
        label: const Text('Show more'),
        onPressed: () {
          setState(() {
            expanded = true;
          });
        },
      ));
    }

    if (expanded) {
      chips.add(InputChip(
        label: const Text('Show less'),
        onPressed: () {
          setState(() {
            expanded = false;
          });
        },
      ));
    }

    return Wrap(
      spacing: context.sizes.spaceS,
      runSpacing: context.sizes.spaceS,
      children: chips,
    );
  }
}
