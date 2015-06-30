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
			if (e.target is UIButton && (e.target as DisplayObject).parent is LineValueMenuButton)
			{
			var lvmb:LineValueMenuButton = LineValueMenuButton((e.target as DisplayObject).parent)
			_controller.lineValue = lvmb.value;
			}
			*/
			var dObj:DisplayObject = (e.target as DisplayObject);
			if (e.target is Slider || dObj.parent == _slider || dObj.parent == this || e.target == _valueTf || e.target == _removeButton) {
				
			} else {
				hide();	
			}
		}
		
		private function build():void
		{
			filters = [CMapConstants.CD_DROP_SHADOW];
			var _ellipse:int = 10;
			var stroke:int = 1;
			var padding:int = 5;
			var w:int = 66;//56;
			var h:int = 133; //153;
			var sliderWidth:int = 30;
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
			_slider = addChild( new Slider(sliderWidth, sliderHeight, Slider.NOTCHED, CMapConstants.INFLUENCE_LINE_VALUES, styles, Slider.VERT) ) as Slider;
			//_slider.rotation = -90;
			_slider.y = padding;
			_slider.x = padding + xAdj;
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
			
			var icon:Sprite = addChild( drawIcon(sliderHeight) ) as Sprite;
			icon.mouseEnabled = false;
			icon.mouseChildren = false;
			var x2col:Number = _slider.x + _slider.width + padding*2;
			var y2row:Number = _slider.height + padding * 2;
			icon.x = x2col;
			icon.y = padding + 2;
			// value text field
			_valueTfHolder = addChild(new Sprite()) as Sprite;
			_valueTfHolder.x = padding + xAdj;// + 4;
			_valueTfHolder.y = _slider.height + (padding * 2) - 2;
			//_valueTfHolder.mouseChildren = true;
			//_valueTfHolder.mouseEnabled = false;
			var g:Graphics = _valueTfHolder.graphics;
			g.beginFill(0x557302);//0x454545);
			g.drawRoundRect(0, 0, sliderWidth, 20, 5, 5);
			g.endFill();
			
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
			_valueTf.x = 13;
			_valueTf.y = 0;
			_valueTf.maxChars = 4;
			_valueTf.restrict = '0-9\-.';
			_valueTf.filters = [ new DropShadowFilter(1, 180, 0, 0.3, 1, 1, 0.5) ];
			_valueTf.addEventListener(Event.CHANGE, handleTextChange, false, 0, true);
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
			
			var bEllispe:int = CMapConstants.BUTTON_ELLIPSE;
			var props:Object = {};
			props[UIButton.WIDTH] = 20;
			props[UIButton.HEIGHT] = 20;
			props[UIButton.ELLIPSE] = {tr:bEllispe, tl:bEllispe, br:bEllispe, bl:bEllispe};
			props[UIButton.USE_DROP_SHADOW] = true;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 1;
			_removeButton = addChild(new UIButton(props)) as UIButton;
			_removeButton.y = _valueTfHolder.y;
			_removeButton.x = _valueTfHolder.x + _valueTfHolder.width + padding;
			var deleteIcon:Sprite = drawDeleteIcon();
			deleteIcon.x = 6;
			deleteIcon.y = 8;
			deleteIcon.filters = [CMapConstants.INSET_BEVEL];
			_removeButton.addLabel( deleteIcon );
			
			
		}
		
		private function drawIcon(h:int):Sprite {
			var w:int = 10;
			var t:int = 2;
			var pct:Number = 0.2;
			var color:uint = 0x454545;
			var s:Sprite = new Sprite();
			s.filters = [CMapConstants.INSET_BEVEL];
			
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
		}
		
		private function onSliderChange(e:Event):void {
			_value = getValue();
			_valueTf.text = _value.toString();
		}
		
		private function onSliderComplete(e:Event):void {
			_value = getValue();
			trace('onSliderComplete, _value:'+_value);
			_valueTf.text = _value.toString();
			// LineValueData(stringValue:String = CMapConstants.INFLUENCE_STRING_VALUE_UNDEFINED, value:Number = UNDEFINED_VALUE, label:String = "", size:int = 15, color:uint = 0x000000, x:Number = 0, y:Number = 0, letterSpacing:int = 0)
			var lvd:LineValueData = new LineValueData(CMapConstants.INFLUENCE_STRING_VALUE_UNDEFINED, _value, "?", 15, 0x000000, -1, -1);
			_controller.lineValue = lvd;
		}
		
		private function getValue():Number {
			var value:Number = _slider.value;
			value = 0 - (Math.floor(value * 100) / 100);
			value = MathUtil.normalize(value, -1, 1);
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