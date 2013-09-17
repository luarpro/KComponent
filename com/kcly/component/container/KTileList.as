package com.kcly.component.container {
	import com.greensock.TweenMax;
	import com.kcly.component.KCore;
	import com.kcly.component.renderer.KItemRenderer;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	public class KTileList extends KList {
		private var gapH:int;
		private var gapV:int;
		private var offsetY:int;
		private var offsetX:int;
		public var itemW:int;
		
		public function KTileList(w:int, h:int, maxWidth:int=0, paddingH:int=0, paddingV:int = 0, gapH:int = 0, gapV:int = 0, lazyInit:Boolean=false, allowPullRefresh:Boolean=false, allowPaging:Boolean=false, rendererClass:Class=null) {
			this.gapH = gapH;
			this.gapV = gapV;
			super(w, h, false, null, lazyInit, allowPullRefresh, allowPaging, rendererClass);
			_paddingH = paddingH;
			_paddingV = paddingV;
			if (maxWidth>0) {
				itemW = maxWidth + gapH
				var viewW:int = w - paddingH*2
				var colNo:int = 1;
				while (itemW*colNo<viewW) {
					colNo++;
				}
				// formula: colNo * itemW + (colNo - 1) * gapH = viewW;
				itemW = (viewW - (colNo-1) * gapH) / colNo
			}
		}
		
		override public function removeAll():void {
			super.removeAll();
			offsetY = _paddingV;
			offsetX = _paddingH;
		}
		
		override public function removeItemAt(no:int):void {
			if (no > 0) {
				var item:KItemRenderer = container.getChildAt(no) as KItemRenderer
				offsetY = item.y;
				offsetX = item.x;
			} else {
				offsetY = _paddingV;
				offsetX = _paddingH;
			}
			super.removeItemAt(no);
		}
		
		override public function refresh(useTween:Boolean = false, startIndex:int = 0):void {
			refreshFooterLoading();
			var len:int = container.numChildren - footerLen - loadingLen;
			
			for (var i:int = startIndex; i < len; i++) {
				var item:KItemRenderer = container.getChildAt(i) as KItemRenderer
				item.x = offsetX
				item.y = offsetY;
				if (item.x + item.width > baseW) {
					offsetX = _paddingH
					offsetY += item.height + gapV;
					item.x = offsetX
					item.y = offsetY;
				}
				offsetX += item.width + gapH;
			}
			positionFooterLoading(useTween, (item) ? offsetY + item.height: offsetY);

			var containerH:int = offsetY + gapV + _paddingV;
			if (item) {
				containerH += item.height;
			}
			container.graphics.clear();
			container.graphics.beginFill(0xff0000, 0);
			container.graphics.drawRect(0, 0, 1, containerH);
			container.graphics.endFill();
			
			if (useTween) {
				var diff:int = scroll.height - offsetY;
				if (container.y < diff) {
					var obj:Object = { y:Math.min(0, diff) };
					if (!footerItem) {
						obj.onComplete = onContainerTweeenDone;
					}
					TweenMax.to(container, KCore.tweenDur, obj);
				} else {
					setTimeout(onContainerTweeenDone, KCore.tweenDur * 1000);
				}
			} else if (stage) {
				scroll.refresh();
			}
			if (allowPaging && len>0 && offsetY <= scroll.height) {
				dispatchEvent(new Event(KList.NEED_PAGING));
			}
		}
	}
}