import 'package:flutter/material.dart';
import 'package:flutterslideuppanel/panel_controller.dart';
import 'package:flutterslideuppanel/panel_scroll_position.dart';

class SlideUpPanel extends StatefulWidget {
	final Widget body;
	final Widget head;
	//如果是scrollable，不要设置controller
	final Widget panel;
	final PanelController controller;

	SlideUpPanel({
		@required this.body,
		@required this.head,
		@required this.panel,
		@required this.controller});

	@override
	SlideUpPanelState createState() => new SlideUpPanelState();
}

class SlideUpPanelState extends State<SlideUpPanel> {
	PanelController _lastPanelController;
	PanelScrollController _scrollController;

	@override
	void initState() {
		super.initState();
		_lastPanelController = widget.controller;
		_lastPanelController.addListener(() {
			setState(() {
			});
		});
		_scrollController = PanelScrollController(_lastPanelController);
	}


	@override
	void didUpdateWidget(SlideUpPanel oldWidget) {
		super.didUpdateWidget(oldWidget);
		print("-----didUpdateWidget: ");
		_updateController();
	}


	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		print("-----didChangeDependencies: ");
		_updateController();
	}

	_updateController() {
		if (_lastPanelController != widget.controller) {
			widget.controller.addListener(() {
				setState(() {
				});
			});
			widget.controller.absorb(_lastPanelController);
			_scrollController.updatePanelController(widget.controller);
			if (_lastPanelController.isFling()) {
				widget.controller.goBallistic(0);
			}
			_lastPanelController.dispose();
			_lastPanelController = widget.controller;
		}
	}

	@override
	Widget build(BuildContext context) {
		return Stack(
			children: <Widget>[
				widget.body,
				Positioned(
					left: 0,
					right: 0,
					bottom: 0,
					child: _buildPanel(),
				)
			],
		);
	}

	Widget _buildPanel() {
		if (widget.panel is ScrollView) {
			return PrimaryScrollController(
				child: Container(
					height: widget.controller.height,
					width: double.infinity,
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
						boxShadow: [
							BoxShadow(
								color: Colors.grey[200],
								offset: Offset(-0, -1.0),
								blurRadius: 10.0,
								spreadRadius: 1.0
							)
						]
					),
					child: SizedBox(
						height: widget.controller.maxHeight,
						width: double.infinity,
						child: Column(
							children: <Widget>[
								GestureDetector(
									behavior: HitTestBehavior.opaque,
									onVerticalDragDown: (details) {
										widget.controller.cancelCurrentAnimation();
									},
									onVerticalDragUpdate: (details) {
										if (details?.delta == null) return;
										widget.controller.consume(details.delta.dy);
									},
									onVerticalDragEnd: (details) {
										widget.controller.goBallistic(-details.velocity.pixelsPerSecond.dy);
									},
									onVerticalDragCancel: () {
										widget.controller.goBallistic(0);
									},
									child: Container(
										width: double.infinity,
										child: widget.head,
									),
								),
								Expanded(
									child: widget.panel,
								)
							],
						),
					),
				),
				controller: _scrollController,
			);
		} else {
			return GestureDetector(
				behavior: HitTestBehavior.opaque,
				child: Container(
					height: widget.controller.height,
					width: double.infinity,
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
						boxShadow: [
							BoxShadow(
								color: Colors.grey[200],
								offset: Offset(0, -1.0),
								blurRadius: 10.0,
								spreadRadius: 1.0
							)
						]
					),
					child: SizedBox(
						height: widget.controller.maxHeight,
						width: double.infinity,
						child: Column(
							children: <Widget>[
								widget.head,
								Expanded(
									child: widget.panel,
								)
							],
						),
					),
				),
				onVerticalDragDown: (details) {
					widget.controller.cancelCurrentAnimation();
				},
				onVerticalDragUpdate: (details) {
					if (details?.delta == null) return;
					widget.controller.consume(details.delta.dy);
				},
				onVerticalDragEnd: (details) {
					widget.controller.goBallistic(-details.velocity.pixelsPerSecond.dy);
				},
				onVerticalDragCancel: () {
					widget.controller.goBallistic(0);
				},
			);
		}
	}
}