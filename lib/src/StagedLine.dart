import 'dart:ui';
import 'package:flutter/material.dart';

/// Animated widget for displaying the current stages of a process.
///
/// The `StagedLine` class provides an easy way to visualize the current stage
/// of a process. Each stage is represented by an enumeration (`Enum`) value and
/// can be supplemented with a name and a color. Transitions between stages are
/// accompanied by smooth animations, including color changes and resizing of
/// the active stage marker.
///
/// ### Key Features:
/// - Display stages of a process with labels.
/// - Support for custom colors for each stage.
/// - Smooth animations for transitions between stages.
///
/// ### Example Usage:
///
/// ```dart
/// enum ProcessStage { preparing, processing, completed }
///
/// StagedLine<ProcessStage>(
///   stageState: ProcessStage.processing,
///   stagesNames: {
///     ProcessStage.preparing: 'Preparing',
///     ProcessStage.processing: 'Processing',
///     ProcessStage.completed: 'Completed',
///   },
///   stagesColors: {
///     ProcessStage.preparing: Colors.blue,
///     ProcessStage.processing: Colors.orange,
///     ProcessStage.completed: Colors.green,
///   },
///   animationDuration: Duration(milliseconds: 500),
/// );
/// ```
///
/// ### Constructor Parameters:
/// - [stageState]: The current process state. Specifies the stage to highlight.
///   This is a value from the enumeration [T].
/// - [stagesNames]: A map where each enumeration value [T] corresponds to a stage name.
///   Used to display text below the stage marker. If a stage is not specified, an empty string is displayed.
/// - [stagesColors]: (Optional) A map where each enumeration value [T] corresponds to a color.
///   If not provided, all stages will use the default color: [Colors.green].
/// - [animationDuration]: (Optional) The duration of the animation for transitions between stages.
///   Default value: 450 milliseconds.
///
/// ### Animations:
/// - Transitions between stages include a smooth color change for the line.
/// - The size of the active stage marker increases to emphasize the current stage.
///
/// ### Notes:
/// - The type [T] must be an enumeration (`Enum`).
/// - The [stagesNames] map should contain keys for all possible values of [T]. If any values are missing,
///   empty strings will be displayed for those stages.
/// - If the [stagesColors] map is not provided or does not include specific keys,
///   the default color ([Colors.green]) will be used for those stages.
class StagedLine<T extends Enum> extends StatefulWidget {

  final T stageState;
  final Map<T, String> stagesNames;
  final Map<T, Color>? stagesColors;
  final Duration animationDuration;

  const StagedLine({
    super.key,
    required this.stageState,
    required this.stagesNames,
    this.stagesColors,
    this.animationDuration = const Duration(milliseconds: 450),
  });

  @override
  State<StatefulWidget> createState() => _StagedLineState<T>();

}

class _StagedLineState<T extends Enum> extends State<StagedLine> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;
  late Map<int, Color> _colors;

  T? previousStage;
  T? currentStage;

  @override
  void initState() {
    super.initState();

    currentStage = widget.stageState as T;

    _colors = widget.stagesColors?.map((stage, color) => MapEntry(stage.index, color)) ?? {};

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..addListener((){ setState(() {}); });

    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _controller.value = 1.0;

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StagedLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.stageState != currentStage){
      previousStage = currentStage;
      currentStage = widget.stageState as T;
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomPaint(
          size: const Size(double.infinity, 18),
          painter: _StagedLinePainter(
            animationValue: _animation.value,
            stageCount: widget.stagesNames.length,
            currentStage: widget.stageState.index,
            previousStage: previousStage?.index,
            colors: _colors
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: widget.stagesNames.values.map(
            (text) => Expanded(
              flex: 1,
              child: Text(
                text,
                textAlign: TextAlign.center,
                //style: Theme.of(context).textTheme.labelSmall,
              )
            )
          ).toList()
        ),
      ],
    );
  }

}

class _StagedLinePainter extends CustomPainter {

  double animationValue;
  int stageCount;
  int currentStage;
  int? previousStage;
  Map<int, Color> colors;

  _StagedLinePainter({
    required this.animationValue,
    required this.stageCount,
    required this.currentStage,
    required this.previousStage,
    required this.colors,
  });

  //static const _activePointMultiplier = 1.25;

  final pointPaint = Paint()
    ..isAntiAlias = true
    ..color = Colors.green
    ..style = PaintingStyle.fill
    ..strokeWidth = 4.0;

  final linePaint = Paint()
    ..isAntiAlias = true
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0;

  @override
  void paint(Canvas canvas, Size size) {

    final painterWidth = size.width;
    final painterHeight = size.height;

    final stageLength = painterWidth / stageCount;
    final stageCenter = stageLength / 2;
    final offsetY = painterHeight / 2;
    final pointRadius = offsetY;
    final activePointRadius = offsetY / 4;

    //background line
    canvas.drawLine(
      Offset(0, offsetY),
      Offset(painterWidth, offsetY),
      linePaint..color = Colors.grey
    );

    //foreground line
    final padLeftCurrent = currentStage * stageLength;
    final offsetXCurrent = stageCenter + padLeftCurrent + (currentStage == stageCount - 1 ? stageCenter : 0);

    final padLeftPrevious = (previousStage ?? 0) * stageLength;
    final offsetXPrevious = stageCenter + padLeftPrevious;

    final offsetX = lerpDouble(offsetXPrevious, offsetXCurrent, animationValue)?.toDouble() ?? 0;
    final foregroundLineColor = Color.lerp(
      colors[previousStage] ?? Colors.grey,
      colors[currentStage] ?? Colors.green,
      animationValue
    ) ?? Colors.green;

    canvas.drawLine(
      Offset(0, offsetY),
      Offset(offsetX, offsetY),
      linePaint..color = foregroundLineColor
    );

    //drawing stage circles, with animated in-out
    for(int i = 0; i < stageCount; i++){

      final isActive = currentStage == i;
      final wasActive = (previousStage ?? -1) == i;

      final padLeft = i * stageLength;
      final offsetX = stageCenter + padLeft;

      Color color = Colors.grey;
      double radius = pointRadius;

      if(isActive){
        radius = pointRadius + activePointRadius * animationValue;
        color = Color.lerp(
          Colors.grey,
          colors[i] ?? Colors.green,
          animationValue
        ) ?? Colors.grey;
      }

      if(wasActive){
        radius = pointRadius + activePointRadius * (1 - animationValue);
        color = Color.lerp(
          colors[previousStage] ?? Colors.green,
          Colors.grey,
          animationValue
        ) ?? Colors.grey;
      }

      if(i < currentStage){
        //color = colors[i] ?? Colors.green;

        color = Color.lerp(
            colors[previousStage] ?? Colors.green,
            colors[currentStage] ?? Colors.green,
            animationValue
        ) ?? Colors.grey;

      }else{

      }

      canvas.drawCircle(
        Offset(offsetX, offsetY),
        radius,
        pointPaint..color = color
      );

    }

  }

  @override
  bool shouldRepaint(covariant _StagedLinePainter oldDelegate) {
    return oldDelegate.currentStage != currentStage;
  }

}