import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:metro_drone/metro_drone.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _metroDrone = MetroDrone();
  bool isPlaying = false;
  int sliderBmp = 120;
  int currentTick = 0;
  // time signature
  int numerator = 4;
  int denominator = 4;


  @override
  void initState() {
    super.initState();
    _metroDrone.listenToStateUpdates();
    _metroDrone.currentTickStream.listen((value) {
      currentTick = value;
      setState(() {});
    });
    _metroDrone.isPlayingStream.listen((value) {
      isPlaying = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _metroDrone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<int>(
                stream: _metroDrone.bpmStream,
                builder: (context, snapshot) {
                  return Text(
                    "BPM: ${snapshot.data ?? _metroDrone.bpm}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }
              ),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  numerator,
                  (index) => GestureDetector(
                    onTap: () {},
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 75),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: currentTick == index ? Colors.green : null,
                        border: Border.all(
                          color:
                              currentTick == index ? Colors.green : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
              Slider(
                value: sliderBmp.toDouble(),
                max: 240,
                min: 40,
                onChanged: (value) {
                  sliderBmp = value.toInt();
                  setState(() {});
                },
                onChangeEnd: (value) {
                  print("Change End: ${value.toInt()}");
                  _metroDrone.setBpm(value.toInt());
                },
              ),
              const SizedBox(height: 100),
              const Text("Time Signature:"),
              Row(
                children: [
                  SelectWidget(
                    values: List.generate(
                      16,
                      (index) => index + 1,
                    ),
                    value: numerator,
                    onChanged: (value) {
                      numerator = value;
                      setState(() {});
                      _metroDrone.setTimeSignatureBpm(
                        numerator: numerator,
                        denominator: denominator,
                      );
                    },
                  ),
                  SelectWidget(
                    values: const [1, 2, 4, 8],
                    value: denominator,
                    onChanged: (value) {
                      denominator = value;
                      setState(() {});
                      _metroDrone.setTimeSignatureBpm(
                        numerator: numerator,
                        denominator: denominator,
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (isPlaying) {
                        _metroDrone.stop();
                      } else {
                        _metroDrone.start();
                      }
                    },
                    child: isPlaying ? const Text("Stop") : const Text("Play"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _metroDrone.tap();
                    },
                    child: const Text("Tap"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef MenuEntry = DropdownMenuEntry<int>;

class SelectWidget extends StatelessWidget {
  final List<int> values;
  final int value;
  final ValueChanged<int> onChanged;

  const SelectWidget({
    super.key,
    required this.values,
    required this.value,
    required this.onChanged,
  });

  List<MenuEntry> get menuEntries => UnmodifiableListView<MenuEntry>(
        values.map<MenuEntry>(
          (int name) => MenuEntry(value: name, label: name.toString()),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      initialSelection: value,
      onSelected: (int? value) {
        if (value != null) {
          onChanged(value);
        }
      },
      dropdownMenuEntries: menuEntries,
    );
    ;
  }
}
