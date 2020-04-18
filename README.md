# flutterslideuppanel

A new Flutter plugin.

## capture

![image](https://github.com/beiger/flutter_slide_up_panel/blob/master/gif/2.gif)

## Getting Started

first, init PanelController:
```java
PanelController({
		@required this.minHeight,
		@required this.maxHeight,
		this.initialOpen = false,
		@required this.vsync
	})
```
second, use SlideUpPanel:
```java
SlideUpPanel({
		@required this.body,
		@required this.head,
		@required this.panel, // if panel is scrollable, donot set ScrollController for it
		@required this.controller});
```


