package com.kcly.component.container {
	import flash.display.Sprite;

	public class KScreen extends Sprite {
		public function KScreen() {
		}
		
		public function beforeShow():void {
			// can be overrided by subclass
			visible = true;
		}
		
		public function show():void {
			// can be overrided by subclass
		}
		
		public function reshow():void {
			// can be overrided by subclass
		}
		
		public function beforeHide():void {
			// can be overrided by subclass
		}	
		
		public function movedToLeft():void {
			// can be overrided by subclass
			visible = false;
		}		
		
		public function hide():void {
			// can be overrided by subclass
			visible = false;
		}		
	}
}