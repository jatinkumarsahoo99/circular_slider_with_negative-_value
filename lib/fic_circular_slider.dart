import 'package:flutter/material.dart';
import 'circular_slider_widgets.dart';
import 'constant.dart';

class FICCircularSlider extends StatefulWidget {
  FICCircularSlider(
      {super.key,
      this.size = 270,
      this.progressBarWidth = 20,
      this.centerCircleColor = Colors.black12,
      this.sliderBarColor = Colors.black26,
      this.trackGradientColors1,
      this.trackGradientColors2,
      this.triangleThumbColor = Colors.teal,
      this.progressGradientColors1 = Colors.teal,
      this.progressGradientColors2 = Colors.teal,
      required this.minProgress,
      required this.maxProgress,
      required this.progress,
      this.startAngle = 0,
      this.endAngle = 360,
      this.thumbSize = 8,
      this.isTablet = false,
      this.isThumbInvisible = false,
      this.onEnd,
      required this.builder});
  final double size;
  final double progressBarWidth;
  final Color centerCircleColor;
  final Color sliderBarColor;
  final Color? trackGradientColors1;
  final Color? trackGradientColors2;
  final Color triangleThumbColor;
  final Color progressGradientColors1;
  final Color progressGradientColors2;
  double minProgress;
  double maxProgress;
  double progress = 0;
  final double startAngle;
  final double endAngle;
  final double thumbSize;
  final bool isTablet;
  final bool isThumbInvisible;
  final Widget Function(BuildContext, double, Widget?) builder;
  final void Function()? onEnd;

  @override
  _FICCircularSliderState createState() => _FICCircularSliderState();
}

class _FICCircularSliderState extends State<FICCircularSlider> {
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);

  @override
  void initState() {
    setValue();
    super.initState();
  }

  setValue() {
    Future.delayed(Duration.zero).then((value) {
      setState(() {
        widget.maxProgress = widget.maxProgress - widget.minProgress;
        widget.progress = widget.progress - widget.minProgress;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            height: widget.size - (widget.progressBarWidth + 20),
            width: widget.size - (widget.progressBarWidth + 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular((widget.size - widget.progressBarWidth) / 2),
              color: widget.centerCircleColor,
            ),
          ),

          /// Bar/Dash slider.
          CircularSliderWidgets(
            trackGradientColors: [widget.sliderBarColor, widget.sliderBarColor],
            maxProgress: widget.maxProgress,
            minProgress: 0,
            //widget.minProgress,
            interactive: false,
            width: widget.size - (widget.progressBarWidth + (isTablet ? 50 : 40)),
            height: widget.size - (widget.progressBarWidth + (isTablet ? 50 : 40)),
            progress: widget.progress,
            barWidth: isTablet ? 15 : 25,
            strokeCap: StrokeCap.butt,
            progressGradientColors: [widget.sliderBarColor, widget.sliderBarColor],
            dashWidth: 1,
            dashGap: 45,
            animation: false,
            startAngle: 0,
            sweepAngle: widget.endAngle,
          ),

          /// Progress slider
          CircularSliderWidgets(
            progress: widget.progress,
            trackGradientColors: [
              widget.trackGradientColors1 ?? Colors.grey.shade200,
              widget.trackGradientColors2 ?? Colors.grey.shade200
            ],
            maxProgress: widget.maxProgress,
            minProgress: 0,
            //widget.minProgress,
            interactive: false,
            barWidth: widget.progressBarWidth,
            trackColor: Colors.black54,
            width: widget.size,
            height: widget.size,
            animation: false,
            animDurationMillis: 200,
            startAngle: (widget.maxProgress == widget.progress) ? 3 : widget.startAngle,
            sweepAngle: widget.endAngle,
            strokeCap: StrokeCap.butt,
            innerThumbRadius: 12,
            innerThumbStrokeWidth: 2,
            innerThumbColor: Colors.transparent,
            outerThumbRadius: 10,
            outerThumbStrokeWidth: 10,
            outerThumbColor: Colors.transparent,
            valueNotifier: _valueNotifier,
            progressGradientColors: [widget.progressGradientColors1, widget.progressGradientColors2],
          ),

          /// Thumb slider.
          CircularSliderWidgets(
            trackGradientColors: const [Colors.transparent, Colors.transparent],
            maxProgress: widget.maxProgress,
            minProgress: 0,
            //widget.minProgress,
            interactive: true,
            progress: widget.progress,
            width: widget.size - (widget.progressBarWidth + 50),
            height: widget.size - (widget.progressBarWidth + 50),
            animation: false,
            animDurationMillis: 200,
            startAngle: widget.startAngle,
            sweepAngle: widget.endAngle,
            outerThumbRadius: widget.isThumbInvisible ? 0 : 7,
            outerThumbStrokeWidth: widget.isThumbInvisible ? 0 : widget.thumbSize,
            outerThumbColor: widget.triangleThumbColor,
            onProgressChanged: (double? value) {
              setState(() {
                widget.progress = (value ?? 0).ceilToDouble();
                // TODO Commenting this line as unable to reach to the max progress using thumb
                // TODO it stops scrolling at 99. so using ceilToDouble rater than the ceilToDouble
                //  widget.progress = (value ?? 0).floorToDouble();
              });
            },
            onEnd: widget.onEnd,
            progressGradientColors: const [Colors.transparent, Colors.transparent],
            child: Center(
              child: ValueListenableBuilder(valueListenable: _valueNotifier, builder: widget.builder),
            ),
          ),
        ],
      ),
    );
  }
}
