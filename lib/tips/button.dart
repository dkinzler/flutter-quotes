import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample/theme/theme.dart';
import 'package:flutter_sample/tips/bloc/bloc.dart';
import 'package:flutter_sample/tips/bloc/events.dart';
import 'package:flutter_sample/tips/bloc/state.dart';

class TipButton extends StatefulWidget {
  final Tip tip;

  final Widget? dialogTitle;
  final Widget dialogContent;
  final AlignmentGeometry dialogAlignment;

  final void Function(TipDialogResult)? onClose;

  final bool showDisableTipsCheckbox;

  const TipButton({
    Key? key,
    required this.tip,
    this.dialogTitle,
    required this.dialogContent,
    this.onClose,
    this.dialogAlignment = Alignment.center,
    this.showDisableTipsCheckbox = true,
  }) : super(key: key);

  @override
  State<TipButton> createState() => _TipButtonState();
}

class _TipButtonState extends State<TipButton> {
  late final TipsBloc tipsBloc;

  @override
  void initState() {
    super.initState();
    tipsBloc = context.read<TipsBloc>();
    if (tipsBloc.shouldAutomaticallyShowTip(widget.tip)) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => showTipDialog(userInitiated: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.lightbulb_outline),
      label: const Text('Tip'),
      onPressed: () => showTipDialog(),
    );
  }

  Future<void> showTipDialog({bool userInitiated = true}) async {
    tipsBloc
        .add(TipOpened(tip: widget.tip, openedAutomatically: !userInitiated));
    var result = await showDialog<TipDialogResult>(
      context: context,
      builder: (context) {
        return TipDialog(
          title: widget.dialogTitle,
          content: widget.dialogContent,
          alignment: widget.dialogAlignment,
          showDisableTipsCheckbox: widget.showDisableTipsCheckbox,
        );
      },
      barrierColor: Colors.black87,
    );
    tipsBloc.add(TipClosed(tip: widget.tip));
    if (result != null) {
      if (result.dontShowAgain) {
        tipsBloc.add(const TipSettingsChanged(showTips: false));
      }
    }
    widget.onClose?.call(result ?? const TipDialogResult());
  }
}

class TipDialogResult extends Equatable {
  final bool dontShowAgain;

  const TipDialogResult({
    this.dontShowAgain = false,
  });

  @override
  List<Object?> get props => [dontShowAgain];
}

class TipDialog extends StatefulWidget {
  final Widget? title;
  final Widget content;
  final AlignmentGeometry? alignment;

  final bool showDisableTipsCheckbox;

  final double maxDialogWidth;

  const TipDialog({
    Key? key,
    this.title,
    required this.content,
    this.alignment,
    required this.showDisableTipsCheckbox,
    this.maxDialogWidth = 400,
  }) : super(key: key);

  @override
  State<TipDialog> createState() => _TipDialogState();
}

class _TipDialogState extends State<TipDialog> {
  bool disableTipsCheckboxValue = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: widget.alignment,
      title: widget.title ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lightbulb_outline),
              SizedBox(width: context.sizes.spaceS),
              const Text('Tip'),
            ],
          ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.sizes.scaled(widget.maxDialogWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.content,
            if (widget.showDisableTipsCheckbox) ...[
              SizedBox(height: context.sizes.spaceM),
              CheckboxListTile(
                value: disableTipsCheckboxValue,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      disableTipsCheckboxValue = value;
                    });
                  }
                },
                title: const Text('Don\'t show me any more tips'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text('Got it'),
          onPressed: () => Navigator.of(context).pop<TipDialogResult>(
              TipDialogResult(dontShowAgain: disableTipsCheckboxValue)),
        ),
      ],
    );
  }
}
