package com.kcly.component.container.accordion {
	import com.kcly.component.control.KLabel;
	import com.kcly.component.control.KLine;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class KAccordion extends Sprite {
		private var gap:int;
		private var tabH:int;
		private var tabAreaW:int;
		private var tabAreaH:int;
		private var screenH:int;
		private var _curTab:int = 0;
		
		public function KAccordion(w:int, h:int, _tabH:int, _gap:int=0) {
			gap = _gap;
			tabH = _tabH;
			tabAreaW = w;
			screenH = h;
			scrollRect = new Rectangle(0, 0, w, h);
		}
		
		public function get curTab():int {
			return _curTab;
		}
		
		public function addScreen(mc:KAccordionElement, edge:KLine = null):void {
			if (edge) {
				edge.name = "edge"
				mc.addChild(edge);
			}
			mc.init(tabAreaW, tabH, gap);
			addChild(mc)
		}
		
		public function refresh():void {
			tabAreaH = screenH - tabH * (numChildren - 1);
			for (var i:int = 0; i < numChildren; i++) {
				var mc:KAccordionElement = getChildAt(i) as KAccordionElement
				mc.setTabAreaH(tabAreaH, (i==_curTab));
				var edge:KLine = mc.getChildByName("edge") as KLine
				if (edge) {
					edge.y = (i > 0) ? tabH - edge.height : tabAreaH - edge.height;
				}
				if (i > 0) {
					mc.y = tabAreaH + tabH * (i - 1)
				}
				mc.getChildByName("btn_tab").addEventListener(MouseEvent.CLICK, onTabClick)
			}
			showTab(_curTab)
		}
		
		private function onTabClick(evt:MouseEvent):void {
			var i:int = getChildIndex(evt.currentTarget.parent as KAccordionElement);
			_curTab = i;
			dispatchEvent(new Event(Event.CHANGE));
			showTab(_curTab);
		}
		
		public function showTab(no:int):void {
			trace ('showTab', no)
			for (var i:int = 0; i < numChildren; i++) {
				var mc:KAccordionElement = getChildAt(i) as KAccordionElement
				if (i<no) {
					mc.hide(Math.max(0, tabH * i));
				} else if (i==no) {
					mc.show(tabH * i);
				} else {
					mc.hide(tabAreaH + tabH * (i - 1));
				}
			}
		}
	}
}