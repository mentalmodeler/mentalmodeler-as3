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
			var w:int = 56;
			var h:int = 153;
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
			var xAdj:int = - Math.round(w/2);
			_bg.x = xAdj;
			//public function Slider(width:int, height:int, type:int, values:Object, styles:Object)
			_slider = addChild( new Slider(sliderWidth, sliderHeight, Slider.NOTCHED, CMapConstants.INFLUENCE_LINE_VALUES, styles, Slider.VERT) ) as Slider;
			//_slider.rotation = -90;
			_slider.y = padding;
			_slider.x = padding + xAdj;
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
			var x2col:Number = _slider.x + _slider.width + padding/2;
			var y2row:Number = _slider.height + padding * 2;
			icon.x = x2col;
			icon.y = padding + 2;
			// value text field
			_valueTfHolder = addChild(new Sprite()) as Sprite;
			_valueTfHolder.x = padding + xAdj + 4;
			_valueTfHolder.y = _slider.height + padding * 2;
			var g:Graphics = _valueTfHolder.graphics;
			g.beginFill(0x557302);//0x454545);
			g.drawRoundRect(0, 0, 24, 17, 5, 5);
			g.endFill();
			
			var del:Sprite = addChild( drawDeleteIcon() ) as Sprite;
			del.y = _slider.height + padding * 2 + 5;
			del.x = x2col + 2;
			
			var tfPaddingX:int = 5;
			var tfPaddingY:int = 5;
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "VerdanaEmbedded";
			textFormat.size = 11;
			textFormat.bold = false;
			textFormat.letterSpacing = -1;
			textFormat.color = 0xffffff;
			textFormat.align = TextFormatAlign.CENTER;
			
			_valueTf = _valueTfHolder.addChild(new TextField()) as TextField;
			_valueTf.x = 10;
			_valueTf.y = 0;
			_valueTf.filters = [ new DropShadowFilter(1, 180, 0, 0.3, 1, 1, 0.5) ];
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
			
			/*var s:Sprite = addChild(new Sprite()) as Sprite;
			g = s.graphics;
			g.beginFill(0xff0000);
			g.drawCircle(0, 0 ,5);
			g.endFill();*/
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
		
		private function drawDeleteIcon():Sprite {
			var bodyWidth:int = 8;
			var bodyheight:int = 10;
			var topHeight:int = 4;
			var topBrimExtra:int = 2;
			
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.lineStyle(2, 0x787878);
			g.moveTo(0,0);
			g.lineTo(0,bodyheight);
			g.lineTo(bodyWidth/2,bodyheight);
			g.lineTo(bodyWidth/2,0);
			g.moveTo(bodyWidth/2,bodyheight);
			g.lineTo(bodyWidth,bodyheight);
			g.lineTo(bodyWidth,0);
			g.moveTo(0 - topBrimExtra, 0);
			g.lineTo(bodyWidth + topBrimExtra, 0);
			g.moveTo(0, 0);
			g.lineTo(0, -topHeight);
			g.lineTo(bodyWidth, -topHeight);
			g.lineTo(bodyWidth, 0);
			
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