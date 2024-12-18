import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:metro_drone/metro_drone.dart';
import 'package:metro_drone/models/subdivision.dart';
import 'package:metro_drone/models/tick_type.dart';

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
  Subdivision? selectedSubdivision;
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  String? selectValue;
  bool isPlaying = false;
  int sliderBmp = 120;
  int currentTick = 0;

  // time signature
  int numerator = 4;
  int denominator = 4;

  @override
  void initState() {
    selectValue = list.first;
    selectedSubdivision = _metroDrone.subdivisions.first;
    _metroDrone.listenToStateUpdates();
    _metroDrone.stateStream.listen((event) {
      final subdivisionMap = event['subdivision'].cast<String, dynamic>();
      final subdivision = Subdivision.fromMap(subdivisionMap);
      print("SUBDIVISION: $subdivision");
    });
    _metroDrone.currentTickStream.listen((value) {
      currentTick = value;
      setState(() {});
    });
    _metroDrone.subdivisionStream.listen((value) {
      print("Subdivision Changed: $value");
      selectedSubdivision = value;
      setState(() {});
    });
    _metroDrone.isPlayingStream.listen((value) {
      isPlaying = value;
      setState(() {});
    });
    super.initState();
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
                  }),
              const SizedBox(height: 100),
              StreamBuilder<List<TickType>>(
                  stream: _metroDrone.tickTypesStream,
                  builder: (context, snapshot) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        numerator,
                        (index) {
                          final tickTypes =
                              snapshot.data ?? _metroDrone.tickTypes;
                          final tickColor = tickTypes[index].color;
                          final backgroundColor =
                              currentTick == index && isPlaying
                                  ? tickColor
                                  : Colors.transparent;
                          return GestureDetector(
                            onTap: () {
                              _metroDrone.setNextTickType(tickIndex: index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              constraints: const BoxConstraints(maxHeight: 75),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                border: Border.all(color: tickColor, width: 2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
              StreamBuilder<int>(
                stream: _metroDrone.bpmStream,
                builder: (context, snapshot) {
                  return Slider(
                    value: snapshot.data?.toDouble() ?? 120,
                    max: 400,
                    min: 20,
                    onChanged: (value) {
                      _metroDrone.setBpm(value.toInt());
                      setState(() {});
                    },
                  );
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
              const Text("Subdivision:"),
              DropDown<Subdivision>(
                selectedValue: selectedSubdivision,
                values: _metroDrone.subdivisions,
                onChanged: (value) {
                  if (value != null) {
                    _metroDrone.setSubdivision(value);
                  }
                },
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

class DropDown<T> extends StatelessWidget {
  final T? selectedValue;
  final List<T> values;
  final ValueChanged<T?> onChanged;

  const DropDown({
    super.key,
    required this.selectedValue,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: selectedValue,
      items: values
          .map(
            (value) => DropdownMenuItem<T>(
              value: value,
              child: Text(value.toString()),
            ),
          )
          .toList(),
      onChanged: onChanged,
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
  }
}

extension TickTypeColor on TickType {
  Color get color {
    return switch (this) {
      TickType.silence => Colors.grey,
      TickType.regular => Colors.blue,
      TickType.accent => Colors.orange,
      TickType.strongAccent => Colors.red,
    };
  }
}
