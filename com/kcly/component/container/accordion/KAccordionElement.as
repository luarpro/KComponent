package com.kcly.component.container.accordion {
	import com.greensock.TweenMax;
	import com.kcly.component.control.KLabel;
	import com.kcly.component.control.KLine;
	import com.kcly.component.control.KTextInput;
	import com.kcly.component.control.NativeText;
	import com.kcly.component.KCore;
	import flash.display.Shape;
	import flash.display.Sprite;

	public class KAccordionElement extends Sprite {
		private var tabH:int;
		private var _tabAreaH:int;
		private var btn_tab:Sprite
		private var edge:KLine;
		private var container:Sprite;
		private var container_mask:Shape;
		
		function KAccordionElement() {
			container = new Sprite
			addChild(container);
			
			container_mask = new Shape
			
			addChild(container_mask)
			container.mask = container_mask;
			container.visible = false;
		}
		
		public function setTabAreaH(no:int, updateMaskH:Boolean):void {
			if (updateMaskH) {
				container_mask.height = no;
			}
			_tabAreaH = no;
			trace ('_tabAreaH',_tabAreaH)
		}	
		
		public function get tabAreaH():int {
			return _tabAreaH;
		}
		
		public function get length():int {
			return container.numChildren;
		}
		
		public function init(tabAreaW:int, _tabH:int, gap:int = 0):void {
			tabH = _tabH;
			
			container_mask.graphics.beginFill(0, 0)
			container_mask.graphics.drawRect(0, 0, tabAreaW, tabH)
			container_mask.graphics.endFill();
			btn_tab = new Sprite
			btn_tab.name = "btn_tab";
			btn_tab.graphics.beginFill(0xffffff, 0)
			btn_tab.graphics.drawRect(0, 0, tabAreaW, tabH)
			btn_tab.graphics.endFill();
			addChild(btn_tab)
			edge = getChildByName("edge") as KLine;
		}

		public function addElement(mc:*):void {
			container.addChild(mc);
		}
		
		public function addElementAt(mc:*, no:int):void {
			container.addChildAt(mc, no);
		}
		
		public function show(ypos:int):void {
			container.visible = true;
			TweenMax.to(this, KCore.tweenDur2, { y:ypos } )
			TweenMax.to(container_mask, KCore.tweenDur2, { height:_tabAreaH, onComplete:showStageElement } )
			if (edge) {
				TweenMax.to(edge, KCore.tweenDur2, { y:_tabAreaH-edge.height } )
			}
			TweenMax.to(btn_tab, KCore.tweenDur2, {autoAlpha:0 } )
		}
		
		public function hide(ypos:int):void {
			hideStageElement();
			TweenMax.to(this, KCore.tweenDur2, { y:ypos } )
			TweenMax.to(container_mask, KCore.tweenDur2, { height:tabH, onComplete:hidden } )
			if (edge) {
				TweenMax.to(edge, KCore.tweenDur2, { y:tabH-edge.height } )
			}
			TweenMax.to(btn_tab, KCore.tweenDur2, {autoAlpha:1 } )
		}
		
		private function showStageElement():void {
			var len:int = container.numChildren
			for (var i:int = 0; i < len; i++) {
				var mc:* = container.getChildAt(i)
				if (mc is KTextInput) {
					if (mc.visible) {
						KTextInput(mc).show()
					}
				}
			}
		}
		
		private function hideStageElement():void {
			var len:int = container.numChildren
			for (var i:int = 0; i < len; i++) {
				var mc:* = container.getChildAt(i)
				if (mc is KTextInput) {
					trace (mc)
					KTextInput(mc).hide()
				}
			}
		}
		
		private function hidden():void {
			container.visible = false;
		}
	}
}