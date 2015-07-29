package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.math.MathUtil;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	public class AbstractPanel extends Sprite
	{
		protected static const HEADER_HEIGHT:int = 26;
		protected static const TF_PADDING:int = 5;
		protected static const HEADER_CD:ColorData = new ColorData(null, new ColorExtended(0x4a4a4a));
		protected static const COVER_CD:ColorData = new ColorData(null, new ColorExtended(0xcccccc, 0.7));//0x4a4a4a, 0.7));
		protected static const BODY_CD:ColorData = new ColorData(null, new ColorExtended(0xF2F2F2));
		protected static const BODY_DS:DropShadowFilter = new DropShadowFilter(3, 90, 0x000000, 1, 4, 4, 0.45, BitmapFilterQuality.MEDIUM, true);
		
		private var _enabled:Boolean = true;
		private var _collapsed:Boolean = false;
		protected var _minHeight:Number = -1;
		protected var _maxHeight:Number = -1;
		protected var _controlPanel:ControlPanelDisplay;
		protected var _title:String;
		protected var _tf:TextField;
		protected var _header:Sprite;
		protected var _chevron:Sprite;
		protected var _body:Sprite;
		protected var _cover:Sprite;
		protected var _width:int;
		protected var _height:int;
		protected var _sizeChanged:Boolean = false;
		
		public function AbstractPanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			mouseEnabled = false;
			
			_controlPanel = controlPanel;
			_title = title;
			_width = w;
			_height = normalizeHeight(h);
			
			//init();
		}
		
		protected function normalizeHeight(value:Number):Number {
			if (_minHeight > -1 && value < _minHeight)
				value = _minHeight;
			else if (_maxHeight > -1 && value > _maxHeight)
				value = _maxHeight
			return value;
		}
		
		protected function outOfRange(value:Number):Boolean {
			var out:Boolean = false;
			if (_minHeight > -1 && value < _minHeight)
				out = true;
			else if (_maxHeight > -1 && value > _maxHeight)
				out = true;
			return out;
		}
		
		public function get collapsed():Boolean {
			return _collapsed;
		}
		
		override public function get height():Number {
			var h:Number = _collapsed ? _header.height : _body.height ;
			//trace(this+" get height, h:"+h+", _collapsed:"+_collapsed+", _body.height:"+_body.height);
			return h;
		}
		
		public function getHeight(_h:Number = 0):Number {
			var h:Number = _collapsed ? _header.height : _h > 0 ? _h : super.height;
			//trace(this+" getHeight, h:"+h+", _collapsed:"+_collapsed);
			return h;
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			visible = value;
			_enabled = value;
			mouseEnabled = value;
			mouseChildren = value;
			_cover.visible = !value;
			setChildIndex(_cover, numChildren - 1);
			//alpha = value ? 1 : 0.4;
		}
			
		public function setSize(w:Number, h:Number):void
		{ 
			_sizeChanged = (w != _width && w != -1) || (h != _height && h != -1);
			if (w > -1)
				_width = w;
			if (h > -1)
				_height = normalizeHeight(h);
			_body.height = _cover.height = _height;
			_body.width = _cover.width = _width;
		}
		
		private function onHeaderClick(e:MouseEvent):void {
			toggle();
			//trace("height:"+height+", _header.height:"+_header.height);
			_controlPanel.updateLayout();
		}
		
		private function toggle():void {
			if ( _collapsed ) {
				_chevron.rotation = 90;
				scrollRect = null;
			} else {
				_chevron.rotation = 0;
				scrollRect = new Rectangle(0, 0, width, _header.height);
			}
			//trace('BEFORE _collapsed:'+_collapsed);
			_collapsed = !_collapsed;
			//trace(this+' _collapsed:'+_collapsed);
			//trace('AFTER _collapsed:'+_collapsed);
			
		}
		
		public function init():void
		{
			_body = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_body, _width, HEADER_HEIGHT, BODY_CD);
			
			_cover = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_cover, _width, HEADER_HEIGHT, COVER_CD);
			
			// draw header
			_header = addChild(new Sprite()) as Sprite;
			DrawingUtil.drawRect(_header, _width, HEADER_HEIGHT, HEADER_CD);	
			_header.addEventListener(MouseEvent.CLICK, onHeaderClick, false, 0, true); 
			_header.buttonMode = true;
			
			var line:Shape = addChild(createHeaderLine(new Rectangle(0, 0, _width, 2))) as Shape;
			line = addChild(createHeaderLine(new Rectangle(0, 0, _width, 1))) as Shape;
			line.filters = [];
			line.y = HEADER_HEIGHT - 1;
			
			// draw chevron
			_chevron = addChild(new Sprite()) as Sprite;
			_chevron.mouseEnabled = false;
			var w:int = 8;
			var h:int = 9;
			var g:Graphics = _chevron.graphics;
			g.beginFill(0xffffff);
			g.moveTo( -w/2, -h/2 );
			g.lineTo( -w/2,  h/2 );
			g.lineTo( w/2, 0 );
			g.lineTo( -w/2, -h/2 );
			g.endFill();
			var adjX:int = 4;
			_chevron.y = (_header.height - _chevron.height)/2 + h/2;
			_chevron.x = Math.min(_chevron.y, Math.round(w/2) + adjX);
			_chevron.rotation = 90;
			
			// draw title
			var props:Object = {color: 0xFFFFFF,
								size: 13,
								align: TextFormatAlign.LEFT,
								letterSpacing: -1,
								bold: true,
								autoSize: TextFieldAutoSize.LEFT
								};
			_tf = addChild(CMapUtils.createTextField(_title, props)) as TextField;
			_tf.mouseEnabled = false;
			_tf.y = (_header.height - _tf.height)/2;
			_tf.x = _chevron.x + adjX;
		}
		
		protected function createBg(rect:Rectangle, color:uint = 0xF2F2F2):Sprite
		{
			var s:Sprite = new Sprite();
			var g:Graphics = s.graphics;
			g.beginFill(color, 0);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
			g.endFill();
			return s;
		}
		
		protected function createHeaderLine(rect:Rectangle, color:uint = 0x323232):Shape
		{
			var s:Shape = new Shape;
			var g:Graphics = s.graphics;
			g.beginFill(color);
			g.drawRect(rect.x, rect.y, rect.width, rect.height);
			g.endFill();
			s.filters = [ new BevelFilter(1, 270, 0xFFFFFF, 1, 0x000000, 1, 2, 2, 0.75, BitmapFilterQuality.MEDIUM, BitmapFilterType.INNER, true) ];
			return s;
		}
		
		protected function getCurCd():ConceptDisplay { return _controlPanel.controller.model.curCd; }
		protected function getCurLine():InfluenceLineDisplay { return _controlPanel.controller.model.curLine; }
		protected function getCurSelected():INotable { return _controlPanel.controller.model.curSelected; }
	}
}