package com.kcly.component.control {
	import flash.text.SoftKeyboardType;
	public class KTextArea extends KTextInput {
		
		public function KTextArea(w:int, h:int, withDisplayText:Boolean, numline:int=1, type:String=SoftKeyboardType.DEFAULT) {
			super(w, withDisplayText, type, h, numline)
		}
	}
}