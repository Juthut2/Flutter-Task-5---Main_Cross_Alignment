import 'package:flutter/material.dart';

const double _box = 60;
const _colors = [Colors.red, Colors.yellow, Colors.blue];

const _mains = <String, MainAxisAlignment>{
  'center': MainAxisAlignment.center,
  'spaceAround': MainAxisAlignment.spaceAround,
  'spaceBetween': MainAxisAlignment.spaceBetween,
  'spaceEvenly': MainAxisAlignment.spaceEvenly,
  'start': MainAxisAlignment.start,
  'end': MainAxisAlignment.end,
};

const _crosses = <String, CrossAxisAlignment>{
  'start': CrossAxisAlignment.start,
  'end': CrossAxisAlignment.end,
  'baseline': CrossAxisAlignment.baseline,
  'center': CrossAxisAlignment.center,
  'stretch': CrossAxisAlignment.stretch,
};

class _Example {
  final bool isRow;
  final bool isMain; // true = MainAxisAlignment demo, false = CrossAxisAlignment demo
  final MainAxisAlignment main;
  final CrossAxisAlignment cross;
  final String name;

  const _Example({
    required this.isRow,
    required this.isMain,
    required this.main,
    required this.cross,
    required this.name,
  });

  String get label =>
      isMain ? 'MainAxisAlignment.$name' : 'CrossAxisAlignment.$name';
  String get widgetName => isRow ? 'Row' : 'Column';
}

class AlignmentDemo extends StatefulWidget {
  const AlignmentDemo({super.key});

  @override
  State<AlignmentDemo> createState() => _AlignmentDemoState();
}

class _AlignmentDemoState extends State<AlignmentDemo> {
  int index = 0;

  late final List<_Example> examples = _buildExamples();

  List<_Example> _buildExamples() {
    final list = <_Example>[];

    void addMain(bool isRow) {
      _mains.forEach((name, value) {
        list.add(_Example(
          isRow: isRow,
          isMain: true,
          main: value,
          cross: CrossAxisAlignment.center,
          name: name,
        ));
      });
    }

    void addCross(bool isRow) {
      _crosses.forEach((name, value) {
        // baseline only works in a Row
        if (!isRow && value == CrossAxisAlignment.baseline) return;
        list.add(_Example(
          isRow: isRow,
          isMain: false,
          main: MainAxisAlignment.center,
          cross: value,
          name: name,
        ));
      });
    }

    // Same pairing as the reference first:
    addMain(true); // MainAxisAlignment in a Row
    addCross(false); // CrossAxisAlignment in a Column
    // Then the swapped ones, so both widgets are covered:
    addMain(false); // MainAxisAlignment in a Column
    addCross(true); // CrossAxisAlignment in a Row
    return list;
  }

  List<Widget> _boxes(_Example e) {
    final stretch = !e.isMain && e.cross == CrossAxisAlignment.stretch;
    final baseline = !e.isMain && e.cross == CrossAxisAlignment.baseline;
    final columnCross = !e.isMain && !e.isRow;

    // baseline: the letter sits at a different spot in each box, so Flutter
    // shifts the boxes until the letters line up (box size stays the same).
    const letterSpots = [
      Alignment.topCenter,
      Alignment.center,
      Alignment.bottomCenter,
    ];

    return List.generate(3, (i) {
      return Container(
        // inset from the edge, like the reference
        margin: columnCross ? const EdgeInsets.symmetric(horizontal: _box) : null,
        // always 60x60, except the stretch direction which must fill
        width: (stretch && !e.isRow) ? null : _box,
        height: (stretch && e.isRow) ? null : _box,
        color: _colors[i],
        alignment: baseline ? letterSpots[i] : null,
        child: baseline
            ? const Text('A', style: TextStyle(fontSize: 20, color: Colors.black))
            : null,
      );
    });
  }

  Widget _slide(_Example e) {
    final label = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: e.label, style: const TextStyle(fontSize: 14)),
          // delete this span if you only want the property name
          TextSpan(
            text: '\n${e.widgetName}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
    const gap = SizedBox(height: 16);

    // CrossAxisAlignment in a Column (the reference style):
    // label + boxes are children of the SAME Column, so the label moves too.
    if (!e.isMain && !e.isRow) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: e.cross,
        children: [label, gap, ..._boxes(e)],
      );
    }

    Widget demo;
    if (e.isMain) {
      demo = e.isRow
          ? Row(mainAxisAlignment: e.main, children: _boxes(e))
          : SizedBox(
              height: 320,
              child: Column(mainAxisAlignment: e.main, children: _boxes(e)),
            );
    } else {
      demo = SizedBox(
        height: 240,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: e.cross,
          textBaseline: TextBaseline.alphabetic,
          children: _boxes(e),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [label, gap, demo],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: const Text('TASK 5 - ROSALADA'),
      ),
      body: SizedBox.expand(child: _slide(examples[index])),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: index > 0 ? () => setState(() => index--) : null,
                child: const Text('Prev'),
              ),
              Text('${index + 1} / ${examples.length}'),
              TextButton(
                onPressed: index < examples.length - 1
                    ? () => setState(() => index++)
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}