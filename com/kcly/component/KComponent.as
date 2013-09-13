package com.kcly.component {
	import com.kcly.component.control.KButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class KComponent extends Sprite {
		public static var isInited:Boolean = false;
		
		[Embed(source="theme/theme.xml",mimeType="application/octet-stream")]
		private var themeXMLClass:Class;
		private var themeXML:XML;
		
		[Embed(source="theme/theme.png")]
		private var themeBmpClass:Class;
		private var themeBmp:Bitmap
		
		public function KComponent() {
			if (!KComponent.isInited) {
				themeXML = new XML(new themeXMLClass);
				
				themeBmp = new themeBmpClass;
				
				var node:XMLList
				var grid:Array
				var matrix:Matrix = new Matrix
				
				node = themeXML.theme.(@type == "button-normal");
				
				grid = node.@grid.split(',');
				matrix.tx = -node.@x;
				matrix.ty = -node.@y;
				KButton.buttonNormalBmpData = new BitmapData(node.@w, node.@h, true, 0x00ffffff);
				KButton.buttonNormalBmpData.draw(themeBmp, matrix)
				KButton.buttonNormalRect = new Rectangle(grid[0],grid[1],grid[2],grid[3]);
				
				node = themeXML.theme.(@type == "button-down");
				grid = node.@grid.split(',');
				matrix.tx = -node.@x;
				matrix.ty = -node.@y;
				KButton.buttonDownBmpData = new BitmapData(node.@w, node.@h, true, 0x00ffffff);
				KButton.buttonDownBmpData.draw(themeBmp, matrix);
				KButton.buttonDownRect = new Rectangle(grid[0],grid[1],grid[2],grid[3]);
				
				KComponent.isInited = true;
			}
		}
	}
}