import 'dart:async';
import 'dart:typed_data';

import 'package:analog_clock/drawn_hand.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'clock_dail.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

final radiansPerTick = radians(360 / 60);

final radiansPerHour = radians(360 / 12);

class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;
  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;
  ui.Image image;
  TextStyle textStyle = TextStyle(fontSize: 0.0);
  bool isImageloaded = false;
  String textureName = "assets/ice_texture.jpg";
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
    getImageFromAsset();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  getImageFromAsset() async {
    image = await load(textureName);
    textStyle = await textureText();
    setState(() {
      isImageloaded = true;
    });
  }

  Future<ui.Image> load(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  Future<TextStyle> textureText() async {
    Float64List matrix4 = new Matrix4.identity().storage;
    return TextStyle().copyWith(
      fontFamily: 'SnowtopCaps',
        fontSize: 25,
        height: 1.2,
        fontWeight: FontWeight.bold,
        foreground: Paint()
          ..shader =
              ImageShader(image, TileMode.repeated, TileMode.repeated, matrix4));
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hms().format(_now);

    return Stack(
      children: <Widget>[
        Container(
            height: double.infinity,
            width: double.infinity,
            // child: SvgPicture.asset('assets/snow1.svg'),
            child: Image.asset(
              'assets/snow2.png',
              // repeat: ImageRepeat.repeatY,
              fit: BoxFit.fitWidth,
            ),),
        Row(
          children: <Widget>[
            Expanded(
                flex: 6,
                child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      // color: Colors.blue,
                      // boxShadow: [
                      //   BoxShadow(offset: Offset(0, 10), color: Colors.blue),
                      //   BoxShadow(offset: Offset(10, 0.0), color: Colors.white)
                      // ],
                      // image: DecorationImage(
                      //     // colorFilter: ColorFilter.mode(
                      //     //     Colors.blue, BlendMode.colorDodge),
                      //     image: AssetImage(
                      //       'assets/background.jpg',
                      //     ),
                      //     repeat: ImageRepeat.repeat),
                      shape: BoxShape.circle,
                      // gradient: RadialGradient(colors: [
                      //   Colors.transparent,
                      //   Colors.blue,
                      //   Colors.transparent,
                      //   Colors.white10,
                      //   Colors.transparent
                      // ]),
                      // backgroundBlendMode: BlendMode.hardLight,
                      border: Border.all(
                          style: BorderStyle.solid,
                          color: Colors.blue[100],
                          width: 5),
                    ),
                    child: CustomPaint(
                      painter: ClockDialPainter(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          DrawnHand(
                            angleRadians: _now.second * radiansPerTick,
                            color: Colors.blue,
                            size: .9,
                            thickness: 4,
                          ),
                          DrawnHand(
                            angleRadians: _now.minute * radiansPerTick,
                            color: Colors.blueAccent,
                            size: .8,
                            thickness: 10,
                          ),
                          DrawnHand(
                            angleRadians: _now.hour * radiansPerHour +
                                (_now.minute / 60) * radiansPerHour,
                            color: Colors.blueAccent,
                            size: .5,
                            thickness: 15,
                          ),
                          // ContainerHand(
                          //   color: Colors.transparent,
                          //   size: 0.6,
                          //   angleRadians: 27,
                          //   child: Transform.translate(
                          //     offset: Offset(0.0, -60.0),
                          //     child: Container(
                          //       width: 25,
                          //       height: 150,
                          //       decoration: BoxDecoration(
                          //           color: Colors.blue,
                          //           // backgroundBlendMode: BlendMode.colorDodge,
                          //           gradient: LinearGradient(
                          //             colors: [Colors.blue[100],Colors.white,Colors.blue[100]]
                          //           ),
                          //           borderRadius: BorderRadius.circular(10)),
                          //     ),
                          //   ),
                          // ),
                          Container(
                            alignment: Alignment.center,
                            height: 40,
                            width:40,
                            decoration: BoxDecoration(
                                gradient: RadialGradient(colors: [
                                  Colors.white,
                                  Colors.blue,
                                  Colors.white
                                ]),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 2,
                                    color: Colors.blueAccent,
                                  ),
                                  BoxShadow(
                                    blurRadius: 2,
                                    color: Colors.white,
                                  ),
                                ],
                                color: Colors.red,
                                shape: BoxShape.circle),
                          )
                          // CustomPaint(
                          //   painter: _CenterCicle(),
                          //   child: Container(),
                          // )
                        ],
                      ),
                    ))),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: DefaultTextStyle(
                  style: textStyle,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.
                    start,
                    children: <Widget>[
                      Text(
                        _temperature,
                        style: TextStyle(),
                      ),
                      Text(_condition),
                      Text(_temperatureRange),
                      Text(_location),
                      Text(time),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DrawTimer extends CustomPainter {
  Paint _paint = Paint();

  _DrawTimer() {
    _paint.color = Colors.red;
  }
  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
    Path _path = Path();
    canvas.drawCircle(center, 20, _paint);

    print(size.width);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
