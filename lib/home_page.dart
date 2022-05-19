import 'dart:ui';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef JSON = Map<String, dynamic>;
List<Task> tasks = [];

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // OverlayEntry _getEntry(context) {
  //   late OverlayEntry entry;
  //   entry = OverlayEntry(
  //     opaque: false,
  //     maintainState: true,
  //     builder: (_) => TextEditor(
  //       onTap: () {
  //         entry.remove();
  //       },
  //     ),
  //   );
  //   return entry;
  // }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    // Color primaryColor = theme.primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text('TODO List', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                    actions: [
                      // IconButton(
                      //   onPressed: () async {
                      //     // Overlay.of(context)!.insert(_getEntry(context));
                      //     // Navigator.of(context).push(
                      //     //   HeroDialogRoute(
                      //     //     builder: (context) => Center(
                      //     //       child: TextEditor(
                      //     //         onTap: () {},
                      //     //       ),
                      //     //     ),
                      //     //   ),
                      //     // );
                      //     // IconData? icon = await FlutterIconPicker.showIconPicker(
                      //     //     context,
                      //     //     iconPackMode: IconPack.cupertino,
                      //     //     adaptiveDialog: true,
                      //     //     iconColor: Theme.of(context).accentColor);
                      //     // debugPrint('Picked Icon:  $icon');
                      //   },
                      //   icon: Icon(CupertinoIcons.add),
                      //   splashRadius: 20,
                      // ),
                    ],
                    floating: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        Task task = tasks[index];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                setState(() {
                                  tasks[index].isDone = !task.isDone;
                                  save();
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                        value: task.isDone,
                                        onChanged: (value) {
                                          setState(() {
                                            tasks[index].isDone = !task.isDone;
                                            save();
                                          });
                                        },
                                        visualDensity: theme.visualDensity,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5))),
                                    Text(
                                      task.task,
                                      style: theme.textTheme.subtitle1,
                                    ),
                                    Spacer(),
                                    Icon(
                                      task.icon,
                                      color: task.color,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                      childCount: tasks.length,
                    ),
                  )
                ],
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Spacer(),
                    GestureDetector(
                      onTap: () async {
                        Task? newTask = await Navigator.of(context)
                            .push(
                              HeroDialogRoute(
                                builder: (context) => Center(
                                  child: TextEditor(),
                                ),
                              ),
                            )
                            .then((value) => value);

                        if (newTask != null) {
                          setState(() {
                            tasks.add(newTask);
                          });
                          await save();
                        } else {
                          return;
                        }
                      },
                      child: Hero(
                        tag: 'textField',
                        createRectTween: (begin, end) {
                          return CustomRectTween(begin: begin!, end: end!);
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Write a new task',
                              style: TextStyle(
                                color: theme.textTheme.bodyText2!.color!
                                    .withOpacity(0.5),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> save() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String json = jsonEncode(tasks.map((e) => e.toJson()).toList());

  await prefs.setString('tasks', json);
}

Future<void> read() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getString('tasks') != null) {
    String json = prefs.getString('tasks')!;

    List<dynamic> data = jsonDecode(json);

    print(List.generate(data.length, (index) => Task.fromJson(data[index])));
    tasks = List.generate(data.length, (index) => Task.fromJson(data[index]));
  } else {
    return;
  }
}

class Task {
  String task;
  bool isDone;
  Color color;
  IconData icon;

  Task({
    required this.task,
    required this.isDone,
    required this.icon,
    required this.color,
  });

  factory Task.fromJson(JSON json) {
    print(json['icon']['codePoint']);
    print(json['icon']['fontFamily']);
    print(json['color']);
    return Task(
      color: Color(int.parse('0x' + json['color'])),
      task: json['task'],
      isDone: json['isDone'],
      icon: IconData(
        json['icon']['codePoint'],
        fontFamily: json['icon']['fontFamily'],
      ),
    );
  }

  JSON toJson() {
    return {
      'color': color.hexAlpha,
      'task': task,
      'isDone': isDone,
      'icon': {
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
      }
    };
  }
}

class TextEditor extends StatefulWidget {
  TextEditor({Key? key}) : super(key: key);

  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  IconData selectedIcon = CupertinoIcons.book_solid;
  Color dialogPickerColor = Color(0xff894BFC);
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'textField',
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
          // padding:  EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width * 0.2), vertical: 5),
          child: Material(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        autofocus: true,
                        maxLines: 1,
                        onSubmitted: (value) {
                          print(value);
                          Navigator.of(context).pop(Task(
                              task: value,
                              isDone: false,
                              icon: selectedIcon,
                              color: dialogPickerColor));
                        },
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(8),
                          hintText: 'Write a new task',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            IconData? icon =
                                await FlutterIconPicker.showIconPicker(
                              context,
                              // customIconPack: ,
                              iconPackModes: [IconPack.material],
                              // iconPackMode: IconPack.material,
                              adaptiveDialog: false,
                              iconPickerShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              iconColor: dialogPickerColor,
                            );
                            debugPrint('Picked Icon:  $icon');
                            setState(() {
                              selectedIcon = icon ?? CupertinoIcons.book_solid;
                            });
                          },
                          icon: Icon(
                            selectedIcon,
                            color: dialogPickerColor,
                          ),
                          splashRadius: 20,
                        ),
                        IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () async {
                            await colorPickerDialog();
                          },
                          icon: Icon(CupertinoIcons.circle_fill),
                          splashRadius: 20,
                          color: dialogPickerColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: dialogPickerColor,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) =>
          setState(() => dialogPickerColor = color),
      // width: 40,
      // height: 40,
      borderRadius: 16,
      showRecentColors: false,
      enableShadesSelection: false,

      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.headline5,
      ),

      customColorSwatchesAndNames: <ColorSwatch<Object>, String>{
        ColorTools.createPrimarySwatch(Color(0xff0163AE)): '',
        ColorTools.createPrimarySwatch(Color(0xff0163AE)): 'Dark Blue',
        ColorTools.createPrimarySwatch(Color(0xff038FFD)): 'Blue',
        ColorTools.createPrimarySwatch(Color(0xff00C0FF)): 'Light Blue',
        ColorTools.createPrimarySwatch(Color(0xff0AB9AF)): 'Teal',
        ColorTools.createPrimarySwatch(Color(0xff02B96D)): 'Green',
        ColorTools.createPrimarySwatch(Color(0xffDEBB10)): 'Yellow',
        ColorTools.createPrimarySwatch(Color(0xffFFF2AF)): 'Gold?',
        ColorTools.createPrimarySwatch(Color(0xffFF6B56)): 'Light Red',
        ColorTools.createPrimarySwatch(Color(0xffE80239)): 'Red',
        ColorTools.createPrimarySwatch(Color(0xffAC0F0D)): 'Dark Red',
        ColorTools.createPrimarySwatch(Color(0xffBF108D)): 'Dark Pink',
        ColorTools.createPrimarySwatch(Color(0xffF76EE8)): 'Pink',
        ColorTools.createPrimarySwatch(Color(0xff7A44FD)): 'Purple',
        ColorTools.createPrimarySwatch(Color(0xff4644FE)): 'Bluerple',
        ColorTools.createPrimarySwatch(Color(0xff9296A2)): 'Grey',
        ColorTools.createPrimarySwatch(Color(0xff7E7063)): 'Brown',
      },
      materialNameTextStyle: Theme.of(context).textTheme.caption,
      colorNameTextStyle: Theme.of(context).textTheme.caption,
      colorCodeTextStyle: Theme.of(context).textTheme.caption,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: false,
      },
    ).showPickerDialog(
      context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints:
          const BoxConstraints(minHeight: 70, minWidth: 100, maxWidth: 320),
    );
  }
}

/// {@template hero_dialog_route}
/// Custom [PageRoute] that creates an overlay dialog (popup effect).
///
/// Best used with a [Hero] animation.
/// {@endtemplate}
class HeroDialogRoute<T> extends PageRoute<T> {
  /// {@macro hero_dialog_route}
  HeroDialogRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  })  : _builder = builder,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}

/// {@template custom_rect_tween}
/// Linear RectTween with a [Curves.easeOut] curve.
///
/// Less dramatic that the regular [RectTween] used in [Hero] animations.
/// {@endtemplate}
class CustomRectTween extends RectTween {
  /// {@macro custom_rect_tween}
  CustomRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.easeOut.transform(t);
    return Rect.fromLTRB(
      lerpDouble(begin!.left, end!.left, elasticCurveValue)!,
      lerpDouble(begin!.top, end!.top, elasticCurveValue)!,
      lerpDouble(begin!.right, end!.right, elasticCurveValue)!,
      lerpDouble(begin!.bottom, end!.bottom, elasticCurveValue)!,
    );
  }
}
