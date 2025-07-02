class AiModel {
  final String? apiModel;
  final String nameModel;

  AiModel({required this.apiModel, required this.nameModel});
}

final List<AiModel> listModels = [
  AiModel(
    apiModel: null,
    nameModel: "Automatic ",
  ),
  AiModel(
    apiModel: "qwen/qwen3-32b:free",
    nameModel: "Qwen 3 32B",
  ),
  AiModel(
    apiModel: "meta-llama/llama-4-scout:free",
    nameModel: "Llama 4 Scout",
  ),
  AiModel(
    apiModel: "deepseek/deepseek-r1-0528-qwen3-8b:free",
    nameModel: "DeepSeek R1 Qwen3 8B",
  ),
  AiModel(
    apiModel: "deepseek/deepseek-r1-0528:free",
    nameModel: "DeepSeek R1 0528",
  ),
  AiModel(
    apiModel: "deepseek/deepseek-r1:free",
    nameModel: "DeepSeek R1",
  ),
  AiModel(
    apiModel: "google/gemini-2.0-flash-exp:free",
    nameModel: "Gemini 2.0 Flash",
  ),
];