package com.jonnybomb.mentalmodeler.display
{
	
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.controls.LineValueMenuButton;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
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
		private var _valueTfHolder:UIButton;
		private var _value:Number;
		private var _removeButton:UIButton;
		private var _removeButtonLVD:LineValueData;
		
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
			var line:InfluenceLineDisplay = _controller.model.curLine;
			var value:Number = line.influenceValue;
			trace("LineValueMenu.show > value:"+value)		
			setValue( line.influenceValue, 'both', false);
			//trace("LineValueMenu.show > _controller.model.curLine:"+_controller.model.curLine);
			//trace("line.influenceValue:"+line.influenceValue);
			//setValue( line.influenceValue, 'both')
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
			var bEllipse:int = CMapConstants.BUTTON_ELLIPSE;
			var bHeight:int = 20;
			var w:int = 36;//58;//56;
			var h:int = 130; //153;
			var sliderWidth:int = 28;
			var paddingX:int = (w - sliderWidth)/2;
			var paddingY:int = paddingX;
			var sliderHeight:int = h - (bHeight+paddingY)*2; //120;
			_bg = this.addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_bg, w, sliderHeight + paddingY*2, ColorData.getColor(ColorData.MENU), stroke);//, _ellipse);
			
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
			_bg.y = bHeight;
			//public function Slider(width:int, height:int, type:int, values:Object, styles:Object)
			_slider = addChild( new Slider(sliderWidth, sliderHeight, Slider.CONTINUOUS, CMapConstants.INFLUENCE_LINE_VALUES, styles, Slider.VERT) ) as Slider;
			//_slider.rotation = -90;
			_slider.y = bHeight + paddingY;
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
			
			// slider bg slope
			var icon:Sprite = addChildAt( drawIcon(sliderHeight, sliderWidth), 1 ) as Sprite;
			icon.mouseEnabled = false;
			icon.mouseChildren = false;
			icon.x = xAdj + paddingX;
			icon.y = bHeight + paddingY;			
			
			// input text button
			var bY:int = _bg.height + bHeight;
			var props:Object = {};
			var ds:DropShadowFilter = new DropShadowFilter(2, 90, 0, 0.5, 5, 5, 1, 1, true);//2, 90, 0x000000, 0.5, 5, 5, 1, 1);
			props[ UIButton.STATE_COLORS ] = handle;
			props[ UIButton.WIDTH ] = w;
			props[ UIButton.HEIGHT ] = bHeight;
			props[UIButton.ELLIPSE] = {tr:bEllipse, tl:bEllipse, br:0, bl:0};
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			_valueTfHolder = addChild( new UIButton(props) ) as UIButton;
			_valueTfHolder.x = xAdj;
			_valueTfHolder.y = 0;//bY;
			_valueTfHolder.mouseEnabled = false;
			_valueTfHolder.mouseChildren = true;
			_valueTfHolder.buttonMode = false;
			_valueTfHolder.addEventListener(MouseEvent.CLICK, onTfButtonClick, false, 0 ,true);
			
			// delete button
			var gap:int = 0;
			props = {};
			props[UIButton.WIDTH] = w;
			props[UIButton.HEIGHT] = bHeight;
			props[UIButton.ELLIPSE] = {tr:0, tl:0, br:bEllipse, bl:bEllipse};
			props[UIButton.USE_DROP_SHADOW] = false;
			props[UIButton.MOUSE_DOWN_DISTANCE] = 0;
			_removeButton = addChild(new UIButton(props)) as UIButton;
			_removeButton.y = bY;//0;
			_removeButton.x = xAdj;
			var deleteIcon:Sprite = DrawingUtil.drawDeleteIcon();
			deleteIcon.x = (w - deleteIcon.width)/2;
			deleteIcon.y = Math.floor( (bHeight - deleteIcon.height)/2 );
			deleteIcon.filters = [CMapConstants.INSET_BEVEL];
			_removeButton.addLabel( deleteIcon );
			_removeButton.addEventListener( MouseEvent.CLICK, onRemoveClick, false, 0, true);
			_removeButtonLVD = LineValueData.getLineValueData( '', 1000, CMapConstants.LINE_VALUE_REMOVE_LABEL );
			
			// input tf
			var tfPaddingX:int = 5;
			var tfPaddingY:int = 5;
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "VerdanaEmbedded";
			textFormat.size = 13;
			textFormat.bold = false;
			textFormat.letterSpacing = -1;
			textFormat.color = 0xffffff;
			textFormat.align = TextFormatAlign.CENTER;		
			_valueTf = new TextField();
			_valueTfHolder.addLabel( _valueTf );
			_valueTf.x = Math.floor(w/2 - 2);//xAdj;
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
			
			//onSliderComplete(null);
			setValue( getValue(), "slider", false);
		}
		
		private function onRemoveClick(e:MouseEvent):void {
			_controller.lineValue =_removeButtonLVD;
			hide();
		}		
		
		private function onTfButtonClick(e:MouseEvent):void {
			trace('ontfbuttonclick');
			stage.focus = _valueTf;
			var l:int = _valueTf.length;
			_valueTf.setSelection(l, l);
		}
		
		private function drawIcon(h:int, w:int):Sprite {
			var t:int = 1;
			var color:uint = 0x333333; //0x454545;
			var s:Sprite = new Sprite();
			s.cacheAsBitmap = true;
			var w2:int = 8;
			var plus:Sprite = s.addChild(new Sprite()) as Sprite;
			var g:Graphics = plus.graphics;
			g.beginFill(color);
			g.drawRect(0, (w2 - t)/2, w2, t);
			g.drawRect((w2 - t)/2, 0, t, (w2 - t)/2);
			g.drawRect((w2 - t)/2, (w2 - t)/2 + t, t, (w2 - t)/2);
			g.endFill();		
			plus.x = 21;
			plus.y = 0;
			var icon:Sprite = s.addChild(new Sprite()) as Sprite;
			g = icon.graphics;
			g.beginFill(0, 0.1);
			var top:Number = 0;
			var bot:Number = h;
			var left:Number = 0;
			var right:Number = w;
			var mid:Number = h/2;
			var midLeft:Number = left + (w - (w*0.25))/2;
			var midRight:Number = right - (w - (w*0.25))/2 
			g.moveTo(left, top);
			g.moveTo(midLeft, mid);
			g.lineTo(left, bot);
			g.lineTo(midRight, bot);
			g.lineTo(midRight, mid);
			g.lineTo(midRight, top);
			g.lineTo(left, top);
			g.endFill();
			t = 2;
			var minus:Sprite = s.addChild(new Sprite()) as Sprite;
			g = minus.graphics;
			g.beginFill(color);
			g.drawRect(0, h - (w2/2 + t), w2, t);
			g.endFill();
			minus.x = 21;
			minus.y = 4;
			return s;	
		}
		
		private function drawDeleteIcon():Sprite {
			var bodyWidth:int = 8;
			var bodyHeight:int = 8;
			var topHeight:int = 2;
			var topTopHeight:int = 1;
			var topBrimExtra:int = 2;
			var topTopBrimExtra:int = 1;
			var spacing:int = 1;
			var bodyTop:int = topTopHeight + topHeight + spacing;		
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.beginFill(0xffffff);;
			g.moveTo(topBrimExtra, bodyTop);
			g.lineTo(topBrimExtra + bodyWidth, bodyTop);
			g.lineTo(topBrimExtra + bodyWidth, bodyTop + bodyHeight);
			g.lineTo(topBrimExtra, bodyTop + bodyHeight);
			g.lineTo(topBrimExtra, bodyTop);
			g.moveTo( 0, topTopHeight + topHeight);
			g.lineTo(topBrimExtra*2 + bodyWidth, topTopHeight + topHeight);
			g.lineTo(topBrimExtra*2 + bodyWidth, topTopHeight);
			g.lineTo(topBrimExtra + bodyWidth - topTopBrimExtra, topTopHeight);
			g.lineTo(topBrimExtra + bodyWidth - topTopBrimExtra, 0);
			g.lineTo(topBrimExtra + topTopBrimExtra, 0);
			g.lineTo(topBrimExtra + topTopBrimExtra, topTopHeight);
			g.lineTo(0, topTopHeight);
			g.lineTo(0, topTopHeight + topHeight);
			g.endFill();	
			return s;
		}
		
		private function handleTextChange(e:Event):void {
			var t:String = _valueTf.text;
			if (t.indexOf('-') > -1 && t.indexOf('-') != 0 ) {
				t = t.replace('-', '');
				t = '-' + t;
			}
			if (t.indexOf('.') !== t.length - 1 ) {
				var n:Number = parseFloat( t );
				if ( !isNaN(n) ) {
					n = MathUtil.normalize( MathUtil.roundToDecimal(n, 10), -1, 1);
					_valueTf.text = n.toString();
					setValue(0-n, "tf", false);
				}
			}
			//trace("n:"+n);
		}
		
		private function handleTextFocus(e:FocusEvent):void {
			var n:Number = parseFloat( _valueTf.text );
			n = MathUtil.normalize( MathUtil.roundToDecimal(n, 10), -1, 1);
			if ( isNaN(n) ) {
				n = 0;
			}
			_valueTf.text = n.toString();
			setValue(0-n, "tf");
		}
		
		private function onSliderComplete(e:Event):void {
			setValue( getValue(), "slider");	
		}
		
		private function onSliderChange(e:Event):void {
			setValue( getValue(), "slider");
		}
		
		private function setValue(value:Number, source:String, setInController:Boolean = true):void {
			_value = value;
			switch (source) {
				case 'slider':
					_valueTf.text = _value.toString();
					break;
				case 'tf':
					_slider.setValue( value, false );
					break;
				case 'both':
					_valueTf.text = _value.toString();
					_slider.setValue( 0-value, false );
					break;
			}
			if ( setInController ) {
				_controller.lineValue = getLVD( value );
			}
		}
		
		private function getLVD( value:Number ):LineValueData {
			var lvd:LineValueData = CMapUtils.getLineValueDataByValue( value );// LineValueData.getLineValueData(value.toString(), value, label, 15, color, -1, -1);
			return lvd;
		}
		
		private function getValue():Number {
			var value:Number = _slider.value;
			//trace("getValue, value:"+value);
			//trace(" value:"+value);
			value = MathUtil.normalize( MathUtil.roundToDecimal(value, 2), -1, 1);
			//trace(" value:"+value);
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