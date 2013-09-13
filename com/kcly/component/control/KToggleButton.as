package com.kcly.component.control {
	import flash.display.Shape;
	import flash.display.Sprite;
	import com.kcly.component.KCore;
	
	public class KToggleButton extends Sprite {
		private var masker:Shape;
		
		public function KToggleButton() {
			var h:int = KCore.fontSize + KCore.paddingH * 2;
			var radius:int = 40 * KCore.scale;
			
			masker = new Shape
			masker.graphics.beginFill(0)
			masker.graphics.drawRoundRect(0, 0, w, h, radius, radius); 
			addChild(masker)
		}
	}
}