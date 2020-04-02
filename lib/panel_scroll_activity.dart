import 'package:flutter/material.dart';

class PanelIdleScrollActivity extends IdleScrollActivity {
	/// Creates a scroll activity that does nothing.
	PanelIdleScrollActivity(ScrollActivityDelegate delegate) : super(delegate);

	@override
	void applyNewDimensions() {
//		delegate.goBallistic(0.0);
	}
}

class PanelBallisticScrollActivity extends BallisticScrollActivity {
	/// Creates an activity that animates a scroll view based on a [simulation].
	///
	/// The [delegate], [simulation], and [vsync] arguments must not be null.
	PanelBallisticScrollActivity(
			ScrollActivityDelegate delegate,
			Simulation simulation,
			TickerProvider vsync,
			) : super(delegate, simulation, vsync);

	@override
	void applyNewDimensions() {
//		delegate.goBallistic(velocity);
	}
}