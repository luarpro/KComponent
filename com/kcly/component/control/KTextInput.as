package com.kcly.component.control {
	import com.kcly.component.KCore;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.text.SoftKeyboardType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import it.instabuy.data.Setting;
	
	public class KTextInput extends Sprite {
		protected var ntf:NativeText;
		protected var dtf:TextField;
		protected var error_border:Shape;
		private var paddingv:int = 15 * KCore.scale;
		private var useDisplayText:Boolean
		private var _pressDelay:int = 100;
		private var curPressTime:int = 0;
		
		public function KTextInput(w:int, useDisplayText:Boolean, type:String=SoftKeyboardType.DEFAULT, _h:int=0, numline:int=1) {
			var h:int = KCore.fontSize + KCore.paddingH * 2;
			if (_h > 0) {
				h = _h * KCore.scale;
			}
			var radius:int = 40 * KCore.scale
			
			graphics.beginFill(KCore.textInputBgColor, 0.4)
			graphics.drawRoundRect(0, 0, w, h, radius, radius)
			graphics.endFill();
			
			error_border = new Shape
			error_border.graphics.lineStyle(4*KCore.scale, 0xff0000)
			error_border.graphics.drawRoundRect(0, 0, w, h, radius, radius)
			error_border.visible = false;
			addChild(error_border)
			
			this.useDisplayText = useDisplayText;
			
			ntf = new NativeText(numline);
			if (KCore.isAppRuntime || !useDisplayText) {
				ntf.fontFamily = KCore.font;
				ntf.fontSize = KCore.fontSize;
				ntf.color = KCore.textColor;
				ntf.softKeyboardType = type;
				ntf.width = w - KCore.paddingH;
				ntf.height = h;
				ntf.addEventListener(FocusEvent.FOCUS_IN, onNativeFocusIn);
				addChild(ntf);
			}
			if (useDisplayText) {
				dtf = new TextField
				var tfmt:TextFormat = new TextFormat
				tfmt.font = KCore.font;
				tfmt.size = KCore.fontSize
				tfmt.color = KCore.textColor;
				dtf.defaultTextFormat = tfmt;
				dtf.x = KCore.paddingH-2
				dtf.y = paddingv-1
				dtf.width = w - KCore.paddingH;
				dtf.height = h;
				addChild(dtf);
				if (KCore.isAppRuntime) {
					dtf.mouseEnabled = false;
					addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown); 
					addEventListener(MouseEvent.MOUSE_UP, onMouseUp); 
					addEventListener(TouchEvent.TOUCH_MOVE, onSwipeMove, false, 0, true);
					ntf.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE, onSoftKeyHide)
				} else {
					dtf.type = TextFieldType.INPUT
				}
			}
		}
		
		private function onSoftKeyHide(evt:SoftKeyboardEvent):void {
			dtf.text = ntf.text;
			hide()
			dtf.visible = true;
			dispatchEvent(new FocusEvent(FocusEvent.FOCUS_OUT, false))
		}
		
		private function onMouseDown(evt:MouseEvent):void {
			error = false;
			curPressTime = getTimer();
		}
		
		private function onMouseUp(evt:MouseEvent):void {
			if (curPressTime > 0 && getTimer() - curPressTime > _pressDelay) {
				dispatchEvent(new FocusEvent(FocusEvent.FOCUS_IN, false))
				dtf.visible = false;
				show()
				ntf.show();
				stage.focus = ntf;
			}
			curPressTime = 0;
		}
		
		private function onNativeFocusIn(evt:FocusEvent):void {
			error = false;
		}
		
		private function onSwipeMove(evt:TouchEvent):void {
			curPressTime = 0;
		}
		
		public function show():void {
			var pt:Point = new Point(x, y);
			pt = parent.localToGlobal(pt);
			ntf.x = pt.x + KCore.paddingH;
			ntf.y = pt.y + paddingv;
			if (!useDisplayText) {
				ntf.show();
			}
		}
		
		public function hide():void {
			ntf.hide();
		}
		
		public function kill():void {
			ntf.kill();
		}
		
		public function set restrict(str:String):void {
			ntf.restrict = str;
			if (useDisplayText) {
				dtf.restrict = str;
			}
		}
		
		public function set text(str:String):void {
			ntf.text = str;
			if (useDisplayText) {
				dtf.text = str;
				hide()
			}
		}
		
		public function get text():String {
			return (!useDisplayText) ? ntf.text : dtf.text
		}
				
		public function set error(bool:Boolean):void {
			error_border.visible = bool;
		}
		
		public function set maxChars(no:int):void {
			ntf.maxChars = no;
		}
		
		public function set freeze(bool:Boolean):void {
			if (!useDisplayText) {
				if (bool) {
					ntf.freeze();
				} else {
					ntf.unfreeze();
					show();
				}
			}
		}
	}
}