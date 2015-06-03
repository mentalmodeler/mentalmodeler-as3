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
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	import com.jonnybomb.ui.components.Slider;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
			
			//trace('e.target:'+e.target);
			/*
			if (e.target is UIButton && (e.target as DisplayObject).parent is LineValueMenuButton)
			{
				var lvmb:LineValueMenuButton = LineValueMenuButton((e.target as DisplayObject).parent)
				_controller.lineValue = lvmb.value;
			}
			*/
			if (e.target is Slider || e.target is UIButton || (e.target as DisplayObject).parent == this) {
				
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
			var w:int = 58;
			var h:int = 160;
			var sliderWidth:int = 30;
			var sliderHeight:int = 120;
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
				
			//public function Slider(width:int, height:int, type:int, values:Object, styles:Object)
			_slider = addChild( new Slider(sliderWidth, sliderHeight, Slider.NOTCHED, CMapConstants.INFLUENCE_LINE_VALUES, styles, Slider.VERT) ) as Slider;
			//_slider.rotation = -90;
			_slider.y = padding;
			_slider.x = padding;
			_slider.addEventListener(Event.CHANGE, onSliderChange, false, 0, true);
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
			icon.x = _slider.x + _slider.width + padding;
			icon.y = padding + 2;
			// value text field
			_valueTfHolder = addChild(new Sprite()) as Sprite;
			_valueTfHolder.x = padding;
			_valueTfHolder.y = _slider.height + padding * 2;
			var g:Graphics = _valueTfHolder.graphics;
			g.beginFill(0x454545);
			g.drawRoundRect(0, 0, 48, 25, 5, 5);
			g.endFill();
			
			var tfPaddingX:int = 5;
			var tfPaddingY:int = 5;
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "VerdanaEmbedded";
			textFormat.size = 15;
			textFormat.bold = true;
			textFormat.letterSpacing = 0;
			textFormat.color = 0xffffff;
			textFormat.align = TextFormatAlign.CENTER;
			
			_valueTf = _valueTfHolder.addChild(new TextField()) as TextField;
			_valueTf.x = 24;
			_valueTf.addEventListener(Event.CHANGE, handleTextChange, false, 0, true);
			_valueTf.type = TextFieldType.INPUT;
			_valueTf.defaultTextFormat = textFormat
			_valueTf.antiAliasType = AntiAliasType.ADVANCED;
			_valueTf.embedFonts = true;
			_valueTf.wordWrap = false; //true;
			_valueTf.multiline = true;
			_valueTf.width = 1; //30;
			_valueTf.height = 1; //30;
			_valueTf.background = false;
			_valueTf.backgroundColor = 0xFFFFFF;
			_valueTf.selectable = true;
			_valueTf.mouseEnabled = false;
			_valueTf.mouseWheelEnabled = false;
			_valueTf.autoSize = TextFieldAutoSize.CENTER;
			onSliderChange(null);
		}
		
		private function drawIcon(h:int):Sprite {
			var w:int = 10;
			var t:int = 2;
			var pct:Number = 0.2;
			var color:uint = 0x454545;
			var s:Sprite = new Sprite();
			
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
			g.drawRect( (w-t)/2, w + t*2, t, h - (w*2 + t*2) );
			g.endFill();
			var minus:Sprite = s.addChild(new Sprite()) as Sprite;
			g = minus.graphics;
			g.beginFill(color);
			g.drawRect(0, h - (w/2), w, t);
			g.endFill();	
			return s;	
		}
		
		private function handleTextChange(e:Event):void {
		}
		
		private function onSliderChange(e:Event):void {
			var value:Number = _slider.value;
			_value = 0 - (Math.floor(value * 100) / 100);
			_valueTf.text = _value.toString();
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