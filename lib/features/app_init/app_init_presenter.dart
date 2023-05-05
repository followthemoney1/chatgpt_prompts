import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatgpt_prompts/core/domain/model/user.dart';
import 'package:chatgpt_prompts/core/domain/stores/user_store.dart';
import 'package:chatgpt_prompts/core/domain/use_cases/app_init_use_case.dart';
import 'package:chatgpt_prompts/core/utils/bloc_extensions.dart';
import 'package:chatgpt_prompts/core/utils/either_extensions.dart';
import 'package:chatgpt_prompts/core/utils/mvp_extensions.dart';
import 'package:chatgpt_prompts/features/app_init/app_init_navigator.dart';
import 'package:chatgpt_prompts/features/app_init/app_init_presentation_model.dart';
import 'package:chatgpt_prompts/features/chats/chat/chat_initial_params.dart';

class AppInitPresenter extends Cubit<AppInitViewModel> with SubscriptionsMixin<AppInitViewModel> {
  AppInitPresenter(
    AppInitPresentationModel super.model,
    this.navigator,
    this.appInitUseCase,
    this.userStore,
  ) {
    listenTo<User>(
      subscriptionId: 'user',
      stream: userStore.stream,
      onChange: (user) => emit(_model.copyWith(user: user)),
    );
  }

  final AppInitNavigator navigator;
  final AppInitUseCase appInitUseCase;
  final UserStore userStore;

  AppInitPresentationModel get _model => state as AppInitPresentationModel;

  Future<void> onInit() async {
    await appInitUseCase
        .execute() //
        .observeStatusChanges((result) => emit(_model.copyWith(appInitResult: result)))
        .doOn(
      fail: (fail) {
        navigator.showError(fail.displayableFailure());
      },
      success: (success) {
        navigator.openMain(const ChatInitialParams());
      },
    );
  }
}
