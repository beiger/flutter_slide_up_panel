import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterslideuppanel/panel_controller.dart';
import 'package:flutterslideuppanel/panel_scroll_activity.dart';

class PanelScrollController extends ScrollController {
	PanelController panelController;

	PanelScrollController(this.panelController): super();

	ScrollPosition createScrollPosition(
			ScrollPhysics physics,
			ScrollContext context,
			ScrollPosition oldPosition,
			) {
		return PanelScrollPosition(
			physics: physics,
			context: context,
			initialPixels: initialScrollOffset,
			keepScrollOffset: keepScrollOffset,
			oldPosition: oldPosition,
			debugLabel: debugLabel,
			panelController: panelController
		);
	}

	void updatePanelController(PanelController newPanelController) {
		if (panelController != newPanelController) {
			this.panelController = newPanelController;
			(position as PanelScrollPosition).panelController = newPanelController;
		}
	}
}

class PanelScrollPosition extends ScrollPosition implements ScrollActivityDelegate {
	PanelController panelController;

	PanelScrollPosition({
		@required ScrollPhysics physics,
		@required ScrollContext context,
		double initialPixels = 0.0,
		bool keepScrollOffset = true,
		ScrollPosition oldPosition,
		String debugLabel,
		@required this.panelController
	}) : super(
		physics: physics,
		context: context,
		keepScrollOffset: keepScrollOffset,
		oldPosition: oldPosition,
		debugLabel: debugLabel,
	) {
		// If oldPosition is not null, the superclass will first call absorb(),
		// which may set _pixels and _activity.
		if (pixels == null && initialPixels != null)
			correctPixels(initialPixels);
		if (activity == null)
			goIdle();
		assert(activity != null);
	}

	/// Velocity from a previous activity temporarily held by [hold] to potentially
	/// transfer to a next activity.
	double _heldPreviousVelocity = 0.0;

	@override
	AxisDirection get axisDirection => context.axisDirection;

	@override
	double setPixels(double newPixels) {
		print("-----setPixels: $newPixels");
		assert(activity.isScrolling);
		return super.setPixels(newPixels);
	}

	@override
	void absorb(ScrollPosition other) {
		super.absorb(other);
		if (other is! PanelScrollPosition) {
			goIdle();
			return;
		}
		activity.updateDelegate(this);
		final PanelScrollPosition typedOther = other as PanelScrollPosition;
		_userScrollDirection = typedOther._userScrollDirection;
		assert(_currentDrag == null);
		if (typedOther._currentDrag != null) {
			_currentDrag = typedOther._currentDrag;
			_currentDrag.updateDelegate(this);
			typedOther._currentDrag = null;
		}
	}

	@override
	void applyNewDimensions() {
		super.applyNewDimensions();
//		context.setCanDrag(physics.shouldAcceptUserOffset(this));
		context.setCanDrag(true);
	}

	@override
	void beginActivity(ScrollActivity newActivity) {
		_heldPreviousVelocity = 0.0;
		if (newActivity == null)
			return;
		assert(newActivity.delegate == this);
		super.beginActivity(newActivity);
		_currentDrag?.dispose();
		_currentDrag = null;
		if (!activity.isScrolling)
			updateUserScrollDirection(ScrollDirection.idle);
	}

	@override
	void applyUserOffset(double delta) {
		updateUserScrollDirection(delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);

		 panelConsume(delta);
	}

	void panelConsume(double delta) {
		if (delta <= 0) { // 向上滑动
			var remain = delta - panelController.consume(delta);
			setPixels(pixels - physics.applyPhysicsToUserOffset(this, remain));
		} else { //向下滑动
			var overscroll = setPixels(pixels - physics.applyPhysicsToUserOffset(this, delta));
			panelController.consume(-overscroll);
		}
	}

	@override
	void goIdle() {
		beginActivity(PanelIdleScrollActivity(this));
	}

