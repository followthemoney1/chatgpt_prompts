import 'package:chatgpt_prompts/localization/app_localizations_utils.dart';
import 'package:chatgpt_prompts/ui/theme/app_theme.dart';
import 'package:chatgpt_prompts/ui/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppCommentBar extends StatefulWidget {
  const AppCommentBar({
    super.key,
    required this.onTapSend,
    required this.controller,
  });

  final VoidCallback onTapSend;
  final TextEditingController controller;

  @override
  State<AppCommentBar> createState() => _AppCommentBarState();
}

class _AppCommentBarState extends State<AppCommentBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dimens = AppTheme.dimens;
    return Padding(
      padding: EdgeInsets.all(dimens.spacingM),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: widget.controller,
              hintText: appLocalizations.commentBarHint,
            ),
          ),
          Gap(dimens.spacingM),
          IconButton(
            onPressed: widget.onTapSend,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
