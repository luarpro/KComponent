package com.kcly.component.renderer {
	import com.greensock.TweenMax;
	import com.kcly.component.control.KButton;
	import com.kcly.component.control.KLabel;
	import com.kcly.component.KCore;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class KItemRenderer extends Sprite {
		public static var ITEM_WANT_DELETE:String = "itemWantDelete";
		
		protected var paddingH:int;
		protected var paddingV:int;
		protected var highlightW:int;
		protected var highlightH:int;
		private var hasArrow:Boolean;
		private var hasIcon:Boolean;
		
		protected var container:Sprite;
		protected var btn_right:KButton
		protected var btn_left:KButton;
		protected var inEditMode:Boolean = false;
		protected var edit_str:String;
		protected var del_str:String;
		protected var gap:int = 20 * KCore.scale;
		
		protected var base:Shape;
		protected var lb_text:KLabel
		protected var lb_arrow:KLabel
		protected var icon:Bitmap
		
		protected var textColor:Number;
		
		public var data:*;
		public var obj:*;
		public var allowSelect:Boolean = true
		
		public function KItemRenderer(str:String = "", paddingH:int = 0, paddingV:int = 0, w:int = 0, h:int = 0, highlightW:int = 0, highlightH:int = 0, useEllipsis:Boolean = false, deletable:Boolean=false, editable:Boolean=false, delIconClass:Bitmap=null) {
			this.paddingH = paddingH;
			this.paddingV = paddingV;
			this.highlightW = highlightW;
			this.highlightH = highlightH;
			
			base = new Shape
			base.graphics.beginFill(KCore.highlightColor, 1)
			base.graphics.drawRect(0, 0, highlightW, highlightH)
			base.graphics.endFill()
			base.alpha = 0;
			addChild(base);
			
			
			lb_text = new KLabel(str, paddingH, 0, w, h);
			lb_text.useEllipsis = useEllipsis;
			lb_text.addEventListener(Event.RENDER, onLabelRendered)
			lb_text.y = (base.height - lb_text.height) / 2;
			addChild(lb_text);
			
			if (editable || deletable) {
				container = new Sprite
				addChild(container);
				container.addChild(lb_text);
			}
			
			if (deletable) {
				btn_left = new KButton
				btn_left.addEventListener(MouseEvent.CLICK, onLeftClick)
				btn_left.bgAlpha = 0
				btn_left.icon = delIconClass
				btn_left.label = '';
				btn_left.setSize(84 * KCore.scale, highlightH);
				btn_left.x = -btn_left.width;
				btn_left.visible = false;
				addChild(btn_left);
			}
			if (editable || deletable) {
				var right_str:String = (edit_str.length > del_str.length) ? edit_str : del_str;
				btn_right = new KButton;
				btn_right.addEventListener(MouseEvent.CLICK, onRightClick);
				btn_right.bgColor = KCore.titleBarRightButtonBgColor;
				btn_right.label = right_str;
				btn_right.setSize(1, highlightH);
				btn_right.followLabelSize(gap);
				btn_right.x = KCore.stageW;
				btn_right.visible = false;
				btn_right.followLabelSize(-1);
				addChild(btn_right);
			}

			var ig:Graphics
			if (!container) {
				mouseChildren = false;
				ig = this.graphics;
			} else {
				container.mouseEnabled = false;
				container.mouseChildren = false;
				ig = container.graphics;
			}
			ig.clear();
			ig.lineStyle(1, KCore.lineColor);
			ig.moveTo(0, highlightH);
			ig.lineTo(KCore.stageW, highlightH);
		}
		
		private function onLabelRendered(evt:Event):void {
			lb_text.removeEventListener(Event.RENDER, onLabelRendered)
			lb_text.y = (base.height - lb_text.height) / 2;
			evt.stopPropagation()
		}

		public function createIcon(bmp:Bitmap):void {
			bmp.x = (paddingH - bmp.width) / 2;
			bmp.y = (base.height - bmp.height) / 2;
			if (!container) {
				addChild(bmp);
			} else {
				container.addChild(bmp);
			}
		}
		
		public function createArrow():void {
			lb_arrow = new KLabel(">")
			lb_arrow.mouseChildren = lb_arrow.mouseEnabled = false;
			lb_arrow.y = (base.height - lb_arrow.height) / 2;
			lb_arrow.x = base.width - lb_arrow.width - gap / 2;
			if (!container) {
				addChild(lb_arrow);
			} else {
				container.addChild(lb_arrow);
			}
		}
		
		public function get label():String {
			return lb_text.label;
		}
		
		public function set highlight(bool:Boolean):void {
			base.alpha = (bool) ? 1 : 0;
			if (bool) {
				textColor = (KCore.textColor < 0x7FFFFF) ? 0xffffff : 0x000000;
			} else {
				textColor = KCore.textColor
			}
			lb_text.updateTextformat( { color:textColor } );
			
			if (lb_arrow) {
				lb_arrow.updateTextformat( { color:textColor } );
			}
		}
		
		public function set deleteMode(bool:Boolean):void {
			if (inEditMode == !bool) return
			if (bool) {
				inEditMode = false;
				btn_right.label = del_str;
				btn_right.bgColor = KCore.buttonBgRedColor;
				btn_right.x = KCore.stageW;
				btn_right.alpha = 0; 
				TweenMax.to(btn_right, KCore.tweenDur, { x:KCore.stageW - btn_right.width, autoAlpha:1 } )
			} else {
				inEditMode = true;
				btn_right.label = edit_str;
				btn_right.bgColor = KCore.titleBarRightButtonBgColor;
			}
			btn_right.refresh();
		}
		
		public function set edit(bool:Boolean):void {
			if (bool) {
				inEditMode = true;
				btn_right.label = edit_str;
				btn_right.bgColor = KCore.titleBarRightButtonBgColor;
				btn_right.refresh();
				TweenMax.to(btn_left, KCore.tweenDur, {x:0, autoAlpha:1 } )
				TweenMax.to(container, KCore.tweenDur, {x:btn_left.width } )
				TweenMax.to(btn_right, KCore.tweenDur, { x:KCore.stageW - btn_right.width, autoAlpha:1 } ) 
			} else {
				TweenMax.to(btn_left, KCore.tweenDur, {x:-btn_left.width, autoAlpha:0 } )
				TweenMax.to(container, KCore.tweenDur, {x:0 } )
				TweenMax.to(btn_right, KCore.tweenDur, { x:KCore.stageW, autoAlpha:0 } ) 
			}
		}
		
		override public function get height():Number {
			return highlightH;
		}
		
		private function onLeftClick(evt:MouseEvent):void {
			dispatchEvent(new Event(KItemRenderer.ITEM_WANT_DELETE, true));
		}
		
		protected function onRightClick(evt:MouseEvent):void {
			// implemented by sub-class
		}
	}
}