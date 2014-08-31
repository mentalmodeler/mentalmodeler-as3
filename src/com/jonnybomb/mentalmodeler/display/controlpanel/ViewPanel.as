package com.jonnybomb.mentalmodeler.display.controlpanel
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.INotable;
	import com.jonnybomb.mentalmodeler.display.InfluenceLineDisplay;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.utils.CMapUtils;
	import com.jonnybomb.mentalmodeler.utils.visual.DrawingUtil;
	import com.jonnybomb.ui.components.UIButton;
	import com.jonnybomb.ui.components.radiobutton.RadioButton;
	import com.jonnybomb.ui.components.radiobutton.RadioButtonData;
	import com.jonnybomb.ui.components.radiobutton.RadioButtonGroup;
	
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	public class ViewPanel extends AbstractPanel
	{
		public static const VIEW_LINES_NONE:int = 0;
		public static const VIEW_LINES_FROM:int = 1;
		public static const VIEW_LINES_TO:int = 2;
		
		private static var colors:Object = { up: ColorData.getColor(ColorData.CHECKBOX_UP),
											 over: ColorData.getColor(ColorData.CHECKBOX_OVER)
										   };
		
		private static const BG_COLOR:uint = 0x727272;
		
		private var _viewLinesTo:UIButton;
		private var _viewLinesFrom:UIButton;
		private var _viewReset:UIButton;
		private var _cdReset:UIButton;
		private var _cdViewMode:MovieClip;
		private var _linesViewMode:MovieClip;
		private var _resetWidth:int = 0;
		
		private var _radioGroup:RadioButtonGroup;
		private var radioButtons:Vector.<RadioButton> = new Vector.<RadioButton>();
		
		public function ViewPanel(controlPanel:ControlPanelDisplay, title:String, w:int, h:int)
		{
			super(controlPanel, title, w, h);
			_resetWidth = Math.round(w * 0.6);
		}
		
		override public function get height():Number { return _cover.height; }
		
		override public function init():void
		{
			super.init();
			removeChild(_body);
			

			_cdViewMode = addChild(new MovieClip()) as MovieClip;
			_cdViewMode.y = HEADER_HEIGHT;
			_cdViewMode.bg = _cdViewMode.addChild(createBg(new Rectangle(0, 0, _width, HEADER_HEIGHT), BG_COLOR)) as Sprite;
			// add radio buttons
			var padding:int = 10;
			var totalWidth:int = _width - padding*2;
			var items:Vector.<RadioButtonData> = new <RadioButtonData>
				[
					//RadioButtonData(value:Object = null, label:String = "", selected:Boolean = false, contentRendererData:Object = null)
					//new RadioButtonData(VIEW_LINES_NONE, "All", true, {}),
					new RadioButtonData(VIEW_LINES_FROM, "View Only Lines From", false, {}),
					new RadioButtonData(VIEW_LINES_TO, "View Only Lines To", false, {})
				]
			var format:Object = {};
			format[RadioButtonGroup.SPACING_VERT] = 8;
			format[RadioButtonGroup.DOT_SPACING_HORZ] = 3;
			format[RadioButtonGroup.TOTAL_WIDTH] = totalWidth;
			_radioGroup = _cdViewMode.addChild(new RadioButtonGroup(items, null, format)) as RadioButtonGroup;
			_radioGroup.x = padding;
			_radioGroup.y = padding; 
			_radioGroup.addEventListener(Event.CHANGE, handleRadioButtonChange, false, 0, true);
			// add radio buttons reset button
			_cdReset = _radioGroup.addChild(createButton("Reset", false)) as UIButton;
			_cdReset.x = (totalWidth - _cdReset.width) / 2;
			_cdReset.y = Math.round(_radioGroup.height + format[RadioButtonGroup.SPACING_VERT]);
			_radioGroup.resetButton = _cdReset;
			_cdViewMode.bg.height = _radioGroup.y + _radioGroup.height + padding;
			
			_linesViewMode = addChild(new MovieClip()) as MovieClip;
			_linesViewMode.y = HEADER_HEIGHT;
			_linesViewMode.bg = _linesViewMode.addChild(createBg(new Rectangle(0, 0, _width, HEADER_HEIGHT), BG_COLOR)) as Sprite;
			
			_viewReset = _linesViewMode.addChild(createButton("Reset", false)) as UIButton;
			_viewReset.x = (_width - _viewReset.width) / 2;
			_viewReset.y = padding;
			_viewReset.addEventListener(MouseEvent.MOUSE_DOWN, handleResetDown, false, 0 ,true);
			
			_linesViewMode.bg.height = _viewReset.y + _viewReset.height + padding;
			
			update(false);
			enabled = false;
			
			_controlPanel.controller.model.addEventListener(ModelEvent.SELECTED_CHANGE, handleSelectedChange, false, 0, true);
		}
		
		private function update(updatePanels:Boolean = true):void
		{
			var curCd:ConceptDisplay = _controlPanel.controller.model.curCd;
			var curLine:InfluenceLineDisplay = _controlPanel.controller.model.curLine;
			var curSelected:INotable = _controlPanel.controller.model.curSelected;
			
			if (curSelected is ConceptDisplay)
			{
				_cdViewMode.visible = true;
				_linesViewMode.visible = false;
				_cover.height = _cdViewMode.y + _cdViewMode.height;
				enabled = true;
			}
			else if (selectedView != VIEW_LINES_NONE) 
			{
				_cdViewMode.visible = false;
				_linesViewMode.visible = true;
				_cover.height = _linesViewMode.y + _linesViewMode.height
				enabled = true;
			}
			else
			{
				_cdViewMode.visible = false; 
				_linesViewMode.visible = false;
				_cover.height = HEADER_HEIGHT;
				enabled = false;
			}
		
			if (updatePanels)
				_controlPanel.updateLayout();
		}
		
		public function get selectedView():int
		{
			var view:int = VIEW_LINES_NONE;
			if (_radioGroup && _radioGroup.selectedValue)
				view = int(_radioGroup.selectedValue);
			return view;
		}
		
		public function set selectedView(view:int):void
		{
			if (_radioGroup)
				_radioGroup.selectItemByValue(view);
		}
		
		private function handleSelectedChange(e:ModelEvent):void
		{
			var curCd:ConceptDisplay = _controlPanel.controller.model.curCd;
			var curLine:InfluenceLineDisplay = _controlPanel.controller.model.curLine;
			var curSelected:INotable = _controlPanel.controller.model.curSelected;
			if (curSelected is ConceptDisplay)
			{
				enabled = true;
				if (selectedView != VIEW_LINES_NONE)
					_controlPanel.controller.setComponentSoloView(selectedView); //, true);
			}
			else if (selectedView != VIEW_LINES_NONE)
				enabled = true;
			else if (curSelected is InfluenceLineDisplay && curCd)
			{
				if ( (selectedView != VIEW_LINES_TO && curLine.influencee == curCd) || (selectedView != VIEW_LINES_FROM && curLine.influencer == curCd) )
					enabled = true;
				else
					enabled = false;
			}
			else
				enabled = false;
			
			update();
		}
		
		private function handleResetDown(e:MouseEvent):void
		{
			enabled = false;
			_viewReset.enabled = false;
			_radioGroup.selectItem(null);
			update();
		}
		
		private function handleRadioButtonChange(e:Event):void
		{
			switch (selectedView)
			{
				case VIEW_LINES_NONE:
					_controlPanel.controller.setComponentSoloView(VIEW_LINES_NONE); //, true);
					_viewReset.enabled = false;
					break
				case VIEW_LINES_FROM:
					_controlPanel.controller.setComponentSoloView(VIEW_LINES_FROM); //, true);
					_viewReset.enabled = true;
					break;
				case VIEW_LINES_TO:
					_controlPanel.controller.setComponentSoloView(VIEW_LINES_TO); //, true);
					_viewReset.enabled = true;
					break;
			}
		}
		
		private function createButton(s:String, toggleButton:Boolean = true):UIButton
		{
			props = {color: 0xFFFFFF,
				size: 13,
				bold:false,
				align: TextFormatAlign.CENTER,
				letterSpacing: -0.5,
				multiline:true,
				wordWrap:true,
				autoSize:TextFieldAutoSize.CENTER,
				width:_resetWidth
			};
			var tf:TextField = CMapUtils.createTextField(s, props);
			tf.filters = [CMapConstants.INSET_BEVEL];
			var hPadding:int = 7;
			var vPadding:int = 3;
			var props:Object = {};
			props[UIButton.STATE_COLORS] = colors;
			props[UIButton.WIDTH] = _resetWidth; //tf.width + hPadding*2;
			props[UIButton.DISABLED_ALPHA] = 0.4;
			props[UIButton.HEIGHT] = tf.height + vPadding*2;
			props[UIButton.ELLIPSE] = CMapConstants.BUTTON_ELLIPSE;
			
			props[UIButton.MOUSE_DOWN_DISTANCE] = 4;
			
			// toggle button configs
			props[UIButton.HAS_TOGGLE_GRAPHIC] = toggleButton;
			props[UIButton.HAS_SELECTED_STATE] = toggleButton;
			props[UIButton.USE_DROP_SHADOW] = !toggleButton;
			
			
			var b:UIButton = new UIButton(props);
			tf.x = (b.width - tf.width) / 2;
			tf.y = (b.height - tf.height) / 2 - props[UIButton.MOUSE_DOWN_DISTANCE];
			b.addLabel(tf);
			
			return b;
		}
	}
}