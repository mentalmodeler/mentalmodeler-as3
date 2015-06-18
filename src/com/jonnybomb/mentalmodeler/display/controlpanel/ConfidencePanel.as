package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.ui.components.Slider;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	public class ConfidencePanel extends AbstractPanel
	{
		private var _slider:Slider;
		private var _labelLeft:TextField;
		private var _labelRight:TextField;
		
		public function ConfidencePanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			super(controlPanel, title, w, h);
		}
		
		override public function init():void
		{
			super.init();
			
			var padding:int = 10;
			
			// create tf labels
			var props:Object = {color: 0x000000,
								size: 10,
								align: TextFormatAlign.LEFT,
								letterSpacing: 0,
								multiline: true,
								wordWrap: true,
								autoSize: TextFieldAutoSize.LEFT,
								type: TextFieldType.DYNAMIC,
								width: _width - padding*2,
								selectable: false,
								mouseEnabled: false
			};
			
			_labelLeft  = addChild(CMapUtils.createTextField("NOT", props)) as TextField;
			
			props.align = TextFormatAlign.RIGHT;
			_labelRight  = addChild(CMapUtils.createTextField("VERY", props)) as TextField;
			
			_labelLeft.x = _labelRight.x = padding;
			_labelLeft.y = _labelRight.y = _header.height + padding/2;
			
			var handle:Object = { up:ColorData.getColor(ColorData.BUTTON_UP),
								  over:ColorData.getColor(ColorData.BUTTON_OVER),
								  bevel:ColorData.getColor(ColorData.BUTTON_BEVEL)
			};
			_slider = addChild( new Slider(_width - padding*2, 25, Slider.NOTCHED, CMapConstants.CONFIDENCE_VALUES, {bg:new ColorData(null, new ColorExtended(0x888888)), bgColor:0x888888, ellipse:8, handle:handle}) ) as Slider;
			_slider.x = padding;
			_slider.y = _labelLeft.y + _labelLeft.height + padding/2;
			_slider.addEventListener(Event.CHANGE, handleSliderChange, false, 0, true);
			enabled = false;
			
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
			
			_minHeight = _maxHeight = _slider.y + _slider.height + padding;
			
			if (_minHeight > -1)
				setSize(-1, _minHeight);
		}
		
		private function handleSliderChange(e:Event):void
		{
			var curCd:ConceptDisplay = _controlPanel.controller.model.curCd;
			var curLine:InfluenceLineDisplay = _controlPanel.controller.model.curLine;
			var curSelected:INotable = _controlPanel.controller.model.curSelected;
			if (curSelected is InfluenceLineDisplay && curSelected == curLine)
				curLine.confidence = _slider.value;
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			var curCd:ConceptDisplay = _controlPanel.controller.model.curCd;
			var curLine:InfluenceLineDisplay = _controlPanel.controller.model.curLine;
			var curSelected:INotable = _controlPanel.controller.model.curSelected;
			//trace("ConfidencePanel >> handleSelectedChange, curCd:"+curCd+", curLine:"+curLine+", curSelected:"+curSelected);
			if (curSelected is InfluenceLineDisplay && curSelected == curLine)
			{
				enabled = true;
				_slider.setValue(curLine.confidence);
				setSize(-1, _minHeight);
			}
			else
				enabled = false;
			
			update();
		}
		
		private function update(updatePanels:Boolean = true):void
		{
			/*
			var curCd:ConceptDisplay = _controlPanel.controller.model.curCd;
			var curLine:InfluenceLineDisplay = _controlPanel.controller.model.curLine;
			var curSelected:INotable = _controlPanel.controller.model.curSelected;
			
			if (curSelected is ConceptDisplay)
			{
			_cdViewMode.visible = true;
			_linesViewMode.visible = false;
			_cover.height = _cdViewMode.y + _cdViewMode.height;
			}
			else if (_viewLinesTo.selected || _viewLinesFrom.selected) //curSelected is InfluenceLineDisplay)
			{
			_cdViewMode.visible = false;
			_linesViewMode.visible = true;
			_cover.height = _linesViewMode.y + _linesViewMode.height
			}
			else
			{
			_cdViewMode.visible = false; 
			_linesViewMode.visible = false;
			_cover.height = HEADER_HEIGHT;
			}
			*/
			
			if (updatePanels)
				_controlPanel.updateLayout();
		}
	}
}