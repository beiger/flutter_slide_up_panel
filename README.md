# flutterslideuppanel

A new Flutter plugin.

## capture

![image](https://github.com/beiger/flutter_slide_up_panel/blob/master/gif/2.gif)

## Getting Started

first, init PanelController:
```dart
PanelController({
		@required this.minHeight,  // double
		@required this.maxHeight, //double
		this.initialOpen = false,
		@required this.vsync // TickerProvider
	})
```
second, use SlideUpPanel:
```dart
SlideUpPanel({
		@required this.body, //Widget, 
		@required this.head, //Widget, the head of the panel
		@required this.panel, // Widget, the body of the panel, if the panel is scrollable, donot set ScrollController for the panel
		@required this.controller});
```

for example:
```dart
class ScrollableTestState extends State<ScrollableTest> with TickerProviderStateMixin {
	PanelController _controller;

	@override
	void initState() {
		super.initState();
		_controller = PanelController(
				minHeight: 56,
				maxHeight: 500,
				vsync: this
		);
	}

	@override
	void dispose() {
		super.dispose();
		_controller.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return SlideUpPanel(
			body: Container(color: Colors.white),
			head: Container(height: 56, width: double.infinity, color: Colors.green),
			panel: _panel(),
			controller: _controller,
		);
	}

	Widget _panel() {
		return CustomScrollView(
			physics: BouncingScrollPhysics(),
			slivers: <Widget>[
				```
			],
		);
	}
}
```


