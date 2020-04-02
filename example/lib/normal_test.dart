
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterslideuppanel/panel_controller.dart';
import 'package:flutterslideuppanel/slide_up_panel.dart';

class NormalTest extends StatefulWidget {
	@override
	State<StatefulWidget> createState() {
		return NormalTestState();
	}
}

class NormalTestState extends State<NormalTest> with TickerProviderStateMixin {
	PanelController _controller;

	StreamController _streamController;

	@override
	void initState() {
		super.initState();
		_controller = PanelController(
				minHeight: 56,
				maxHeight: 650,
				vsync: this
		);
		_streamController = StreamController<int>();
		_controller.addListener(() {
			_streamController.sink.add(_controller.height.toInt());
		});
	}

	@override
	void dispose() {
		super.dispose();
		_controller.dispose();
		_streamController.close();
	}

	@override
	Widget build(BuildContext context) {
		return SlideUpPanel(
			body: _body(),
			head: _head(),
			panel: _panel(),
			controller: _controller,
		);
	}

	Widget _body() {
		return Container(
			color: Colors.white,
			width: double.infinity,
			child: Column(
				children: <Widget>[
					SizedBox(height: 64,),
					StreamBuilder(
						initialData: _controller.height,
						stream: _streamController.stream,
						builder: (context, snapshot) {
							return Text(
								"height: ${snapshot.data}",
								style: Theme.of(context).textTheme.bodyText1,
							);
						},
					),

				],
			),
		);
	}

	Widget _head() {
		return SizedBox(
			height: 56,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.center,
				mainAxisAlignment: MainAxisAlignment.start,
				children: <Widget>[
					SizedBox(height: 8,),
					Container(
							height: 2,
							width: 48,
							color: Colors.grey[300]
					),
					SizedBox(height: 10,),
					Text(
						"drag me",style: Theme.of(context).textTheme.headline6,
					),
				],
			),
		);
	}

	Widget _panel() {
		return Padding(
			padding: EdgeInsets.fromLTRB(2, 24, 2, 24),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceAround,
				children: <Widget>[
					_image("build", Icons.build, Colors.red),
					_image("des", Icons.description, Colors.yellow),
					_image("adb", Icons.adb, Colors.green),
					_image("see", Icons.visibility, Colors.blue),
				],
			),
		);
	}

	Widget _image(String label, IconData icon, Color color){
		return Column(
			children: <Widget>[
				Container(
					padding: const EdgeInsets.all(16.0),
					child: Icon(
						icon,
						color: Colors.white,
					),
					decoration: BoxDecoration(
							color: color,
							shape: BoxShape.circle,
							boxShadow: [BoxShadow(
								color: Color.fromRGBO(0, 0, 0, 0.15),
								blurRadius: 8.0,
							)]
					),
				),
				SizedBox(height: 12.0,),
				Text(
					label,
					style: Theme.of(context).textTheme.subtitle1,
				),
			],

		);
	}
}
