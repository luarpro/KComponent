package com.kcly.component.control {
	import com.kcly.component.KCore;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;

	public class KLabel extends Sprite {
		private var _w:int;
		private var tf:MaxRowsTextField;
		private var tfmt:TextFormat;
		private var _text:String;
		private var _useEllipsis:Boolean = false;

		public function KLabel(str:String = "", paddingh:int=0, paddingv:int=0, w:int = 0, h:int=0) {
			_w = w;
			
			tf = new MaxRowsTextField;
			tf.selectable = false;
			tf.embedFonts = KCore.embedFonts;
			tf.mouseEnabled = false;
			//tf.border = true;
			tf.x = paddingh;
			tf.y = paddingv;
			if (_w > 0) {
				tf.width = _w;
				tf.height = h;
			}
			addChild(tf);
			
			tfmt = new TextFormat
			tfmt.font = KCore.font;
			tfmt.size = KCore.fontSize;
			tfmt.color = KCore.textColor;
			tf.defaultTextFormat = tfmt;

			label = _text = str;
		}
		
		public function get label():String {
			return _text;
		}
		
		public function set label(str:String):void {
			tf.text = _text = str;
			if (_w == 0) {
				tf.autoSize = TextFieldAutoSize.LEFT;
			}
			if (_useEllipsis) {
				useEllipsis = true;
			}
		}

		public function set url(bool:Boolean):void {
			tf.visible = false;
			tf.multiline = tf.wordWrap = true;
			tf.autoSize = TextFieldAutoSize.LEFT;
			setTimeout(_url, 500)
		}
		
		public function set useEllipsis(bool:Boolean):void {
			_useEllipsis = bool;
			if (bool) {
				if (tf.maxRows<2) {
					var cutLen:int = _text.length;
					while(tf.textWidth >= tf.width) {
						tf.text = _text.substring(0, cutLen) + '...';
						cutLen--;
					}
				} else {
					tf.text2 = _text;
				}
			} else {
				tf.text = _text;
			}
			
		}
		
		public function set maxRows(no:int):void {
			tf.maxRows = no;
		}
		
		public function updateTextformat(obj:Object):void {
			for (var i:String in obj) {
				tfmt[i] = obj[i];
			}
			tf.defaultTextFormat = tfmt;
			tf.setTextFormat(tfmt);
		}
		
		public function get multiline():Boolean {
			return tf.multiline;
		}
		
		public function set multiline(bool:Boolean):void {
			tf.multiline = bool;
		}
		
		public function get wordWrap():Boolean {
			return tf.wordWrap
		}
		
		public function set wordWrap(bool:Boolean):void {
			tf.wordWrap = bool;
		}
		
		public function set autoSize(str:String):void {
			tf.autoSize = str;
		}

		public function checkCanEmbed():Boolean {
			if (KCore.embedFonts) {
				var str:String = tf.text
				var len:int = str.length;
				for (var i:int = 0; i < len; i++) {
					if (str.charCodeAt(i)>500) {
						tf.embedFonts = false;
						if (_useEllipsis) {
							useEllipsis = true;
						}
						return false;
					}
				}
				return true;
			}
			return KCore.embedFonts
		}
		
		private function _url():void {
			tf.visible = true;
			if (tf.numLines == 1) {
				tfmt.align = TextFormatAlign.CENTER
			}
			tfmt.underline = true;
			tfmt.color = 0x0000ff;
			tf.setTextFormat(tfmt);
			addEventListener(MouseEvent.CLICK, onURLClick);
		}
		
		private function onURLClick(evt:MouseEvent):void {
			navigateToURL(new URLRequest(tf.text));
		}
	}
}