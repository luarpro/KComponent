package com.kcly.component.control {
	import com.kcly.component.KCore;
	import flash.display.Shape;
	import flash.display.Sprite;

	public class KPageCircle extends Sprite {
		private var container:Sprite;
		private var curPage:int = 0;
		private var radius:int;
		private var gap:int;
		private var w:int;
		private var color:Number
		
		public function KPageCircle(w:int, color:Number = 0xffffff) {
			this.w = w;
			this.color = color;
			container = new Sprite
			addChild(container)
			radius = 8 * KCore.scale;
			gap = 36 * KCore.scale;
		}
		
		public function set total(no:int):void {
			var len:int = container.numChildren
			for (var i:int = 0; i < len;i++) {
				container.removeChildAt(0);
			}
			for (i = 0; i < no; i++) {
				var circle:Shape = new Shape
				circle.graphics.beginFill(color)
				circle.graphics.drawCircle(0, 0, radius)
				circle.y = radius
				circle.x = radius + gap * i
				circle.alpha = (i == curPage) ? 1 : 0.3;
				container.addChild(circle);
			}
			container.x = (w - container.width) / 2;
		}
		
		public function set current(no:int):void {
			var circle:Shape = container.getChildAt(curPage) as Shape
			circle.alpha = 0.3;
			curPage = no;
			circle = container.getChildAt(curPage) as Shape
			circle.alpha = 1;
		}
	}
}