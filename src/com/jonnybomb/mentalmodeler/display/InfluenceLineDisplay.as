package com.jonnybomb.mentalmodeler.display
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.controls.LineValue;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.events.ControllerEvent;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.math.MathUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class InfluenceLineDisplay extends Sprite implements INotable
	{
		private static const VERTICAL:int = 0;
		private static const HORIZONTAL:int = 1;
		
		private var _controller:CMapController;
		private var _influencer:ConceptDisplay;
		private var _influencee:ConceptDisplay;
		private var _lineValue:LineValue;
		
		private var _arrow:Sprite;
		
		private var _erCenter:Point;
		private var _eeCenter:Point;
		private var _erEdge:Point;
		private var _eeEdge:Point;
		
		private var _comboPct:Number = 0.5;
		
		private var _hasInfluencerOffset:Boolean = false;
		private var _hasInfluenceeOffset:Boolean = false;
		private var _lineValueMoved:Boolean = false;
		private var _isDown:Boolean = false;
		private var _isInDualRelationship:Boolean = false;
		private var _isFirstLineInDualRelationship:Boolean = false;
		
		private var _notes:String = "";
		public function get notes():String { return _notes; }
		public function set notes(value:String):void { _notes = value; }
		
		private var _units:String = ""
		public function get units():String { return _units; }
		public function set units(value:String):void { _units = value; }
		
		private var _confidence:Number = 0;
		public function get confidence():Number { return _confidence; }
		public function set confidence(value:Number):void { _confidence = value; }
		
		override public function get name():String { return "line -> "+_influencer.name+" influencing "+_influencee.name; }
		
		public function get title():String { return name; }
		public function get influenceLabel():String { return _lineValue.value.label }
		public function get influenceValue():Number { return _lineValue.value.value; }
		public function get influencer():ConceptDisplay { return _influencer; }
		public function get influencee():ConceptDisplay { return _influencee; }
		public function get hasInfluencerOffset():Boolean { return _hasInfluencerOffset; }
		public function get hasInfluenceeOffset():Boolean { return _hasInfluenceeOffset; }
		public function connectsTo(cd:ConceptDisplay):Boolean { return _influencee == cd || _influencer == cd;	}
		
		private var _enabled:Boolean = true; 
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			alpha = value ? 1: CMapConstants.DISABLED_ALPHA;
			mouseEnabled = value;
			mouseChildren = value;
			buttonMode = value;
		}
		
		public function InfluenceLineDisplay(controller:CMapController, influencer:ConceptDisplay, influencee:ConceptDisplay, startValue:LineValueData)
		{
			_controller = controller;
			_influencer = influencer;
			_influencee = influencee;
			
			_erCenter = new Point();
			_eeCenter = new Point();
			
			init(startValue);
		}
		
		public function setDualRelationship(isInDualRelationship:Boolean, isFirstLineinDualRelationship:Boolean = false):void
		{
			_isInDualRelationship = isInDualRelationship;
			_isFirstLineInDualRelationship = isFirstLineinDualRelationship;
		}
		
		public function get value():LineValueData { return _lineValue.value; }
		public function set value(lvd:LineValueData):void
		{ 
			_lineValue.value = lvd;
			draw();
		}
		
		
		public function draw():void
		{
			_eeCenter.x = _influencee.x + _influencee.width/2 + getOffset();
			_eeCenter.y = _influencee.y + _influencee.height/2;
			_erCenter.x = _influencer.x + _influencer.width/2 + getOffset();
			_erCenter.y = _influencer.y + _influencer.height/2;
			
			var pct:Number;
			
			// rotate the arrow head
			var deltaX:Number = _eeCenter.x - _erCenter.x;
			var deltaY:Number = _eeCenter.y - _erCenter.y;
			var radians:Number = Math.atan2(deltaY, deltaX);
			_arrow.rotation =  radians * 180 / Math.PI;
			
			// determine the eeEdge point
			var dist:Number = Point.distance(_eeCenter, _erCenter);
			var eeRadians:Number = Math.atan2(_erCenter.x - _eeCenter.x, _erCenter.y - _eeCenter.y);
			var w:int = _influencee.width/2 + ((_erCenter.x > _eeCenter.x) ? -getOffset() : getOffset());
			var h:int = _influencee.height/2;
			var cos:Number = Math.cos(eeRadians);
			var hypo:Number = Math.abs(h / cos);
			var opposite:Number = Math.sqrt(Math.pow(hypo, 2) - Math.pow(h, 2));
			var adj:int = 0;
			if (opposite < w)
				pct = (dist - hypo + adj) / dist;
			else
			{
				var sin:Number = Math.sin(eeRadians);
				hypo = Math.abs(w / sin);
				pct = (dist - hypo + adj) / dist;
			}
			_eeEdge = Point.interpolate(_eeCenter, _erCenter, pct);
			
			// determine the erEdge point
			dist = Point.distance(_erCenter, _eeCenter);
			var erRadians:Number = Math.atan2(_eeCenter.x - _erCenter.x, _eeCenter.y - _erCenter.y);
			w = _influencer.width/2 + ((_eeCenter.x > _erCenter.x) ? -getOffset() : getOffset());
			h = _influencer.height/2;
			cos = Math.cos(erRadians);
			hypo = Math.abs(h / cos);
			opposite = Math.sqrt(Math.pow(hypo, 2) - Math.pow(h, 2));
			adj = 0;
			if (opposite < w)
				pct = (dist - hypo + adj) / dist;
			else
			{
				sin = Math.sin(erRadians);
				hypo = Math.abs(w / sin);
				pct = (dist - hypo + adj) / dist;
			}
			_erEdge = Point.interpolate(_erCenter, _eeCenter, pct);
			
			// place the arrow head
			_arrow.x = _eeEdge.x;
			_arrow.y = _eeEdge.y;
			
			var color:uint = _lineValue.value.color;
			if (_controller.model.curSelected == this)
			{
				var cdOver:ColorData = ColorData.getColor(ColorData.BUTTON_OVER, true);
				color = GradientColorData(cdOver.fill).colors[0];
			}
			var value:Number = Math.abs(LineValueData(_lineValue.value).value);
			var lines:int = value == 1 ? 4 : value == 0.62 ? 2 : 1;
			graphics.clear();
			
			//draw the line hit area
			graphics.lineStyle(CMapConstants.INFLUENCE_LINE_THICKNESS + 14, 0xff0000, 0);
			graphics.moveTo(_erEdge.x, _erEdge.y);
			graphics.lineTo(_eeEdge.x, _eeEdge.y);
			
			// draw the outer part
			graphics.lineStyle(lines*3, color, 0.3); // CMapConstants.INFLUENCE_LINE_THICKNESS
			graphics.moveTo(_erEdge.x, _erEdge.y);
			graphics.lineTo(_eeEdge.x, _eeEdge.y);
			
			// draw the line
			graphics.lineStyle(lines, color, 0.9);
			graphics.moveTo(_erEdge.x, _erEdge.y);
			graphics.lineTo(_eeEdge.x, _eeEdge.y);
			
			drawArrowHead(color);
			
			// place the line value combo
			positionLineValue();
		}
		
		public function getLineValueGlobalPos(lineValue:LineValue):Point
		{
			if (!lineValue)
				lineValue = _lineValue;
			
			//if (!lineValue) return;
			return localToGlobal(new Point(lineValue.x, lineValue.y));
		}
		
		private function getOffset():int
		{
			var offset:int = 0;
			if (_isInDualRelationship)
				offset = _isFirstLineInDualRelationship ? CMapConstants.LINE_VALUE_INDICATOR_WIDTH/2 : -CMapConstants.LINE_VALUE_INDICATOR_WIDTH/2;
			return offset;
		}
		
		private function drawArrowHead(color:uint):void
		{
			var g:Graphics = _arrow.graphics;
			var h:int = CMapConstants.ARROWHEAD_HEIGHT;
			var w:int = CMapConstants.ARROWHEAD_WIDTH;
			g.clear();
			g.beginFill(color);
			g.lineTo(-h, -w/2);
			g.lineTo(-h, w/2);
			g.lineTo(0, 0);
			g.endFill();
		}
		
		private function init(startValue:LineValueData):void
		{
			//_controlPanel.controller.model.addEventListener(ModelEvent.LINE_VALUE_CHANGE, handleLineValueChange, false, 0, true);
			//CMapController.log("InflunecyLineDisplay >> init\n\tstartValue:"+startValue);
			
			// draw arrow head
			_arrow = addChild(new Sprite()) as Sprite;
			drawArrowHead(startValue.color);
			
			// add line value combo
			_lineValue = addChild(new LineValue(startValue)) as LineValue;
			_lineValue.addEventListener(MouseEvent.MOUSE_DOWN, handleComboMouseDown, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, handleLineMouseDown, false, 0 , true);
			
			_controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
			//_controller.model.addEventListener(ModelEvent.SELECTED_LINE_CHANGE, handleSelectedChange, false, 0, true);
			//_controller.model.addEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedChange, false, 0, true);
			
			enabled = true;
			
			// TODO - show line value menu if this was created by a user click
			//_controller.showLineValueMenu(globalPoint.x, globalPoint.y, options.indexOf(_lineValue.value), this);
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			draw();
		}
		
		private function handleLineMouseDown(e:MouseEvent):void
		{
			//_controller.model.curLine = this;
			_controller.setAsCurrentLine(this);
		}	 
		
		private function handleComboMouseDown(e:MouseEvent):void
		{
			if (_isDown)
				return;
				
			_isDown = true;
			
			if (stage)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handleComboMouseMove, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, handleComboMouseUp, false, 0, true);
			}
		}
		
		private function handleComboMouseMove(e:MouseEvent):void
		{
			if (!_isDown)
				return;
				
			_lineValueMoved = true;
			positionLineValue(true);
		}
		
		private function handleComboMouseUp(e:MouseEvent):void
		{
			if (_isDown)
			{
				_isDown = false;			
				if (stage)
				{
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleComboMouseMove);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleComboMouseUp);
				}
				if (!_lineValueMoved)
				{
					if (e.target is UIButton && DisplayObject(e.target).parent is LineValue)
					{	
						var lineV:LineValue = DisplayObject(e.target).parent as LineValue;
						if (!lineV)
							return;
						
						var options:Vector.<LineValueData> = CMapConstants.LINE_VALUES;
						if (options.length == 0)
						{
							// assuming only option is remove
							_controller.doRemoveLine(this);
						}
						else
						{
							// show the line values combo
							var globalPoint:Point = getLineValueGlobalPos(lineV);
							_controller.showLineValueMenu(globalPoint.x, globalPoint.y, options.indexOf(_lineValue.value), this);
						}
					}
				}
				_lineValueMoved = false;
			}
		}			
		
		private function getLineValueDragOrientation():int
		{
			var angle:Number = _arrow.rotation;
			if ((angle >= -45 && angle <= 45) || angle <= -135 || angle >= 135) // horz
				return HORIZONTAL;
			else // vert
				return VERTICAL;
		}
		
		private function positionLineValue(bDrag:Boolean = false):void
		{
			var angle:Number = _arrow.rotation;
			var side:int = CMapConstants.LINE_CLOSE_SIDE;
			
			var padding:int = 20;
			var dist:Number = Point.distance(_eeEdge, _erEdge);
			var pct:Number = padding/dist;
			
			var fromPoint:Point = Point.interpolate(_erEdge, _eeEdge, 1 - pct); //_erEdge;
			var toPoint:Point = Point.interpolate(_erEdge, _eeEdge, pct); //_eeEdge;
			
			if (bDrag)
			{
				if (getLineValueDragOrientation() == HORIZONTAL) // horz
				{
					var mX:Number = MathUtil.normalize(mouseX, MathUtil.min(toPoint.x, fromPoint.x), MathUtil.max(toPoint.x, fromPoint.x));
					dist = Math.abs(fromPoint.x - toPoint.x);
					_comboPct = Math.abs((mX - toPoint.x) / dist); 
				}
				else // vert
				{
					var mY:Number = MathUtil.normalize(mouseY, MathUtil.min(toPoint.y, fromPoint.y), MathUtil.max(toPoint.y, fromPoint.y));
					dist = Math.abs(fromPoint.y - toPoint.y);
					_comboPct = Math.abs((mY - toPoint.y) / dist); 
				}
			}
			else
				dist = Point.distance(toPoint, fromPoint);
			
			var p:Point = Point.interpolate(fromPoint, toPoint, _comboPct);
			if ( isNaN(p.x) )
				p.x = _erEdge.x;
			if ( isNaN(p.y) )
				p.y = _erEdge.y;
			_lineValue.x = p.x;
			_lineValue.y = p.y;
		}
		
		public function finalize():void
		{
			if (stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleComboMouseMove, false);
				stage.removeEventListener(MouseEvent.MOUSE_UP, handleComboMouseUp, false);
			}
			
			if (_lineValue)
				_lineValue.removeEventListener(MouseEvent.MOUSE_DOWN, handleComboMouseDown, false);
			
			removeEventListener(MouseEvent.MOUSE_DOWN, handleLineMouseDown, false);
			_controller.model.removeEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false);
			//_controller.model.removeEventListener(ModelEvent.SELECTED_LINE_CHANGE, handleSelectedChange, false);
			//_controller.model.removeEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedChange, false);
			
			DisplayObjectUtil.finalizeAndRemove(_lineValue);
			DisplayObjectUtil.remove(_arrow);
			
			_controller = null;
			_influencer = null;
			_influencee = null;
			_lineValue = null;
			_arrow = null;
			_erCenter = null;
			_eeCenter = null;
			_eeEdge = null;
			_erEdge = null;
		}
	}
}