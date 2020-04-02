import 'package:flutter/material.dart';
import 'package:flutterslideuppanel_example/normal_test.dart';
import 'package:flutterslideuppanel_example/scrollable_test.dart';

void main() {
	runApp(MyApp());
}

class MyApp extends StatefulWidget {
	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

	@override
	void initState() {
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			home: ScrollableTest(),
//			home: NormalTest(),
		);
	}
}