	/// Start a physics-driven simulation that settles the [pixels] position,
	/// starting at a particular velocity.
	///
	/// This method defers to [ScrollPhysics.createBallisticSimulation], which
	/// typically provides a bounce simulation when the current position is out of
	/// bounds and a friction simulation when the position is in bounds but has a
	/// non-zero velocity.
	///
	/// The velocity should be in logical pixels per second.
	@override
	void goBallistic(double velocity) {
		assert(pixels != null);
		if(!panelController.canFling(velocity, this)) {
			final Simulation simulation = physics.createBallisticSimulation(this, velocity);
			if (simulation != null) {
				beginActivity(PanelBallisticScrollActivity(this, simulation, context.vsync));
			} else {
				goIdle();
			}
		} else {
			goIdle();
			panelController.goBallistic(velocity);
		}
	}

	@override
	ScrollDirection get userScrollDirection => _userScrollDirection;
	ScrollDirection _userScrollDirection = ScrollDirection.idle;

	/// Set [userScrollDirection] to the given value.
	///
	/// If this changes the value, then a [UserScrollNotification] is dispatched.
	@protected
	@visibleForTesting
	void updateUserScrollDirection(ScrollDirection value) {
		assert(value != null);
		if (userScrollDirection == value)
			return;
		_userScrollDirection = value;
		didUpdateScrollDirection(value);
	}

	@override
	Future<void> animateTo(
			double to, {
				@required Duration duration,
				@required Curve curve,
			}) {
		print("-----animateTo");
		if (nearEqual(to, pixels, physics.tolerance.distance)) {
			// Skip the animation, go straight to the position as we are already close.
			jumpTo(to);
			return Future<void>.value();
		}

		final DrivenScrollActivity activity = DrivenScrollActivity(
			this,
			from: pixels,
			to: to,
			duration: duration,
			curve: curve,
			vsync: context.vsync,
		);
		beginActivity(activity);
		return activity.done;
	}

	@override
	void jumpTo(double value) {
		print("-----jumpTo: $value");
		goIdle();
		if (pixels != value) {
			final double oldPixels = pixels;
			forcePixels(value);
			notifyListeners();
			didStartScroll();
			didUpdateScrollPositionBy(pixels - oldPixels);
			didEndScroll();
		}
		goBallistic(0.0);
	}

	@Deprecated('This will lead to bugs.') // ignore: flutter_deprecation_syntax, https://github.com/flutter/flutter/issues/44609
	@override
	void jumpToWithoutSettling(double value) {
		goIdle();
		if (pixels != value) {
			final double oldPixels = pixels;
			forcePixels(value);
			notifyListeners();
			didStartScroll();
			didUpdateScrollPositionBy(pixels - oldPixels);
			didEndScroll();
		}
	}

	@override
	ScrollHoldController hold(VoidCallback holdCancelCallback) {
		panelController.cancelCurrentAnimation();
		final double previousVelocity = activity.velocity;
		final HoldScrollActivity holdActivity = HoldScrollActivity(
			delegate: this,
			onHoldCanceled: holdCancelCallback,
		);
		beginActivity(holdActivity);
		_heldPreviousVelocity = previousVelocity;
		return holdActivity;
	}

	ScrollDragController _currentDrag;

	@override
	Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
		final ScrollDragController drag = ScrollDragController(
			delegate: this,
			details: details,
			onDragCanceled: dragCancelCallback,
			carriedVelocity: physics.carriedMomentum(_heldPreviousVelocity),
			motionStartDistanceThreshold: physics.dragStartDistanceMotionThreshold,
		);
		beginActivity(DragScrollActivity(this, drag));
		assert(_currentDrag == null);
		_currentDrag = drag;
		return drag;
	}

	@override
	void dispose() {
		_currentDrag?.dispose();
		_currentDrag = null;
		super.dispose();
	}

	@override
	void debugFillDescription(List<String> description) {
		super.debugFillDescription(description);
		description.add('${context.runtimeType}');
		description.add('$physics');
		description.add('$activity');
		description.add('$userScrollDirection');
	}
}