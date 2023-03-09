import 'package:flutter/material.dart';
import 'package:hard_diffusion/api/network_service.dart';
import 'package:hard_diffusion/main.dart';
import 'package:html/parser.dart';

class TextToImageFormState extends ChangeNotifier {
  TextToImageFormState() {
    prompt = prefs!.getString("prompt") ?? "";
    negativePrompt = prefs!.getString("negativePrompt") ?? "";
    seed = prefs!.getInt("seed") ?? 0;
    useAdvanced = prefs!.getBool("useAdvanced") ?? false;
    useMultipleModels = prefs!.getBool("useMultipleModels") ?? false;
    useNsfw = prefs!.getBool("useNsfw") ?? false;
    usePreview = prefs!.getBool("usePreview") ?? false;
    useRandomSeed = prefs!.getBool("useRandomSeed") ?? false;
    width = prefs!.getInt("width") ?? 512;
    height = prefs!.getInt("height") ?? 512;
    inferenceSteps = prefs!.getInt("inferenceSteps") ?? 50;
    guidanceScale = prefs!.getDouble("guidanceScale") ?? 7.5;

    notifyListeners();
    //connect();
  }

  var ns = NetworkService();
  final inferenceFormKey = GlobalKey<FormState>();
  String prompt = "";
  String negativePrompt = "";
  int seed = 0;
  bool useAdvanced = false;
  bool useMultipleModels = false;
  bool useNsfw = false;
  bool usePreview = false;
  bool useRandomSeed = false;
  int width = 512;
  int height = 512;
  int inferenceSteps = 50;
  double guidanceScale = 7.5;

  void setPrompt(value) {
    prompt = value;
    prefs!.setString("prompt", prompt);
    notifyListeners();
  }

  void setNegativePrompt(value) {
    negativePrompt = value;
    prefs!.setString("negativePrompt", negativePrompt);
    notifyListeners();
  }

  void setUseMultipleModels(value) {
    useMultipleModels = value;
    prefs!.setBool("useMultipleModels", useMultipleModels);
    notifyListeners();
  }

  void setUseNsfw(value) {
    useNsfw = value;
    prefs!.setBool("useNsfw", useNsfw);
    notifyListeners();
  }

  void setUseAdvanced(value) {
    useAdvanced = value;
    prefs!.setBool("useAdvanced", useAdvanced);
    notifyListeners();
  }

  void setUsePreview(value) {
    usePreview = value;
    prefs!.setBool("usePreview", usePreview);
    notifyListeners();
  }

  void setUseRandomSeed(value) {
    useRandomSeed = value;
    prefs!.setBool("useRandomSeed", useRandomSeed);
    notifyListeners();
  }

  void setSeed(value) {
    seed = value;
    prefs!.setInt("seed", seed);
    notifyListeners();
  }

  void setWidth(value) {
    width = value;
    prefs!.setInt("width", width);
    notifyListeners();
  }

  void setHeight(value) {
    height = value;
    prefs!.setInt("height", height);
    notifyListeners();
  }

  void setInferenceSteps(value) {
    inferenceSteps = value;
    prefs!.setInt("inferenceSteps", inferenceSteps);
    notifyListeners();
  }

  void setGuidanceScale(value) {
    guidanceScale = value;
    prefs!.setDouble("guidanceScale", guidanceScale);
    notifyListeners();
  }

  void generate() async {
    if (inferenceFormKey.currentState!.validate()) {
      inferenceFormKey.currentState!.save();
      var map = new Map<String, dynamic>();
      map["prompt"] = prompt;
      map["negative_prompt"] = negativePrompt;
      map["use_multiple_models"] = useMultipleModels ? "true" : "";
      map["use_nsfw"] = useNsfw ? "true" : "";
      map["use_preview"] = usePreview ? "true" : "";
      map["use_random_seed"] = useRandomSeed ? "true" : "";
      map["seed"] = seed.toString();
      map["width"] = width.toString();
      map["height"] = height.toString();
      map["num_inference_steps"] = inferenceSteps.toString();
      map["guidance_scale"] = guidanceScale.toString();
      var response = await ns.get("$apiHost/csrf");
      var document = parse(response);
      var csrf = document.querySelectorAll("input").first.attributes["value"];
      map["csrfmiddlewaretoken"] = csrf;
      ns.headers["X-CSRFToken"] = csrf!;
      response = await ns.post(
        "$apiHost/api/v1/images",
        body: map,
      );
    }
  }
}
