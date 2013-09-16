package com.kcly.component.container {
	import com.greensock.TweenMax;
	import com.kcly.component.control.KButton;
	import com.kcly.component.KCore;
	import com.kcly.component.renderer.KItemRenderer;
	import com.kcly.component.scroll.IOSScrollArea;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	
	public class KList extends Sprite {
		public static var NEED_PAGING:String = "KListNeedPaging";
		
		protected var container:Sprite;
		protected var scroll:IOSScrollArea;
		private var base:Sprite;
		private var btn_ok:KButton;
		
		private var _selectedIndex:int = -1;
		private var lastSelectedIndex:int = -1;

		protected var baseW:int;
		protected var _paddingH:int = KCore.paddingH
		protected var _paddingV:int = 15 * KCore.scale;
		private var isFloat:Boolean
		private var _gap:int = 20 * KCore.scale;
		private var txtW:int;
		private var txtH:int;
		private var hlH:int;
		private var halfGap:int;
		private var _paddingH2:int;
		
		public var curInDeleteItem:KItemRenderer;
		protected var allowPullRefresh:Boolean;
		protected var allowPaging:Boolean;
		private var lastDownItem:KItemRenderer;
		private var lazyInit:Boolean;
		private var inEditMode:Boolean = false;
		private var _data:*;
		private var rendererClass:Class;
		private var _loading:MovieClip;
		
		protected var loadingLen:int = 0;
		protected var footerLen:int = 0;
		protected var footerItem:Sprite;
		
		public function KList(w:int, h:int, isFloat:Boolean, btn_label:String=null, lazyInit:Boolean=false, allowPullRefresh:Boolean=false, allowPaging:Boolean=false, rendererClass:Class=null) {
			this.isFloat = isFloat;
			this.lazyInit = lazyInit;
			
			if (!rendererClass) {
				this.rendererClass = KItemRenderer
			} else {
				this.rendererClass = rendererClass;
			}
			
			// TODO: support pull to refresh
			this.allowPullRefresh = allowPullRefresh;
			
			this.allowPaging = allowPaging;

			var radius:int = 0
			var scrollH:int = h;
			baseW = w;
			txtW = baseW - _paddingH * 2;
			txtH = KCore.fontSize*1.3;
			hlH = txtH+_gap;
			halfGap = _gap / 2;
			
			if (isFloat) {
				radius = 40 * KCore.scale
				scrollH = h - radius - _paddingV * 2;
				graphics.beginFill(0, 0.2)
				graphics.drawRect(0, 0, KCore.stageW, KCore.stageH)
				graphics.endFill();
				
				base = new Sprite
				base.graphics.beginFill(0xffffff)
				base.graphics.drawRoundRect(0, 0, w, h, radius, radius);
				base.graphics.endFill();
				addChild(base);
			}
			container = new Sprite
			container.addEventListener(KItemRenderer.ITEM_WANT_DELETE, onLeftClick)
			
			var btnH:int = 80 * KCore.scale;
			if (btn_label) {
				btn_ok = new KButton()
				btn_ok.setSize(w - KCore.paddingH * 2, btnH);
				btn_ok.label = btn_label
				addChild(btn_ok)
				scrollH -= btnH;
			}

			scroll = new IOSScrollArea(w, scrollH, true, allowPaging);
			if (allowPaging) {
				scroll.addEventListener(IOSScrollArea.SCROLL_STOP, onScrollEnded);
			}
			
			if (isFloat) {
				scroll.x = container.x = (KCore.stageW - w) / 2;
				scroll.y = container.y = (KCore.stageH - h) / 2 + radius;
				base.x = scroll.x
				base.y = (KCore.stageH - base.height) / 2
				base.graphics.lineStyle(1, KCore.lineColor);
				base.graphics.moveTo(0, radius);
				base.graphics.lineTo(base.width, radius);
				base.graphics.moveTo(0, radius+scrollH);
				base.graphics.lineTo(base.width, radius+scrollH);
			}
			addEventListener(TouchEvent.TOUCH_MOVE, onSwipeMove, false, 0, true);
			
			if (btn_ok) {
				btn_ok.x = container.x + KCore.paddingH;
				btn_ok.y = container.y + scrollH + _paddingV;
				btn_ok.addEventListener(MouseEvent.CLICK, onBtnClick, false, 0, true)
			}
			addEventListener(Event.ADDED_TO_STAGE, onAdded)
		}
		
		private function onScrollEnded(evt:Event):void {
			if (scroll.percent > 0.7) {
				dispatchEvent(new Event(KList.NEED_PAGING));
			}
		}
		
		private function onSwipeMove(evt:TouchEvent):void {
			lastDownItem = null;
			if (isFloat) {
				selectedIndex = lastSelectedIndex;
			} else {
				selectedIndex = -1;
			}
		}
		
		private function onAdded(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addChild(container);
			addChild(scroll);
			scroll.item = container;
			refresh()
		}	
		
		private function onBtnClick(evt:MouseEvent):void {
			visible = false;
			dispatchEvent(new Event(Event.CHANGE));
		}

		
		private function onItemDown(evt:MouseEvent):void {
			if (!inEditMode) {
				lastDownItem = evt.currentTarget as KItemRenderer
				if (lastDownItem.allowSelect) {
					if (!isFloat) {
						selectedIndex = container.getChildIndex(lastDownItem);
					}
				} else {
					lastDownItem = null;
				}
			}
		}
		
		private function onItemUp(evt:MouseEvent):void {
			var item:KItemRenderer = evt.currentTarget as KItemRenderer
			if (item == lastDownItem) {
				selectedIndex = container.getChildIndex(item);
				if (!isFloat) {
					dispatchEvent(new Event(Event.CHANGE));
				}
			}
			if (!isFloat) {
				selectedIndex = -1;
			}
		}

		public function set dataProvider(dataA:*):void {
			// dataType: Array of Object or Vector.<Object>
			if (!lazyInit) {
				var item:KItemRenderer
				removeAll();
				_paddingH2 = _paddingH;
				txtW = baseW - _paddingH * 2;
				var len:int = dataA.length;
				if (len>0) {
					if (dataA[0].icon) {
						_paddingH2 += dataA[0].icon.width+halfGap;
						txtW -= dataA[0].icon.width+halfGap;
					}

					for (var i:int = 0; i < len; i++) {
						addDataAt(dataA[i]);
					}
				}
				refresh();
			} else {
				_data = dataA;
			}
		}
		
		public function set edit(bool:Boolean):void {
			inEditMode = bool;
			var len:int = container.numChildren - footerLen - loadingLen;
			for (var i:int; i < len; i++) {
				var item:KItemRenderer = container.getChildAt(i) as KItemRenderer
				item.edit = bool;
			}
			lastDownItem = null;
		}
		
		// e.g. btn_edit
		public function set footer(mc:Sprite):void {
			if (footerItem) {
				container.removeChild(footerItem);
			}
			footerLen = 1;
			footerItem = mc
			container.addChild(footerItem);
		}
		
		public function get length():int {
			return (!lazyInit) ? container.numChildren - footerLen - loadingLen : _data.length;
		}

		public function set containerName(str:String):void {
			container.name = str;
		}
		
		public function get selectedData():* {
			if (_selectedIndex>=0) {
				if (!lazyInit) {
					var item:KItemRenderer = container.getChildAt(_selectedIndex) as KItemRenderer
					return item.data;
				} else {
					return _data[_selectedIndex].data
				}
			}
		}
		
		public function set selectedData(val:*):void {
			var len:int = length;
			var i:int;
			if (!lazyInit) {
				for (i = 0; i < len; i++) {
					var item:KItemRenderer = container.getChildAt(i) as KItemRenderer
					trace ('list selectedData0', i, item.data, val, lazyInit)
					if (item.data == val) {
						selectedIndex = i;
						return;
					}
				}
			} else {
				for (i = 0; i < len; i++) {
					trace ('list selectedData1', i, _data[i].scid, val, lazyInit)
					if (_data[i].scid == val) {
						selectedIndex = i;
						return;
					}
				}
			}
		}
		
		public function get selectedItem():* {
			if (_selectedIndex >= 0) {
				if (!lazyInit) {
					var item:KItemRenderer = container.getChildAt(_selectedIndex) as KItemRenderer
					return item.obj;
				} else {
					// not yet separate non-label/data value to data[i].obj
					return _data[_selectedIndex]
				}
			}
		}
		
		public function get selectedLabel():String {
			if (_selectedIndex >= 0) {
				if (!lazyInit) {
					var item:KItemRenderer = container.getChildAt(_selectedIndex) as KItemRenderer
					return item.label;
				} else {
					return _data[_selectedIndex].label
				}
			} else {
				return "";
			}
		}
		
		public function get selectedIndex():int {
			return _selectedIndex;
		}
		
		public function set selectedIndex (no:int):void {
			var item:KItemRenderer
			var len:int = container.numChildren - footerLen - loadingLen;
			if (_selectedIndex >= 0 && _selectedIndex<len) {
				item = container.getChildAt(_selectedIndex) as KItemRenderer
				if (item) {
					item.highlight = false;
				}
			}
			lastSelectedIndex = _selectedIndex = no
			if (_selectedIndex >= 0 && _selectedIndex<len) {
				item = container.getChildAt(_selectedIndex) as KItemRenderer
				item.highlight = true;
			}
		}
		
		public function get selectedRenderer():* {
			if (_selectedIndex >= 0) {
				return container.getChildAt(_selectedIndex)
			}
		}
		
		public function set paddingH(no:int):void {
			_paddingH = no * KCore.scale;
			txtW = baseW - _paddingH * 2;
		}
		
		public function set paddingV(no:int):void {
			_paddingV = no * KCore.scale;
		}
		
		public function set gap(no:int):void {
			_gap = no * KCore.scale;
			hlH = txtH+_gap;
			halfGap = _gap / 2;
		}
		
		public function set scrollEnabled(bool:Boolean):void {
			scroll.mouseEnabled = bool;
		}
		
		public function addDataAt(data:Object, rowIndex:int = -1):void {
			if (!lazyInit) {
				_addDataAt(data, rowIndex)
			} else {
				_data.splice(rowIndex, 0, data) 
			}
		}

		private function _addDataAt(data:Object, rowIndex:int = -1):void {
			var _txtW:int = txtW;
			if (data.next) {
				_txtW -= _gap;
			}
			var item:KItemRenderer = new rendererClass(data.label, _paddingH2, _paddingV, _txtW, txtH, baseW, hlH, true)
			item.addEventListener(MouseEvent.MOUSE_DOWN, onItemDown, false, 0, true)
			item.addEventListener(MouseEvent.MOUSE_UP, onItemUp, false, 0, true)
			item.data = data.data;
			item.obj = {}
			for (var j:String in data) {
				item.obj[j] = data[j]
			}
			delete item.obj.label;
			delete item.obj.data;
			if (data.icon) {
				item.createIcon(data.icon);
			}
			if (data.next) {
				item.createArrow()
			}
			
			if (rowIndex==-1) {
				container.addChild(item);
			} else {
				container.addChildAt(item, rowIndex);
			}
		}
		
		public function addItemAt(item:KItemRenderer, rowIndex:int = -1, doRefresh:Boolean=false, useTween:Boolean=false):void {
			item.addEventListener(MouseEvent.MOUSE_DOWN, onItemDown);
			item.addEventListener(MouseEvent.MOUSE_UP, onItemUp);
			if (rowIndex==-1) {
				container.addChild(item);
			} else {
				container.addChildAt(item, rowIndex);
			}
			if (doRefresh) {
				refresh(useTween)
				if (container.height > scroll.height) {
					TweenMax.to(container, KCore.tweenDur, {y:scroll.height - container.height});
				}
			}
		}
		
		public function getItemAt(no:int):KItemRenderer {
			return container.getChildAt(no) as KItemRenderer;
		}
		
		public function getItemIndex(mc:KItemRenderer):int {
			return container.getChildIndex(mc);
		}

		public function removeAll():void {
			for (var i:int = container.numChildren - 1 - footerLen - loadingLen; i >= 0; i--) {
				var item:KItemRenderer = container.getChildAt(i) as KItemRenderer
				item.removeEventListener(MouseEvent.MOUSE_DOWN, onItemDown)
				item.removeEventListener(MouseEvent.MOUSE_UP, onItemUp)
				container.removeChildAt(i);
			}
		}
		
		public function removeItem(item:KItemRenderer):void {
			item.removeEventListener(MouseEvent.MOUSE_DOWN, onItemDown);
			item.removeEventListener(MouseEvent.MOUSE_UP, onItemUp);
			container.removeChild(item);
			refresh(true);
		}
		
		protected function refreshFooterLoading():void {
			if (footerItem) {
				container.addChild(footerItem)
			}
			if (_loading) {
				container.addChild(_loading)
			}
		}
		
		public function refresh(useTween:Boolean=false, startIndex:int=0):void {
			refreshFooterLoading();
			var len:int = container.numChildren - footerLen - loadingLen;
			var offsetY:int = 0;
			for (var i:int = startIndex; i < len; i++) {
				var item:KItemRenderer = container.getChildAt(i) as KItemRenderer
				if (!useTween) {
					item.y = offsetY;
				} else {
					if (item.y != offsetY) {
						TweenMax.to(item, KCore.tweenDur, { y:offsetY } )
					}
				}
				offsetY += item.height;
			}

			offsetY = positionFooterLoading(useTween, offsetY);
			
			container.graphics.clear();
			container.graphics.beginFill(0xff0000, 0);
			container.graphics.drawRect(0, 0, 1, offsetY);
			container.graphics.endFill();
			
			if (useTween) {
				var diff:int = scroll.height - offsetY;
				if (container.y < diff) {
					TweenMax.to(container, KCore.tweenDur, {y:Math.min(0,diff)})
				}
			} else if (stage) {
				scroll.refresh();
			}
			if (allowPaging && len>0 && container.height < scroll.height) {
				dispatchEvent(new Event(KList.NEED_PAGING));
			}
		}
		
		protected function positionFooterLoading(useTween:Boolean, offsetY:int):int {
			if (footerItem) {
				offsetY += KCore.paddingH;
				if (!useTween) {
					footerItem.y = offsetY;
				} else {
					TweenMax.to(footerItem, KCore.tweenDur, {y:offsetY, onComplete:onContainerTweeenDone})
				}
				offsetY += footerItem.height + KCore.paddingH*2;
			}
			if (_loading) {
				if (!footerItem) {
					_loading.y = offsetY + KCore.paddingH;
				} else {
					_loading.y = offsetY;
				}
				offsetY += _loading.height;
				_loading.x = (baseW - _loading.width) / 2;
			}
			return offsetY;
		}
		
		private function onContainerTweeenDone():void {
			if (stage) {
				scroll.refresh();
			}
		}
		
		private function onLeftClick(evt:Event):void {
			if (curInDeleteItem) {
				curInDeleteItem.deleteMode = false;
			}
			curInDeleteItem = evt.target as KItemRenderer
			curInDeleteItem.deleteMode = true;
			evt.stopPropagation()
		}
				
		public function setLoadingIcon(mc:MovieClip = null):void {
			var needRreshScroll:int = 0;
			if (_loading) {
				container.removeChild(_loading);
				if (!mc) {
					needRreshScroll = _loading.height;
				}
			}
			if (mc) {
				_loading = mc;
				_loading.scaleX = _loading.scaleY = KCore.scale;
				loadingLen = 1;
				container.addChild(_loading);
				showHideLoading(false);
			} else {
				_loading = null;
				loadingLen = 0;
			}
			if (needRreshScroll>0) {
				container.y += needRreshScroll;
				scroll.refresh();
			}
		}
		
		public function showHideLoading(bool:Boolean):void {
			if (_loading) {
				_loading.visible = bool;
				if (bool) {
					_loading.play();
				} else {
					_loading.stop();
				}
			}
		}
		
		public function scrollToSelection():void {
			if (lazyInit) {
				lazyInit = false;
				dataProvider = _data
				selectedIndex = _selectedIndex
				_data = null;
			}
			if (container.height>scroll.height) {
				if (_selectedIndex >= 0) {
					var item:KItemRenderer = container.getChildAt(_selectedIndex) as KItemRenderer
					container.y = Math.max(scroll.height-container.height, -item.y)+scroll.y
				}
			}
		}
		
		public function kill():void {
			scroll = null;
		}
	}
}