package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.display.controls.TextScrollPanel;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.mincomps.data.MinCompsScrollBarConstants;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	public class UnitsPanel extends AbstractPanel
	{
		private var _textScrollPanel:TextScrollPanel;
		private var _curNotable:INotable;
		
		public function UnitsPanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			super(controlPanel, title, w, h);
			_minHeight = 80;
			_maxHeight = 80;
		}
		
		override public function get height():Number { return _height; }
		
		override public function setSize(w:Number, h:Number):void
		{
			//trace("UnitsPanel >> setSize, w:"+w+", h:"+h);
			_sizeChanged = (w != _width && w != -1) || (h != _height && h != -1);
			
			if (w > -1)
				_width = w;
			if (h > -1)
				_height = normalizeHeight(h);
			
			_body.height = _cover.height = _height;
			_body.width = _cover.width = _width;
			
			if (_sizeChanged)
				_textScrollPanel.setSize(_width - TextScrollPanel.TF_PADDING, _height - HEADER_HEIGHT);
		}
		
		override public function init():void
		{
			//trace("UnitsPanel >> init");
			super.init();
			
			// create tf for text scroll panel
			var props:Object = {color: 0x000000,
				size: 13,
				align: TextFormatAlign.LEFT,
					letterSpacing: 0,
					autoSize: TextFieldAutoSize.LEFT,
					multiline: true,
					mouseEnabled: true,
					wordWrap: true,
					type: TextFieldType.INPUT,
					width: _width - MinCompsScrollBarConstants.SIZE - TextScrollPanel.TF_PADDING,
					selectable: true
			};
			var tf:TextField = CMapUtils.createTextField("", props);
			// create text scroll panel
			_textScrollPanel = addChild(new TextScrollPanel(tf, _width - TextScrollPanel.TF_PADDING, _height - HEADER_HEIGHT, CMapConstants.UNITS_PREFILL_TEXT)) as TextScrollPanel;
			_textScrollPanel.x = TextScrollPanel.TF_PADDING
			_textScrollPanel.y = _header.height;
			_textScrollPanel.addEventListener(Event.CHANGE, handleTextScrollPanelChange, false, 0, true);
			enabled = false;
			
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
		}
		
		private function handleTextScrollPanelChange(e:Event):void
		{
			if (_curNotable)
				_curNotable.units = _textScrollPanel.tf.text
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			var curCd:ConceptDisplay = _controlPanel.controller.model.curCd;
			var curLine:InfluenceLineDisplay = _controlPanel.controller.model.curLine;
			var curSelected:INotable = _controlPanel.controller.model.curSelected;
			//trace("UnitsPanel >> handleSelectedChange, curCd:"+curCd+", curLine:"+curLine+", curSelected:"+curSelected);
			if (curSelected is ConceptDisplay)
			{
				enabled = true;
				_curNotable = curSelected;
				_textScrollPanel.tf.text = _curNotable.units == "" && CMapConstants.UNITS_PREFILL_TEXT != "" ? CMapConstants.UNITS_PREFILL_TEXT : _curNotable.units;
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
		
		private function getCurCd():ConceptDisplay { return _controlPanel.controller.model.curCd; }
		private function getCurLine():InfluenceLineDisplay { return _controlPanel.controller.model.curLine; }
	}
}