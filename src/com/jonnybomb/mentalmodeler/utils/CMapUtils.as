package com.jonnybomb.mentalmodeler.utils
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class CMapUtils
	{
		public static function makeId():String
		{
			var s:String = '';
			var i:int;
			var c:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
			for ( i=0; i<8; i++ ) { 
				s += c.charAt(Math.floor(Math.random() * (i === 0 ? c.length-10 : c.length) ));
			}
			return s;
		}
		
		/*
		public static function getLineValueDataByStringValue(stringValue:String, datas:Vector.<LineValueData>):LineValueData
		{
			var lvd:LineValueData;
			for each (lvd in datas)
			{
				if (lvd.stringValue == stringValue)
					return lvd;
			}
			return CMapConstants.LINE_VALUE_DEFAULT;
		}
		*/
		
		public static function getLineValueDataByValue( value:Number ):LineValueData {
			// set color
			var color:uint = 0;
			var label:String = '?';
			var size:int= 15;
			var x:int = -1;
			var y:int = 1;
			var letterSpacing:int = 1;
			
			if  (value > 0 ) {
				color = CMapConstants.LINE_COLOR_POSITIVE;
				label = '+';
				x = 0;
				y = -1;
			} else if (value < 0) {
				color = CMapConstants.LINE_COLOR_NEGATIVE
				label = '-';
				x = 1;
				y = -1;
				letterSpacing = 3;
			}
			var lvd:LineValueData = LineValueData.getLineValueData( value.toString(), value, label, size, color, x, y, letterSpacing);
			//trace('lvd:'+lvd);
			return lvd;
		}
		/*
		public static function getLineValueDataByLabel(label:String, datas:Vector.<LineValueData>):LineValueData
		{
			var lvd:LineValueData;
			for each (lvd in datas)
			{
				if (lvd.label == label)
					return lvd;
			}
			return CMapConstants.LINE_VALUE_EMPTY;
		}
		*/
		
		public static function createTextField(text:String, props:Object):TextField
		{
			var format:TextFormat = new TextFormat();
			format.color = getProp(props, "color", 0x000000);
			format.size = getProp(props, "size", 16);
			format.font = "VerdanaEmbedded";
			format.bold = getProp(props, "bold", false);
			format.align = getProp(props, "align", TextFormatAlign.CENTER);
			format.leading = getProp(props, "leading", 0);
			format.italic = getProp(props, "italic", false);
			format.kerning = 0;
			format.letterSpacing = getProp(props, "letterSpacing", 0);
			
			var tf:TextField = new TextField();
			tf.embedFonts = true;
			tf.defaultTextFormat = format;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.background = getProp(props, "background", false);
			tf.backgroundColor = getProp(props, "backgroundColor", 0xFFFFFF);
			tf.border = getProp(props, "border", false);
			tf.borderColor = getProp(props, "borderColor", 0xFFFFFF);
			tf.type = getProp(props, "type", TextFieldType.DYNAMIC);
			tf.selectable = getProp(props, "selectable", false)
			tf.autoSize = getProp(props, "autoSize", TextFieldAutoSize.LEFT);
			tf.wordWrap = getProp(props, "wordWrap", false);
			tf.multiline = getProp(props, "multiline", false);
			tf.mouseEnabled = getProp(props, "mouseEnabled", false);
			tf.mouseWheelEnabled = false;
			tf.width = getProp(props, "width", 10);
			
			if (props.html)
				tf.htmlText = text;
			else
				tf.text = text;
			
			tf.height = getProp(props, "height", tf.textHeight);
			
			return tf;
		}
		
		private static function getProp(o:Object, prop:String, defaultValue:*):*
		{
			var value:* = defaultValue;
			if (o[prop] || o[prop] == 0)
				value = o[prop]; 
			return value;
		}
	}
}