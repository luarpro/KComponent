package com.kcly.component.control {
	import com.greensock.TweenMax;
	import com.kcly.component.container.KList;
	import com.kcly.component.KCore;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class KComboBox extends Sprite {
		private var _text:String;
		private var tf:TextField;
		private var error_border:Shape;
		private var picker:KList;
		private var paddingv:int = 15 * KCore.scale;
		private var _useEllipsis:Boolean = false;
		private var _selectedIndex:int = -1;
		private var _pressDelay:int = 50;
		private var curPressTime:int = 0;
		
		public function KComboBox(w:int, btn_label:String, lazyInit:Boolean=false) {
			var h:int = KCore.fontSize + KCore.paddingH * 2;
			var radius:int = 40 * KCore.scale;
			
			graphics.beginFill(KCore.textInputBgColor, 0.4);
			graphics.drawRoundRect(0, 0, w, h, radius, radius);
			graphics.beginFill(0, 1);
			radius = radius * .5;
			graphics.moveTo(w - radius, h * 0.4);
			graphics.lineTo(w - radius * 2, h * 0.4);
			graphics.lineTo(w - radius * 1.5, h * 0.6);
			graphics.endFill();
			
			error_border = new Shape;
			error_border.graphics.lineStyle(4 * KCore.scale, 0xff0000);
			error_border.graphics.drawRoundRect(0, 0, w, h, radius, radius);
			error_border.visible = false;
			addChild(error_border);
			
			tf = new TextField;
			tf.selectable = false;
			tf.embedFonts = KCore.embedFonts;
			tf.mouseEnabled = false;
			tf.x = KCore.paddingH;
			tf.width = w - KCore.paddingH * 2 - radius;
			tf.height = h;
			tf.y = paddingv;
			addChild(tf);
			
			var tfmt:TextFormat = new TextFormat;
			tfmt.font = KCore.font;
			tfmt.size = KCore.fontSize;
			tfmt.color = KCore.textColor;
			tf.defaultTextFormat = tfmt;
			
			var pickerW:int = KCore.stageW * 0.8;
			var pickerH:int = KCore.stageH * 0.8;
			picker = new KList(pickerW, pickerH, true, btn_label, lazyInit);
			picker.alpha = 0;
			picker.visible = false;
			
			picker.addEventListener(Event.CHANGE, onPickerChange);
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onAdded(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved)
		}
		
		private function onRemoved(evt:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			if (picker.stage) {
				stage.removeChild(picker);
			}
		}
		
		private function onMouseDown(evt:MouseEvent):void {
			curPressTime = getTimer();
		}
		
		private function onMouseUp(evt:MouseEvent):void {
			if (curPressTime>0 && getTimer()-curPressTime>_pressDelay) {
				error = false;
				stage.addChild(picker);
				picker.scrollToSelection();
				dispatchEvent(new Event(Event.OPEN));
				TweenMax.to(picker, 0.2, { autoAlpha:1 } );
			}
			curPressTime = 0
		}
		
		private function onPickerChange(evt:Event):void {
			stage.removeChild(picker);
			_selectedIndex = picker.selectedIndex;
			label = picker.selectedLabel;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onSwipeMove(evt:TouchEvent):void {
			curPressTime = 0;
		}
		
		public function set containerName(str:String):void {
			picker.containerName = str;
		}
		
		public function get label():String {
			return _text;
		}
		
		public function set label(str:String):void {
			tf.text = _text = str;
			useEllipsis = true;
		}

		public function set dataProvider(dataA:*):void {
			// dataType: Array of Object or Vector.<Object>
			picker.dataProvider = dataA
		}
		
		public function get selectedData():* {
			return picker.selectedData;
		}
		
		public function set selectedData(val:*):void {
			picker.selectedData = val;
			label = picker.selectedLabel;
		}
		
		public function get selectedItem():* {
			return picker.selectedItem;
		}
		
		public function get selectedIndex():int {
			return _selectedIndex;
		}
		
		public function get length():int {
			return picker.length;
		}
		
		public function set selectedIndex (no:int):void {
			_selectedIndex = no
			picker.selectedIndex = no;
			label = picker.selectedLabel;
		}
		
		public function set error(bool:Boolean):void {
			error_border.visible = bool;
		}
		
		public function get pressDelay():int {
			return _pressDelay;
		}
		
		public function set pressDelay(no:int):void {
			_pressDelay = no;
			addEventListener(TouchEvent.TOUCH_MOVE, onSwipeMove, false, 0, true);
		}
		
		public function set useEllipsis(bool:Boolean):void {
			_useEllipsis = bool;
			if (bool) {
				var cutLen:int = _text.length;
				while(tf.textWidth >= tf.width) {
					tf.text = _text.substring(0, cutLen) + '...';
					cutLen--;
				}
			} else {
				tf.text = _text;
			}
		}
		
		public function addDataAt(data:Object, rowIndex:int=-1):void {
			picker.addDataAt(data, rowIndex);
		}
		
		public function refresh():void {
			picker.refresh();
		}
		
		public function kill():void {
			picker.kill();
		}
	}
}