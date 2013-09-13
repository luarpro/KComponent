package com.kcly.component.container {
	import com.greensock.TweenMax;
	import com.kcly.component.control.KButton;
	import com.kcly.component.KCore;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;

	public class KScreenNavigator extends Sprite {
		public static var titlePositionLeft:String = "left";
		public static var titlePositionCenter:String = "center";
		public static var titlePositionRight:String = "right";
		public static var SCREEN_NAV_BACK:String = "KScreenNavBack";
		
		private var container:Sprite
		private var titleBar:Sprite;
		private var _titleLogo:Bitmap;
		private var btn_back:KButton;
		
		private var curScreenIndex:int = 0;
		private var titleSettingObj:Array = []
		private var contentA:Array
		
		public function KScreenNavigator(bgColor0:Number, bgColor1:Number, titleBarInitW:int, titleBarInitH:int, padding:int) {
			titleBar = new Sprite;

			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(titleBarInitW, titleBarInitH, (Math.PI/180)*90, 0, 00);
			titleBar.graphics.beginGradientFill(GradientType.LINEAR, [bgColor0, bgColor1], [1, 1], [0,255], matrix);
			titleBar.graphics.drawRect(0, 0,titleBarInitW,titleBarInitH);
			titleBar.graphics.endFill();
			
			btn_back = new KButton
			btn_back.setSize(1, titleBarInitH)
			btn_back.label = KCore.btnBackLabel
			btn_back.followLabelSize(20);
			btn_back.addEventListener(MouseEvent.CLICK, onBackClick)
			titleBar.addChild(btn_back);
			
			titleBar.visible = false;
			addChild(titleBar)
			
			container = new Sprite
			addChild(container);
			
			titleSettingObj = [];
			contentA = []
		}
		
		public function get currentScreen():KScreen {
			return contentA[curScreenIndex] as KScreen
		}
		
		public function set titleLogo(bmpClass:Bitmap):void {
			if (_titleLogo) {
				_titleLogo.bitmapData.dispose();
				_titleLogo = null;
				titleBar.removeChild(_titleLogo) 
			}
			_titleLogo = bmpClass
			_titleLogo.y = (titleBar.height - _titleLogo.height) / 2;
			titleBar.addChild(_titleLogo);
			
			
			titleLogoPosition = KScreenNavigator.titlePositionCenter
		}
		
		public function set titleLogoPosition(str:String):void {
			var xpos:int;
			switch (str) {
				case KScreenNavigator.titlePositionLeft:
					xpos = 10
					break;
				case KScreenNavigator.titlePositionCenter:
					xpos = (KCore.stageW - _titleLogo.width) / 2;
					break;
				case KScreenNavigator.titlePositionRight:
					xpos = KCore.stageW - _titleLogo.width - 10;
					break;
			}
			TweenMax.to(_titleLogo,KCore.tweenDur,{x:xpos})
		}
		
		public function addScreen(mc:KScreen, isRoot:Boolean = false, showTitleBar:Boolean = true, titlePos:String = "center"):void {
			if (!titleBar.visible && showTitleBar) {
				_titleLogo.x = KCore.stageW
			}
			titleBar.visible = showTitleBar;
			titleLogoPosition = titlePos;
			titleSettingObj.push([showTitleBar, titlePos])
			if (!isRoot) {
				btn_back.x = 100 * KCore.scale;
				btn_back.alpha = 0;
				TweenMax.to(btn_back, KCore.tweenDur, { x:0, alpha:1 } );
				var mc1:KScreen = contentA[curScreenIndex] as KScreen;
				TweenMax.to(mc1, KCore.tweenDur, { x: -KCore.stageW, onStart:onCurrentMoveToLeft, onStartParams:[mc1], onComplete:onCurrentMovedToLeft, onCompleteParams:[mc1] } );
				mc.x = KCore.stageW;
				mc.y = titleBar.height;
				container.addChild(mc);
				contentA.push(mc)
				curScreenIndex++;
				TweenMax.to(mc, KCore.tweenDur, { x:0, onStart:onNewAdd, onStartParams:[mc], onComplete:onNewAdded, onCompleteParams:[mc] } );
			} else {
				container.addChild(mc);
				contentA.push(mc)
			}
		}		
		
		public function goRoot():void {
				removeAllScreensExceptRoot();
				onBackClick();
		}
		
		public function removeAllScreensExceptRoot():void {
			var len:int = contentA.length - 1;
			for (var i:int = 1; i < len; i++ ) {
				contentA.splice(1, 1);
				titleSettingObj.splice(1, 1);
			}
			trace ('removeChildren', contentA.length, container.numChildren)
			curScreenIndex = 1;
		}
		
		public function onBackClick(evt:MouseEvent = null):void {
			trace ('onBackClick', titleSettingObj.length)
			if (titleSettingObj.length>1) {
				titleSettingObj.pop()
				var obj:Array = titleSettingObj[titleSettingObj.length - 1];
				titleBar.visible = obj[0];
				titleLogoPosition = obj[1];
				
				var mc1:KScreen = contentA[curScreenIndex] as KScreen;
				TweenMax.to(mc1, KCore.tweenDur, { x:KCore.stageW, onStart:onCurrentRemove, onStartParams:[mc1], onComplete:onCurrentRemoved, onCompleteParams:[mc1] } );
				curScreenIndex--;
				var mc2:KScreen = contentA[curScreenIndex] as KScreen;
				container.addChild(mc2)
				TweenMax.to(mc2, KCore.tweenDur, { x:0, onStart:onPreviousReshow, onStartParams:[mc2], onComplete:onPreviousReshowed, onCompleteParams:[mc2] } )
				dispatchEvent(new Event(KScreenNavigator.SCREEN_NAV_BACK));
			}
		}

		private function onCurrentMoveToLeft(mc:KScreen):void {
			mc.beforeHide();
		}
		private function onCurrentMovedToLeft(mc:KScreen):void {
			container.removeChild(mc);
			mc.movedToLeft();
		}		
		private function onNewAdd(mc:KScreen):void {
			mc.beforeShow();
		}
		private function onNewAdded(mc:KScreen):void {
			mc.show();
		}		
		
		private function onCurrentRemove(mc:KScreen):void {
			mc.beforeHide();
		}
		private function onCurrentRemoved(mc:KScreen):void {
			container.removeChild(mc);
			mc.hide();
			contentA.pop();
		}
		private function onPreviousReshow(mc:KScreen):void {
			mc.beforeShow();
		}
		private function onPreviousReshowed(mc:KScreen):void {
			mc.reshow();
			
		}
	}
}