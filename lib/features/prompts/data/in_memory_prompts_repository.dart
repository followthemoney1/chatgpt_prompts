import 'dart:math';

import 'package:chatgpt_prompts/core/data/openai/model/openai_chat_completion_transformers.dart';
import 'package:chatgpt_prompts/core/domain/model/id.dart';
import 'package:chatgpt_prompts/core/utils/either_extensions.dart';
import 'package:chatgpt_prompts/core/utils/logging.dart';
import 'package:chatgpt_prompts/features/prompts/domain/model/execute_prompt_failure.dart';
import 'package:chatgpt_prompts/features/prompts/domain/model/prompt.dart';
import 'package:chatgpt_prompts/features/prompts/domain/model/prompt_execution_request.dart';
import 'package:chatgpt_prompts/features/prompts/domain/model/prompt_template_variable.dart';
import 'package:chatgpt_prompts/features/prompts/domain/repositories/prompts_repository.dart';
import 'package:chatgpt_prompts/features/prompts/domain/use_cases/execute_prompt_use_case.dart';
import 'package:chatgpt_prompts/features/prompts/domain/use_cases/get_prompts_list_use_case.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InMemoryPromptsRepository implements PromptsRepository {
  const InMemoryPromptsRepository();

  static const defaultMaxTokens = 2048;

  static const defaultCompletionModel = 'text-davinci-003';
  static const defaultChatModel = 'gpt-3.5-turbo';
  static final _templates = [
    Prompt(
      name: 'Create greeting',
      template: '''
      create a greeting message to the user that said the following
       ```{{greeting}}```
      make the response with {{format}} format
      '''
          .trim(),
      id: const Id('id-greeting'),
      createdAtUtc: DateTime.now().toIso8601String(),
      updatedAtUtc: DateTime.now().toIso8601String(),
      description: 'Creates greeting in specified format',
      variables: const [
        PromptTemplateVariable(
          slug: 'greeting',
          description: 'What user has said?',
        ),
        PromptTemplateVariable(
          slug: 'format',
          description: 'What format to output in?',
        ),
      ],
    ),
    Prompt(
      name: 'Create user object',
      template: '''
Create new User entity class in {{language}}. It needs to contain the following fields: username, id, roles, permissions. Wrap result into github markdown syntax with language hint'''
          .trim(),
      id: const Id('id-greeting'),
      createdAtUtc: DateTime.now().toIso8601String(),
      updatedAtUtc: DateTime.now().toIso8601String(),
      description: 'Creates user object in specified language',
      variables: const [
        PromptTemplateVariable(
          slug: 'language',
          description: 'What format to output in?',
        ),
      ],
    ),
  ];

  @override
  Future<GetPromptsListResult> getPromptsList() async {
    //ignore: no-magic-number
    await Future.delayed(Duration(milliseconds: Random().nextInt(1000)));
    return success([..._templates]);
  }

  @override
  Stream<ExecutePromptResult> executePrompt({
    required PromptExecutionRequest request,
  }) async* {
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY'] ?? (throw 'Missing OpenAI api key');

    // final models = await OpenAI.instance.model.list();
    // debugPrint(models.map((e) => e.id).join('\n'));
    // try {
    // yield* OpenAI.instance.completion
    //     .createStream(
    //   model: defaultCompletionModel,
    //   prompt: 'Create a JSON for a user object consisting of username, id, roles, and permissions.',
    //   maxTokens: defaultMaxTokens,
    // )
    //     .handleError((error) {
    //   logError(error);
    //   return failure(ExecutePromptFailure.unknown(error));
    // }).map((event) => success(event.toChatCompletionResult()));
    // } catch (ex, stack) {
    //   logError(ex, stack);
    // }
    const model = defaultChatModel;
    yield* OpenAI.instance.chat.createStream(
      model: model,
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: request.compileTemplate(),
        ),
      ],
    ).handleError((error) {
      logError(error);
      return failure(ExecutePromptFailure.unknown(error));
    }).map((event) {
      return success(event.toChatCompletionResult(model));
    });
  }
}
