package com.jonnybomb.mentalmodeler.display
{
	
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.controls.LineValueMenuButton;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.math.MathUtil;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	import com.jonnybomb.ui.components.Slider;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class LineValueMenuDisplay extends Sprite
	{
		private var _buttons:Vector.<LineValueMenuButton> = new Vector.<LineValueMenuButton>();
		private var _controller:CMapController;
		private var _slider:Slider;
		private var _bg:Sprite;
		private var _valueTf:TextField;
		private var _valueTfHolder:Sprite;
		private var _value:Number;
		private var _removeButton:UIButton;
		
		private var _height:Number;
		override public function get height():Number { return _height; }
		
		public function LineValueMenuDisplay(controller:CMapController)
		{
			visible = false;
			_controller = controller;
			init();
		}
		
		public function show(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
			visible = true;
			
			if (stage)
				stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
		}
		
		public function hide():void
		{
			visible = false;
			
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		private function init():void
		{
			build();
			layout();
		}
		
		private function handleMouseDown(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			e.preventDefault();
			
			/*
			if (e.target is UIButton && (e.target as DisplayObject).parent is LineValueMenuButton) {
				var lvmb:LineValueMenuButton = LineValueMenuButton((e.target as DisplayObject).parent)
				_controller.lineValue = lvmb.value;
			}
			*/
			if ( !this.contains( e.target as DisplayObject ) ) {	
				hide(); 
			}
		}
		
		private function build():void
		{
			filters = [CMapConstants.CD_DROP_SHADOW];
			var _ellipse:int = 10;
			var stroke:int = 1;
			var paddingX:int = 4;
			var paddingY:int = 6;
			var w:int = 58;//56;
			var h:int = 133; //153;
			var sliderWidth:int = 28;
			var sliderHeight:int = 100; //120;
			_bg = this.addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_bg, w, h, ColorData.getColor(ColorData.MENU), stroke, _ellipse);
			
			var handle:Object = { up:ColorData.getColor(ColorData.BUTTON_UP),
				over:ColorData.getColor(ColorData.BUTTON_OVER),
				bevel:ColorData.getColor(ColorData.BUTTON_BEVEL)
			};
			var styles:Object = { bg: new ColorData(null, new ColorExtended(0x888888)),
				bgColor:0x888888,
				ellipse:8,
				handle:handle
			};
			var xAdj:int = - Math.round(w/2);
			_bg.x = xAdj;
			//public function Slider(width:int, height:int, type:int, values:Object, styles:Object)
			_slider = addChild( new Slider(sliderWidth, sliderHeight, Slider.CONTINUOUS, CMapConstants.INFLUENCE_LINE_VALUES, styles, Slider.VERT) ) as Slider;
			//_slider.rotation = -90;
			_slider.y = paddingY;
			_slider.x = paddingX + xAdj;
			_slider.addEventListener(Event.CHANGE, onSliderChange, false, 0, true);
			_slider.addEventListener(Event.COMPLETE, onSliderComplete, false, 0, true);
			/*
			var lvd:LineValueData;
			var options:Vector.<LineValueData> = CMapConstants.LINE_VALUES;
			var button:LineValueMenuButton;
			var len:int = options.length;
			for each (lvd in options)
			{
			button = addChild(new LineValueMenuButton(lvd, options.indexOf(lvd), len + 1)) as LineValueMenuButton;
			_buttons.push(button);
			}
			
			button = addChild(new LineValueMenuButton(new LineValueData(CMapConstants.INFLUENCE_STRING_VALUE_NULL, LineValueData.REMOVE_VALUE, CMapConstants.LINE_VALUE_REMOVE_LABEL), len, len + 1)) as LineValueMenuButton;
			_buttons.push(button);
			*/
			
			var icon:Sprite = addChildAt( drawIcon(sliderHeight), 1 ) as Sprite;
			icon.mouseEnabled = false;
			icon.mouseChildren = false;
//			var x2col:Number = _slider.x + _slider.width + paddingX * 2;
//			var y2row:Number = _slider.height + paddingY * 2;
//			var sW:Number = _slider.x + sliderWidth + paddingX * 1.5;
//			var remaining:Number = w - sW; 
//			trace("remaining:"+remaining+", sW:"+sW+", w:"+w);
			var sW:Number = sliderWidth + paddingX * 1.5;
			var sX:Number = _slider.x + sW;
			var rema:Number = w - sW;
			icon.x = xAdj + (sW - icon.width)/2;//sX + 2;//(rema - icon.width)/2; //sW + (remaining - icon.width)/2;
			icon.y = paddingY + 2;
			// value text field
			
			var bEllipse:int = CMapConstants.BUTTON_ELLIPSE;
			var bHeight:int = 24;
			var bY:int = _bg.height - bHeight;
				
			var props:Object = {};
			var ds:DropShadowFilter = new DropShadowFilter(2, 90, 0, 0.5, 5, 5, 1, 1, true);//2, 90, 0x000000, 0.5, 5, 5, 1, 1);
			props[ UIButton.STATE_COLORS ] = handle;
			props[ UIButton.WIDTH ] = sW;
			props[ UIButton.HEIGHT ] = bHeight;
			props[UIButton.ELLIPSE] = {tr:0, tl:0, br:0, bl:bEllipse};
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			_valueTfHolder = addChild( new UIButton(props) ) as Sprite;
			_valueTfHolder.x = xAdj;
			_valueTfHolder.y = bY;
			_valueTfHolder.mouseEnabled = false;
			_valueTfHolder.mouseChildren = true;
			_valueTfHolder.buttonMode = false;
			_valueTfHolder.addEventListener(MouseEvent.CLICK, onTfButtonClick, false, 0 ,true);
			// delete button
			var gap:int = 0;
			props = {};
			props[UIButton.WIDTH] = rema;
			props[UIButton.HEIGHT] = bHeight;
			props[UIButton.ELLIPSE] = {tr:0, tl:0, br:bEllipse, bl:0};
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			_removeButton = addChild(new UIButton(props)) as UIButton;
			_removeButton.y = _valueTfHolder.y;
			_removeButton.x = _valueTfHolder.x + _valueTfHolder.width + gap;
			var deleteIcon:Sprite = drawDeleteIcon();
			deleteIcon.x = 8;
			deleteIcon.y = 8;
			deleteIcon.filters = [CMapConstants.INSET_BEVEL];
			_removeButton.addLabel( deleteIcon );
			/*
			_valueTfHolder = addChild(new Sprite()) as Sprite;
			_valueTfHolder.x = padding + xAdj;// + 4;
			_valueTfHolder.y = _slider.height + (padding * 2) - 2;
			var g:Graphics = _valueTfHolder.graphics;
			g.beginFill(0x557302);//0x454545);
			g.drawRoundRect(0, 0, sliderWidth, 20, 5, 5);
			g.endFill();
			*/
			
			/*var del:Sprite = addChild( drawDeleteIcon() ) as Sprite;
			del.y = _slider.height + padding * 2 + 5;
			del.x = x2col + 2;*/
			
			var tfPaddingX:int = 5;
			var tfPaddingY:int = 5;
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "VerdanaEmbedded";
			textFormat.size = 13;
			textFormat.bold = false;
			textFormat.letterSpacing = -1;
			textFormat.color = 0xffffff;
			textFormat.align = TextFormatAlign.CENTER;
			
			_valueTf = _valueTfHolder.addChild(new TextField()) as TextField;
			_valueTf.x = 16;
			_valueTf.y = 0;
			_valueTf.maxChars = 4;
			_valueTf.restrict = '0-9\-.';
			_valueTf.filters = [ new DropShadowFilter(1, 180, 0, 0.3, 1, 1, 0.5) ];
			_valueTf.addEventListener(Event.CHANGE, handleTextChange, false, 0, true);
			_valueTf.addEventListener(FocusEvent.FOCUS_OUT, handleTextFocus, false, 0, true);
			//_valueTf.addEventListener(MouseEvent.CHANGE, handleTextChange, false, 0, true);
			_valueTf.type = TextFieldType.INPUT;
			_valueTf.defaultTextFormat = textFormat
			_valueTf.antiAliasType = AntiAliasType.ADVANCED;
			_valueTf.embedFonts = true;
			_valueTf.wordWrap = false; //true;
			_valueTf.multiline = false;
			_valueTf.width = 1; //30;
			_valueTf.height = 1; //30;
			_valueTf.background = false;
			_valueTf.backgroundColor = 0xFFFFFF;
			_valueTf.selectable = true;
			_valueTf.mouseEnabled = true;
			_valueTf.mouseWheelEnabled = false;
			_valueTf.autoSize = TextFieldAutoSize.CENTER;
			
			onSliderComplete(null);
		}
		
		
		
		private function onTfButtonClick(e:MouseEvent):void {
			trace('ontfbuttonclick');
			stage.focus = _valueTf;
			var l:int = _valueTf.length;
			_valueTf.setSelection(l, l);
		}
		
		private function drawIcon(h:int):Sprite {
			var w:int = 20;
			var t:int = 2;
			//var pct:Number = 0.2;
			var color:uint = 0; //0x454545;
			var s:Sprite = new Sprite();
			s.cacheAsBitmap = true;
			s.alpha = 0.15;
			//s.filters = [CMapConstants.INSET_BEVEL];
			
			var plus:Sprite = s.addChild(new Sprite()) as Sprite;
			var g:Graphics = plus.graphics;
			g.beginFill(color);
			g.drawRect(0, (w - t)/2, w, t);
			g.drawRect((w - t)/2, 0, t, (w - t)/2);
			g.drawRect((w - t)/2, (w - t)/2 + t, t, (w - t)/2);
			g.endFill();			
			var icon:Sprite = s.addChild(new Sprite()) as Sprite;
			g = icon.graphics;
			g.beginFill(color);
			//g.drawRect( (w-t)/2, w + t*2, t, h - (w*2 + t*2) );
			var top:Number = w + t*2;
			var bot:Number = top + (h - (w*2 + t*4));
			var left:Number = 0;
			var right:Number = w;
			g.moveTo(left, top);
			g.lineTo(right, bot);
			g.lineTo(left, bot);
			g.lineTo(right, top);
			g.lineTo(left, top);
			g.endFill();
			var minus:Sprite = s.addChild(new Sprite()) as Sprite;
			g = minus.graphics;
			g.beginFill(color);
			g.drawRect(0, h - (w/2 + t), w, t);
			g.endFill();	
			return s;	
		}
		
		private function drawDeleteIcon():Sprite {
			var bodyWidth:int = 8;
			var bodyHeight:int = 8;
			var topHeight:int = 3;
			var topBrimExtra:int = 1;
			
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			//g.lineStyle(1, 0xFFFFFF);
			g.beginFill(0xFFFFFF);
			g.moveTo(0,0);
			g.lineTo(bodyWidth, 0);
			g.lineTo(bodyWidth, bodyHeight);
			g.lineTo(0, bodyHeight);
			g.lineTo(0, 0);
			g.moveTo(- topBrimExtra, -1);
			g.lineTo(topBrimExtra + bodyWidth, -1);
			g.lineTo(topBrimExtra + bodyWidth, -3);
			g.lineTo(bodyWidth - 2, -3);
			g.lineTo(bodyWidth - 2, -4);
			g.lineTo(bodyWidth - 6, -4);
			g.lineTo(bodyWidth - 6, -3);
			g.lineTo(- topBrimExtra, -3);
			g.lineTo(- topBrimExtra, -1);
			g.endFill();
			return s;
		}
		
		private function handleTextChange(e:Event):void {
//			var n:Number = parseFloat( _valueTf.text );
//			n = MathUtil.normalize( MathUtil.roundToDecimal(n, 10), -1, 1);
//			trace("n:"+n);
		}
		
		private function handleTextFocus(e:FocusEvent):void {
			var n:Number = parseFloat( _valueTf.text );
			n = MathUtil.normalize( MathUtil.roundToDecimal(n, 10), -1, 1);
			if ( isNaN(n) ) {
				n = 0;
			}
			_valueTf.text = n.toString();
			setValue(0-n, "tf")
		}
		
		private function onSliderChange(e:Event):void {
			setValue( getValue(), "slider");
		}
		
		private function setValue(value:Number, source:String):void {
			_value = value;
			switch (source) {
				case 'slider':
					_valueTf.text = _value.toString();
					break;
				case 'tf':
					_slider.setValue( value, false );
					break;
			}
			// LineValueData(stringValue:String = CMapConstants.INFLUENCE_STRING_VALUE_UNDEFINED, value:Number = UNDEFINED_VALUE, label:String = "", size:int = 15, color:uint = 0x000000, x:Number = 0, y:Number = 0, letterSpacing:int = 0)
			var lvd:LineValueData = new LineValueData(CMapConstants.INFLUENCE_STRING_VALUE_UNDEFINED, value, "?", 15, 0x000000, -1, -1);
			_controller.lineValue = lvd;
		}
		
		private function onSliderComplete(e:Event):void {
			setValue( getValue(), "slider");	
		}
		
		private function getValue():Number {
			var value:Number = _slider.value;
			trace("getValue, value:"+value);
			trace(" value:"+value);
			value = MathUtil.normalize( MathUtil.roundToDecimal(value, 2), -1, 1);
			trace(" value:"+value);
			return value;
		}
		
		private function layout():void
		{
			var h:int = CMapConstants.LINE_VALUE_HEIGHT;
			var nY:int = h/2;
			var border:int = CMapConstants.LINE_VALUE_BORDER;
			var button:LineValueMenuButton
			for each (button in _buttons)
			{
				button.y = nY;
				nY += h - border;
			}
			
			_height = nY + h/2
		}
		
		public function finalize():void
		{
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			
			for each (var button:LineValueMenuButton in _buttons)
			DisplayObjectUtil.finalizeAndRemove(button);
			
			_buttons = null
			_controller = null;
		}
	}
}