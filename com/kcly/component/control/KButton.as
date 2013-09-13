package com.kcly.component.control {
	import com.kcly.component.KCore;
	import com.kcly.component.util.ScaleBitmap;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class KButton extends KCore {
		public static var buttonNormalBmpData:BitmapData
		public static var buttonDownBmpData:BitmapData
		public static var buttonNormalRect:Rectangle
		public static var buttonDownRect:Rectangle;
		public static var labelPositionRight:String = "right"
		public static var labelPositionBottom:String = "bottom"
		
		private var _bgColor:Number;
		private var _bgAlpha:Number = 1;
		
		private var state_normal:ScaleBitmap;
		private var state_down:ScaleBitmap;
		
		private var _icon:Bitmap;
		private var _w:int = 100;
		private var _h:int = 100;
		private var _labelPosition:String = KButton.labelPositionBottom;
		private var _followLabelSize:Boolean = false;
		
		public var paddingh:int = 0;
		public var paddingv:int = 15*KCore.scale;
		
		public var tf:TextField;
		public var tfmt:TextFormat

		public function KButton() {
			_bgColor = KCore.themeColor;
			
			state_normal = new ScaleBitmap(KButton.buttonNormalBmpData.clone());
			state_normal.scale9Grid = KButton.buttonNormalRect;
			state_down = new ScaleBitmap(KButton.buttonDownBmpData.clone());
			state_down.scale9Grid = KButton.buttonDownRect;

			state_down.visible = false;
			tf = new TextField()
			tf.multiline = tf.wordWrap = true
			tf.embedFonts = KCore.embedFonts;
			tf.selectable = false;
			//tf.border = true;
			tfmt = new TextFormat
			tfmt.font = KCore.font;
			tfmt.size = KCore.fontSize;
			tfmt.color = 0xffffff;
			tfmt.align = TextFormatAlign.CENTER;
			tfmt.bold = true;
			tf.defaultTextFormat = tfmt;
			
			addChild(state_normal)
			addChild(state_down)
			addChild(tf)
			
			addEventListener(MouseEvent.MOUSE_UP, onUp)
			addEventListener(MouseEvent.MOUSE_DOWN, onDown)
			addEventListener(MouseEvent.RELEASE_OUTSIDE, onUpOutside);
			
			mouseChildren = false;
			buttonMode = true;
		}
		
		public function set labelPosition(str:String):void {
			_labelPosition = str;
			if (_labelPosition == KButton.labelPositionBottom) {
				tfmt.align = TextFormatAlign.CENTER;
				tf.width = _w;
				tf.defaultTextFormat = tfmt;
			} else {
				tfmt.align = TextFormatAlign.LEFT;
				tf.width = _w * 0.6;
				tf.defaultTextFormat = tfmt;
			}
		}
		public function set icon(bmpClass:Bitmap):void {
			if (_icon) {
				_icon.bitmapData.dispose();
				_icon = null;
				removeChild(_icon) 
			}
			_icon = bmpClass
			addChild(_icon);
			setIconPosition();
		}
		
		public function set bgColor(no:Number):void {
			_bgColor = no;
		}
		
		public function set bgAlpha(no:Number):void {
			_bgAlpha = no;
			state_normal.alpha = state_down.alpha = no;
		}
		
		public function set label(str:String):void {
			tf.text = str
			tf.autoSize = TextFieldAutoSize.CENTER
			setLabelPosition();
		}
		
		override public function get width():Number {
			return _w;
		}
		
		override public function get height():Number {
			return _h;
		}

		public function refresh():void {
			setSize(_w, _h);
		}
		
		public function setSize(w:int, h:int):void {
			if (!state_normal) return;
			_w = w;
			_h = h;
			state_normal.setSize(_w, _h);
			state_down.setSize(_w, _h);
			
			
			if (_labelPosition == KButton.labelPositionBottom) {
				tf.width = _w;trace (tf.width)
			} else {
				tf.width = _w * 0.6;
			}
			if (_icon) {
				setIconPosition();
			}
			setLabelPosition();
			
			graphics.clear();
			graphics.beginFill(_bgColor, _bgAlpha);
			graphics.drawRect(0, 0, _w, _h);
			graphics.endFill();
		}
		
		public function followLabelSize(padding:int):void {
			if (padding>=0) {
				_followLabelSize = true;
				paddingh = padding * KCore.scale;
				tf.multiline = tf.wordWrap = false;
				tfmt.align = TextFormatAlign.LEFT;
				tf.defaultTextFormat = tfmt;
				setLabelPosition();
				setSize(tf.textWidth + paddingh * 2.5, _h);
			} else {
				_followLabelSize = false;
				/*paddingh = 0;
				tf.autoSize = TextFieldAutoSize.CENTER;
				tfmt.align = TextFormatAlign.CENTER;*/
				setSize(_w, _h);
			}
		}
		
		private function onUpOutside(evt:MouseEvent=null):void {
			state_normal.visible = true;
			state_down.visible = false;
		}
		
		private function onUp(evt:MouseEvent):void {
			onUpOutside();
		}
		
		private function onDown(evt:MouseEvent):void {
			state_normal.visible = false;
			state_down.visible = true;
		}
		
		private function setIconPosition():void {
			if (_labelPosition==KButton.labelPositionBottom) {
				_icon.x = (_w - _icon.width) / 2;
				_icon.y = (_h - tf.textHeight - _icon.height) / 2;
			} else {
				_icon.y = (_h - _icon.height) / 2;
				setLabelPosition();
			}
		}
		
		private function setLabelPosition():void {
			if (!_followLabelSize) {
				if (_labelPosition == KButton.labelPositionBottom) {
					if (_icon) {
						tf.y = _h - paddingv - tf.textHeight;
					} else {
						tf.y = (_h - tf.height) / 2;
					}
					tf.x = (_w - tf.width) / 2;
				} else {
					tf.y  = (_h - tf.height) / 2;
					if (_icon) {
						_icon.x = (_w - _icon.width - 10 - tf.textWidth) / 2;
						tf.x = _icon.width + _icon.x + 10;
					} else {
						tf.x = (_w - tf.textWidth) / 2;
					}
				}
			} else {
				tf.x = paddingh;
				tf.y = (_h - tf.height) / 2;
			}
		}
	}
}