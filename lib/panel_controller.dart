import 'package:flutter/cupertino.dart';

class PanelController extends ValueNotifier<double> {
	double minHeight;
	double maxHeight;
	bool initialOpen;
	
	TickerProvider vsync;

	PanelController({
		@required this.minHeight,
		@required this.maxHeight,
		this.initialOpen = false,
		@required this.vsync
	}) : super(initialOpen ? maxHeight : minHeight);

	double get height => value;
	set height(double h) {
		value = h;
	}

	void absorb(PanelController oldController) {
		height = oldController.height;
	}

	//返回消耗了多少
	double consume(double delta) {
		double consumer = 0;
		var newHeight = height - delta;
		var newHeightClamp = newHeight.clamp(minHeight, maxHeight);
		if (newHeightClamp != height) {
			consumer = height - newHeightClamp;
			height = newHeightClamp;
		}
		return consumer;
	}

	AnimationController _currentAniController;

	bool canFling(double velocity, ScrollPosition position) {
		if (velocity == 0) {
			return height != minHeight && height != maxHeight;
		} else if (velocity > 0) {
			return height != maxHeight;
		} else {
			if (height != minHeight && height != maxHeight) {
				return true;
			} else if (height == minHeight) {
				return false;
			} else {
				return position.pixels <= position.minScrollExtent;
			}
		}
	}

	bool isFling() {
		return _currentAniController != null;
	}
	
	void goBallistic(double velocity) {
		if (_currentAniController != null) return;
		double dest;
		if (velocity == 0) {
			dest = height < (minHeight + maxHeight) / 2 ? minHeight : maxHeight;
		} else if (velocity > 0) {
			dest = maxHeight;
		} else {
			dest = minHeight;
		}
		if (height == dest) return;
		double milliSecond = (dest - height).abs() * 300 / (maxHeight - minHeight);
		_currentAniController = AnimationController(duration: Duration(milliseconds: milliSecond.toInt()), vsync: vsync);
		var animation = Tween(begin: height, end: dest).animate(CurvedAnimation(
			parent: _currentAniController,
			curve: Curves.easeOutCubic
		));
		animation.addListener(() {
			height = animation.value;
		});
		animation.addStatusListener((status) {
			if (status == AnimationStatus.completed) {
				_currentAniController?.dispose();
				_currentAniController = null;
			}
		});
		_currentAniController.forward();
	}

	void cancelCurrentAnimation() {
		_currentAniController?.stop();
		_currentAniController?.dispose();
		_currentAniController = null;
	}

	void open() {
		goBallistic(1);
	}

	void close() {
		goBallistic(-1);
	}

	@override
	void dispose() {
		super.dispose();
		cancelCurrentAnimation();
	}
}