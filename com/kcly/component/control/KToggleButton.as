package com.kcly.component.control {
	import com.greensock.TweenMax;
	import com.kcly.component.KCore;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class KToggleButton extends Sprite {
		private var masker:Shape;
		private var container:Sprite;
		private var maskBorder:Shape;
		private var dragger:Sprite;
		private var _isactive:Boolean;
		private var maxX:int;
		private var centerX:Number;
		private var borderW:int;
		private var halfBorderW:Number;
		private var isTouchMove:Boolean;
		private var mouseDownX:Number;
		
		public function KToggleButton(onStr:String, offStr:String) {
			
			var radius:int = 50 * KCore.scale;
			
			var on_tf:TextField = new TextField()
			on_tf.embedFonts = KCore.embedFonts;
			on_tf.selectable = false;
			
			var off_tf:TextField = new TextField()
			off_tf.embedFonts = KCore.embedFonts;
			off_tf.selectable = false;
			
			var on_tfmt:TextFormat = new TextFormat
			var off_tfmt:TextFormat = new TextFormat
			on_tfmt.font = off_tfmt.font = KCore.font;
			on_tfmt.size = off_tfmt.size = KCore.fontSize;
			on_tfmt.color = 0xffffff;
			on_tfmt.bold = on_tfmt.bold = true;
			on_tf.defaultTextFormat = on_tfmt;
			off_tf.defaultTextFormat = off_tfmt;
			on_tf.text = onStr;
			on_tf.autoSize = TextFieldAutoSize.LEFT;
			off_tf.text = offStr;
			off_tf.autoSize = TextFieldAutoSize.LEFT;
			on_tf.mouseEnabled = off_tf.mouseEnabled = false;
			
			var w:int = Math.max(on_tf.width, off_tf.width)*2;
			var circleCenter:Number = radius / 2;
			var offsetX:int = w - circleCenter;
			borderW = w + circleCenter;
			halfBorderW = borderW / 2;
			maxX = offsetX;
			centerX = maxX / 2;
			
			masker = new Shape;
			masker.graphics.beginFill(0, 0);
			masker.graphics.drawRoundRect(0, 0, borderW, radius, radius, radius);
			addChild(masker);
			
			container = new Sprite;
			container.mouseChildren = false;
			container.addEventListener(MouseEvent.CLICK, onClick)
			container.addEventListener(MouseEvent.MOUSE_DOWN, onTouchDown)
			container.mask = masker;
			addChild(container);

			var tfBase:Shape = new Shape
			tfBase.graphics.beginFill(KCore.themeColor);
			tfBase.graphics.drawRect(0, 0, w, radius);
			tfBase.graphics.beginFill(0xffffff);
			tfBase.graphics.drawRect(w, 0, w, radius);
			tfBase.graphics.endFill();
			tfBase.x = -offsetX;
			
			var tfW:int = w - circleCenter;
			on_tf.x = (tfW - on_tf.width) / 2 - offsetX;
			off_tf.x = (tfW - off_tf.width) / 2 + w/2;
			on_tf.y = (radius-on_tf.height) / 2;
			off_tf.y = (radius-off_tf.height) / 2;
			
			container.addChild(tfBase);
			container.addChild(on_tf);
			container.addChild(off_tf);
			
			dragger = new Sprite;
			dragger.graphics.beginFill(0xffffff);
			dragger.graphics.lineStyle(0, KCore.lineColor);
			
			dragger.graphics.drawCircle(circleCenter, circleCenter, circleCenter);
			container.addChild(dragger);
			
			maskBorder = new Shape;
			maskBorder.graphics.lineStyle(0, KCore.lineColor);
			maskBorder.graphics.drawRoundRect(0, 0, borderW, radius, radius, radius); 
			addChild(maskBorder);
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved)
		}
		
		private function onRemoved(evt:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			container.removeEventListener(MouseEvent.CLICK, onClick);
			container.removeEventListener(MouseEvent.MOUSE_DOWN, onTouchDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTouchUp);
			removeEventListener(MouseEvent.MOUSE_MOVE, onTouchMoving);
		}
		
		private function onTouchDown(evt:MouseEvent):void {
			mouseDownX = container.mouseX;
			isTouchMove = false;
			stage.addEventListener(MouseEvent.MOUSE_UP, onTouchUp);
			addEventListener(MouseEvent.MOUSE_MOVE, onTouchMoving);
		}
		
		private function onTouchMoving(evt:MouseEvent):void {
			var posX:int = Math.min(maxX, Math.max(0, this.mouseX-mouseDownX));
			container.x = posX;
			isTouchMove = true;
		}
		
		private function onTouchUp(evt:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTouchUp);
			removeEventListener(MouseEvent.MOUSE_MOVE, onTouchMoving);
			if (isTouchMove) {
				_isactive = (this.mouseX > halfBorderW);
				updateDragger(true);
			}
		}
		
		private function onClick(evt:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTouchUp);
			removeEventListener(MouseEvent.MOUSE_MOVE, onTouchMoving);
			if (!isTouchMove) {
				_isactive = !_isactive;
				updateDragger(true);
			}
		}
		
		public function get isactive():Boolean {
			return _isactive;
		}
		
		public function set isactive(bool:Boolean):void {
			if (bool != _isactive) {
				_isactive = bool;
				updateDragger(false);
			}
		}
		
		private function updateDragger(useTween:Boolean):void {
			var xpos:int = (_isactive) ? maxX : 0;
			if (useTween) {
				TweenMax.to(container, KCore.tweenDur, { x:xpos } );
			} else {
				container.x = xpos;
			}
		}
		
		override public function get width():Number {
			return borderW;
		}
	}
}