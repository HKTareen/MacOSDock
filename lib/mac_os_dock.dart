import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import 'custom_reorderable_wrap/lib/reorderables.dart';


class MacOsDock extends StatefulWidget {

  const MacOsDock({super.key});

  @override
  State<MacOsDock> createState() => _MacOsDockState();
}

class _MacOsDockState extends State<MacOsDock> {
  late int? hoveredIndex;
  late double baseItemHeight;
  late double baseTranslationY;
  late double verticlItemsPadding;
  double spacing = -20;
  bool isDragging = false;
  double getScalingSize(int index) {
    return getValue(
      index: index,
      baseValue: baseItemHeight,
      maxValue: 70,
      nonHoveredMaxValue: 70,
    );
  }

  double getYaxis(int index) {
    return getValue(
      index: index,
      baseValue: baseTranslationY,
      maxValue: -20,
      nonHoveredMaxValue: -20,
    );
  }

  double getValue({
    required int index,
    required double baseValue,
    required double maxValue,
    required double nonHoveredMaxValue,
  }) {
    late final double propertyValue;


    if (hoveredIndex == null) {
      return baseValue;
    }


    final difference = (hoveredIndex! - index).abs();


    const itemsAffected = 3;


    if (difference == 0) {
      propertyValue = maxValue;


    } else if (difference <= itemsAffected) {
      final ratio = (itemsAffected - difference) / itemsAffected;

      propertyValue = lerpDouble(baseValue, nonHoveredMaxValue, ratio)!;


    } else {
      propertyValue = baseValue;
    }

    return propertyValue;
  }
  int? _hoveredIndex; // Tracks the index of the hovered icon
  int? _draggedIndex;
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // Adjust for the placeholder position
      if (newIndex > oldIndex) newIndex--;

      // Reorder the list
      final icon = items.removeAt(oldIndex);
      items.insert(newIndex, icon);

      _draggedIndex = null; // Clear the dragged index after reordering
      isDragging = false;
    });
  }


  @override
  void initState() {
    super.initState();
    hoveredIndex = null;
    baseItemHeight = 60;

    verticlItemsPadding = 10;
    baseTranslationY = 0.0;
  }
  Path defaultTailBuilder(Offset tip, Offset point2, Offset point3) {
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(point2.dx, point2.dy)
      ..lineTo(point3.dx, point3.dy)
      ..close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.yellow.shade100,
        body: Center(
          child: MouseRegion(
            onEnter: (event){
              log('enter: ');

              setState(() {
                spacing = 0;
              });

            },onExit: (v){
            log('exit: ');

            setState(() {
              spacing = -20;
            });
          },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  height: baseItemHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient:  LinearGradient(

                          colors: [
                            Color(0xff808081).withOpacity(0.7),
                            Color(0xff808081)
                          ]),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(verticlItemsPadding),
                  // 1.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReorderableWrap(
                        scrollDirection: Axis.horizontal,
                        needsLongPressDraggable: false,
                        spacing: spacing,
                        runSpacing: 0.0,

                        padding: const EdgeInsets.all(8),
                        // buildItemsContainer: (c,v,list) {
                        //   // if(_draggedIndex != null){
                        //   // list.removeAt(_draggedIndex!);
                        //   // }
                        //   return Row(
                        //     children: [
                        //     ...List.generate(list.length, (i)=>list[i])
                        //   ],);
                        // },
                        buildDraggableFeedback: (c,bc,w) {
                          log('box Constraints: ${bc.maxHeight}');
                          return Opacity(opacity: 1,child: w,);
                        },
                        onReorderStarted: (index) {
                          setState(() {
                            isDragging = true;
                          });
                        },
                        onNoReorder: (index) {
                          setState(() {
                            isDragging = false;
                            _draggedIndex = null; // Clear the dragged index if no reorder occurs
                          });
                        },
                        reorderAnimationDuration: const Duration(milliseconds: 500),
                        scrollAnimationDuration: const Duration(milliseconds: 500),
                        onReorder: _onReorder,
                        children: List.generate(
                          items.length,
                              (index) {
                            // 2.
                            return MouseRegion(
                              key: ValueKey(items[index]['image']),
                              // cursor: SystemMouseCursors.click,

                              onEnter: ((event) {
                                log('event: $event');
                                if(!isDragging){
                                  setState(() {
                                    hoveredIndex = index;
                                  });
                                }


                                log('hover index: $hoveredIndex');
                              }),
                              onExit: (event) {
                                setState(() {
                                  hoveredIndex = null;
                                });
                              },
                              opaque: false,
                              // 3.
                              child: JustTheTooltip(
                                content:
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    items[index]['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                tailBuilder: defaultTailBuilder,
                                tailLength: 8,
                                tailBaseWidth: 20,
                                margin: const EdgeInsets.only(bottom: 15),
                                backgroundColor: Colors.black.withOpacity(.5),
                                preferredDirection: AxisDirection.up,
                                offset: 15,

                                child: AnimatedContainer(
                                  curve: Curves.linear,

                                  duration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  transform:

                                  isDragging ? null:
                                  (Matrix4.identity()
                                    ..translate(
                                      0.0,
                                      getYaxis(index),
                                      0.0,
                                    )),
                                  height:isDragging ? 60: getScalingSize(index),
                                  width: isDragging ? 60:  getScalingSize(index),

                                  alignment: AlignmentDirectional.bottomCenter,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  // 4.
                                  child: AnimatedDefaultTextStyle(
                                    curve: Curves.easeInOut,
                                    duration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    style: TextStyle(
                                      fontSize:  getScalingSize(index),
                                    ),
                                    child: Image.asset(items[index]['image']),
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

List items = [
  {"image":'assets/images/insta.png',"name":"Instagram"},
  {"image":'assets/images/music.png',"name":"Music"},
  {"image":'assets/images/safari.png',"name":"Safari"},
  {"image":'assets/images/voice.png',"name":"Voice"},
  {"image":'assets/images/zen.png',"name":"Zenmade"},
  {"image":'assets/images/ai.png',"name":"Illustrator"},
  {"image":'assets/images/pr.png',"name":"Premier"},
  {"image":'assets/images/android.png',"name":"Android Studio"},
];