package com.kcly.component.control {
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class MaxRowsTextField extends TextField {
		public var maxRows:int = 0;	// 0 = unlimited rows
		public var moreStr:String = "...";
		private var rawText:String;
		private var enterframeCount:int;
		private var showRows:int = 0;
		
		public function MaxRowsTextField(){
			super();
		}
		
		// if no need abbreviation, you call use htmlText directly
		public function set text2(str:String):void {
			removeEventListener(Event.ENTER_FRAME, render);
			rawText = str;
			text = str;
			if (maxRows > 0) {
				enterframeCount = 0;
				addEventListener(Event.ENTER_FRAME, render);
			}
		}
		public function get text2():String {
			return rawText;
		}
		
		// Flash Player bug, cannot get the correct numLines, height when TextField.text is changed, it must wait one frame later.
		// Since after adding moreStr (...), numLines may be change again, extra characters need to be omitted, so, using enterframe to loop through until maxrows reached.
		private function render(evt:Event):void {
			if (enterframeCount == 0) {
				showRows = (numLines > maxRows) ? maxRows : numLines;
			} else if (enterframeCount > 0) {
				if (numLines > showRows){
					var no:int = 0;
					for (var i:int = 0; i < showRows; i++){
						no += getLineLength(i);
					}
					// if you want more accurate result, you should not deduct moreStr.length
					// but it requires more enterframe time to reach the right extractCount
					var extractCount:int = no - moreStr.length - enterframeCount;
					text = rawText.substr(0, extractCount) + moreStr;
				} else {
					removeEventListener(Event.ENTER_FRAME, render);
					autoSize = TextFieldAutoSize.LEFT
					dispatchEvent(new Event(Event.RENDER, true))
				}
			}
			enterframeCount++;
		}
	}
}