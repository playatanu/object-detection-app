import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';

import 'package:vision_app/utils/recognitionsToOutput.dart';
import 'package:vision_app/widgets/clickableText.dart';
import 'package:vision_app/data/modelMetaData.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts = FlutterTts();
  ModelObjectDetection? currentModel;
  ModelMetaData? currentModelMetaData;

  List<CameraDescription>? cameras;
  CameraController? cameraController;

  XFile? imageFile;
  String? displayOutputText = '';
  bool isCameraActive = false;
  int activeCamera = 0;
  int currentModelIndex = 0;

  bool isProcessing = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.bottom]);

    loadModel(modelMetaData[0]);
    initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraActive) {
      return const Center(child: CircularProgressIndicator());
    }

    final screenSize = MediaQuery.of(context).size;
    final cameraPreviewSize = screenSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        maintainBottomViewPadding: true,
        top: true,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Atanu AI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'EN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Mode: ${currentModelMetaData?.name} Detection',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: GestureDetector(
                  onHorizontalDragEnd: onSwapCameraScreen,
                  onLongPress: takePicture,
                  child: SizedOverflowBox(
                    size: Size(cameraPreviewSize, cameraPreviewSize),
                    alignment: Alignment.center,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(
                          cameraController!,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          child: Text(
                            textAlign: TextAlign.center,
                            displayOutputText!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white54,
                              backgroundColor: Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 20,
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: modelMetaData.map((model) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ClickableText(
                                text: model.name,
                                onTap: () => loadModel(model),
                                isActive: model.id == currentModelMetaData!.id,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 50,
                          ),
                          IconButton(
                            onPressed: takePicture,
                            style: IconButton.styleFrom(
                                iconSize: 55,
                                backgroundColor: isProcessing
                                    ? Colors.white70
                                    : Colors.white),
                            icon: const Icon(Icons.circle),
                            color: Colors.black,
                          ),
                          IconButton(
                            onPressed: switchCamera,
                            iconSize: 18,
                            style: IconButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(31, 255, 255, 255)),
                            icon: const Icon(Icons.cameraswitch_outlined),
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const Row()
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }

  Future<void> loadModel(ModelMetaData model) async {
    try {
      currentModelMetaData = model;
      currentModel = await FlutterPytorch.loadObjectDetectionModel(
          model.modelPath, model.nc, 640, 640,
          labelPath: model.labelPath);

      flutterTts.speak(model.name);
      log('switched to ${model.name} detection!');

      setState(() {});
    } catch (error) {
      log(error.toString());
    }
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(
          cameras![activeCamera], ResolutionPreset.high,
          fps: 30);

      await cameraController?.initialize();

      cameraController!.value =
          cameraController!.value.copyWith(previewSize: const Size(640, 640));

      isCameraActive = true;

      setState(() {});
    } catch (error) {
      log(error.toString());
    }
  }

  void switchCamera() {
    activeCamera = activeCamera == 0 ? 1 : 0;
    initializeCamera();
    flutterTts.speak('camera switched!');
    log("camera switched!");
  }

  void takePicture() async {
    if (isProcessing) {
      log('please wait');
      flutterTts.speak('please wait');
      return;
    }

    isProcessing = true;
    vibrate();
    Audio.load('assets/sounds/camera.wav')
      ..play()
      ..dispose();

    displayOutputText = '';
    imageFile = null;
    setState(() {});

    if (!cameraController!.value.isInitialized) {
      flutterTts.speak('camera not initialized');
      return;
    }

    imageFile = await cameraController!.takePicture();

    List<ResultObjectDetection?> recognitions = await currentModel!
        .getImagePrediction(await File(imageFile!.path).readAsBytes(),
            minimumScore: 0.65, IOUThershold: 0.3);

    String output = recognitionsToOutput(recognitions);
    flutterTts.speak(output);

    displayOutputText = output;
    isProcessing = false;
    setState(() {});
  }

  void onSwapCameraScreen(DragEndDetails details) {
    int maxLength = modelMetaData.length;
    int currentModelIndex = currentModelMetaData!.id - 1;

    // Swiping in right direction.
    if (details.primaryVelocity! > 0) {
      if (currentModelIndex == maxLength - 1) {
        currentModelIndex = -1;
      }
      ModelMetaData model = modelMetaData[currentModelIndex + 1];
      loadModel(model);
      log('right');
    }

    // Swiping in left direction.
    else if (details.primaryVelocity! < 0) {
      if (currentModelIndex == 0) {
        currentModelIndex = maxLength;
      }
      ModelMetaData model = modelMetaData[currentModelIndex - 1];
      loadModel(model);
      log('left');
    }
  }

  static Future<void> vibrate() async {
    log('vibrating');
    await SystemChannels.platform.invokeMethod<void>('HapticFeedback.vibrate');
  }
}
