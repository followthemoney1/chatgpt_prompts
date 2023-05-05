// ignore: unused_import
import 'dart:math';

import 'package:chatgpt_prompts/core/utils/mvp_extensions.dart';
import 'package:chatgpt_prompts/features/main/main_presentation_model.dart';
import 'package:chatgpt_prompts/features/main/main_presenter.dart';
import 'package:chatgpt_prompts/ui/widgets/app_comment_bar.dart';
import 'package:chatgpt_prompts/ui/widgets/chat_message_view.dart';
import 'package:chatgpt_prompts/ui/widgets/response_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainPage extends StatefulWidget with HasPresenter<MainPresenter> {
  const MainPage({
    required this.presenter,
    super.key,
  });

  @override
  final MainPresenter presenter;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with PresenterStateMixin<MainViewModel, MainPresenter, MainPage> {
  late TextEditingController _textEditingController;


  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _textEditingController.addListener(
      () => presenter.onTextChanged(_textEditingController.text),
    );
  }

  @override
  Widget build(BuildContext context) => stateListener(
        listener: (context, state) {
          if (_textEditingController.text != state.currentPrompt) {
            _textEditingController.text = state.currentPrompt;
          }
        },
        listenWhen: (previous, current) => previous.currentPrompt != current.currentPrompt,
        child: CallbackShortcuts(
          bindings: {
            LogicalKeySet(LogicalKeyboardKey.enter): () => presenter.onTapSend(),
          },
          child: Scaffold(
            // backgroundColor: AppTheme.colors.,
            body: stateObserver(
              builder: (context, state) {
                return Column(
                  children: [
                    Expanded(
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ListView.builder(
                            reverse: true,
                            clipBehavior: Clip.none,
                            shrinkWrap: true,
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) =>
                                ChatMessageView(message: state.messages.reversed.toList()[index]),
                          ),
                        ),
                      ),
                    ),
                    ResponseLoadingIndicator(
                      isLoading: state.isLoading,
                    ),
                    AppCommentBar(
                      onTapSend: () => presenter.onTapSend(),
                      controller: _textEditingController,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
}
