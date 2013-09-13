package com.kcly.component.control {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class KLine extends Sprite {
		
		public function KLine(w:int, h:int, lineBmpData:BitmapData, cornerLBmpData:BitmapData=null, cornerRBmpData:BitmapData=null) {
			graphics.beginBitmapFill(lineBmpData)

			if (cornerLBmpData && cornerRBmpData) {
				var bmpL:Bitmap = new Bitmap(cornerLBmpData)
				addChild(bmpL)
				var bmpR:Bitmap = new Bitmap(cornerRBmpData)
				addChild(bmpR)
				bmpR.x = w - bmpR.width;
				graphics.drawRect(bmpL.width, 0, w-bmpL.width-bmpR.width, h)
			} else {
				graphics.drawRect(0, 0, w, h)
			}
			graphics.endFill()
		}
	}
}