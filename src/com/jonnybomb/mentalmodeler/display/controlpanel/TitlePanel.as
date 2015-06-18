package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.display.controls.TextScrollPanel;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.LineValueData;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.GradientColorData;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	import com.mincomps.data.MinCompsScrollBarConstants;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.text.TextLineMetrics;
	
	public class TitlePanel extends AbstractPanel
	{
		private static const TYPE_NULL:int = 0;
		private static const TYPE_CD:int = 1;
		private static const TYPE_LINE:int = 2;
		private static const MAX_HEIGHT:int = 80;
		
		private var _tfPadding:int = 8;
		private var _stripe:Shape;
		private var _curNotable:INotable;
		private var _textScrollPanel:TextScrollPanel;
		
		public function TitlePanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			super(controlPanel, title, w, h);
			_maxHeight = 100;
			_minHeight = 10;
		}
		
		override public function get height():Number
		{
			return _header.height;
			/*	
			if (!_tf.visible)
				return _header.height	
			return super.height;
			*/
		}
			
		override public function setSize(w:Number, h:Number):void
		{
			_sizeChanged = (w != _width && w != -1) || (h != _height && h != -1);
			
			if (w > -1)
				_width = w;
			if (h > -1)
				_height = normalizeHeight(h);
			
			_header.height = _height;
			_header.width= _width;
			
			if (_sizeChanged)
				_textScrollPanel.setSize(_width - TextScrollPanel.TF_PADDING, _header.height - TF_PADDING*2);
		}
		
		override public function init():void
		{
			//super.init();
			
			var cdOver:ColorData = ColorData.getColor(ColorData.BUTTON_OVER, true);
			var color:uint = GradientColorData(cdOver.fill).colors[0];
			
			_header = addChild(new Sprite()) as Sprite;
			var g:Graphics = _header.graphics;
			g.beginFill(color);//0x595959);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
			
			// create tf for text scroll panel
			var props:Object = {color: 0xFFFFFF,
				size: 14,
				align: TextFormatAlign.LEFT,
				autoSize: TextFieldAutoSize.LEFT,
				letterSpacing:-1,
				multiline: true,
				wordWrap: true,
				width:_width - _tfPadding*2,
				html:true
			};
			
			var tf:TextField = CMapUtils.createTextField("", props);
			//_tf = addChild(CMapUtils.createTextField("", props)) as TextField;
			//_tf.x = _tf.y = _tfPadding;
			
			_textScrollPanel = addChild(new TextScrollPanel(tf, _width - TextScrollPanel.TF_PADDING, _header.height/*_height- HEADER_HEIGHT*/, "Title display")) as TextScrollPanel;
			_textScrollPanel.x = _textScrollPanel.y = TextScrollPanel.TF_PADDING;
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CD_CHANGE, handleSelectedCDChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_LINE_CHANGE, handleSelectedLineChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.ELEMENT_TITLE_CHANGE, handleElementTitleChange, false, 0, true);
			_controlPanel.controller.model.addEventListener(ModelEvent.LINE_VALUE_CHANGE, handleLineValueChange, false, 0, true);
			
			update(TYPE_NULL, false);
			
			if (_minHeight > -1)
				setSize(-1,_minHeight);
		}
			
		private function getTitle(type:int):String
		{
			var s:String = "";
			if (type == TYPE_LINE) // Line
			{
				var line:InfluenceLineDisplay = _curNotable as InfluenceLineDisplay; 
				var nameER:String = (line.influencer.title != "" ) ? line.influencer.title : "[Component]";
				var influence:String;
				if (line.influenceValue == 0 || line.influenceValue == LineValueData.UNDEFINED_VALUE)
					influence = "To"
				else
					influence = (line.influenceValue > 0 ? "INCREASES" : "DECREASES") + " ("+line.influenceLabel+")";
				var nameEE:String = (line.influencee.title != "") ? line.influencee.title : "[Component]";
				s = nameER + "<br/><b>" + influence + "</b><br/>" + nameEE;
			}
			else if (type == TYPE_CD) // CD
				s = "<b>"+ (_curNotable.title != "" ? _curNotable.title : "[Component]") +"</b>";
			
			return s;
		}
		
		private function update(type:int, updateLayout:Boolean = true, fromTextChange:Boolean = false):void
		{
			//trace("TitlePanel >> update, _curNotable:"+_curNotable)
			if (_curNotable)
			{
				var s:String = getTitle(type)
				_textScrollPanel.visible = true;
				_textScrollPanel.tf.htmlText = s;
				setSize(-1, Math.ceil(_textScrollPanel.tf.height) + _tfPadding*2);
				//setSize(-1, Math.ceil(_tf.height) + _tfPadding*2);
			}
			else
			{
				_textScrollPanel.visible = false;
				setSize(-1, _minHeight);
			}	
			
			//trace("Title Panel >> update, text:"+_textScrollPanel.tf.text+", _textScrollPanel.tf.height:"+_textScrollPanel.tf.height+", updateLayout:"+updateLayout); 
			
			if (updateLayout)
				_controlPanel.updateLayout();
		}
		
		private function handleElementTitleChange(e:ModelEvent):void
		{
			//trace("handleElementTitleChange");
			var line:InfluenceLineDisplay = getCurLine();
			if (_curNotable)
			{
				if (_curNotable is InfluenceLineDisplay)
					update(TYPE_LINE);
				else
					update(TYPE_CD);
				_textScrollPanel.updateTextFromChange();
			}
		}
		
		private function handleLineValueChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			if (line)
			{
				_curNotable = line;
				update(TYPE_LINE);
				_textScrollPanel.updateTextFromChange();
			}
		}
		
		private function handleSelectedLineChange(e:ModelEvent):void
		{
			var line:InfluenceLineDisplay = getCurLine();
			var cd:ConceptDisplay = getCurCd();
			//trace("TitlePanel >> handleSelectedLineChange, line:"+line+", cd:"+cd);
			if (line)
			{
				_curNotable = line;
				update(TYPE_LINE);
				_textScrollPanel.updateTextFromChange(true);
			}
			else {
				_curNotable = null;
				update(TYPE_LINE);
			}
			
			/*
			else if (!getCurCd())
			{
				_curNotable = null;
				update(TYPE_LINE);
				_textScrollPanel.updateTextFromChange(true);
			}
			*/
		}
		
		private function handleSelectedCDChange(e:ModelEvent):void
		{
			var cd:ConceptDisplay = getCurCd();
			if (cd)
			{
				_curNotable = cd;
				update(TYPE_CD);
				_textScrollPanel.updateTextFromChange(true);
			}
			else if (!getCurLine())
			{
				_curNotable = null;
				update(TYPE_CD);
				_textScrollPanel.updateTextFromChange(true);
			}
		}
		
		private function getCurCd():ConceptDisplay { return _controlPanel.controller.model.curCd; }
		private function getCurLine():InfluenceLineDisplay { return _controlPanel.controller.model.curLine; }
	}
}