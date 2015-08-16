package com.jonnybomb.mentalmodeler.display
{
	import com.jonnybomb.mentalmodeler.CMapConstants;
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.controlpanel.AbstractPanel;
	import com.jonnybomb.mentalmodeler.display.controlpanel.ConfidencePanel;
	import com.jonnybomb.mentalmodeler.display.controlpanel.GroupPanel;
	import com.jonnybomb.mentalmodeler.display.controlpanel.NotesPanel;
	import com.jonnybomb.mentalmodeler.display.controlpanel.TitlePanel;
	import com.jonnybomb.mentalmodeler.display.controlpanel.UnitsPanel;
	import com.jonnybomb.mentalmodeler.display.controlpanel.ViewPanel;
	import com.jonnybomb.mentalmodeler.events.ControllerEvent;
	import com.jonnybomb.mentalmodeler.events.ModelEvent;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	public class ControlPanelDisplay extends Sprite
	{
		private var _controller:CMapController
		private var _x:int;
		private var _y:int;
		private var _width:int;
		private var _height:int;
		private var holder:Sprite;
		private var _notesPanel:NotesPanel;
		private var _titlePanel:TitlePanel;
		private var _unitsPanel:UnitsPanel;
		private var _viewPanel:ViewPanel;
		private var _confidencePanel:ConfidencePanel;
		private var _groupPanel:GroupPanel;
		private var _panels:Vector.<AbstractPanel> = new Vector.<AbstractPanel>();
		
		public function get controller():CMapController { return _controller; }
		
		public function ControlPanelDisplay(controller:CMapController, x:int, y:int, w:int)
		{
			mouseEnabled = false;
			
			_controller = controller;
			_x = x;
			_y = y;
			_width = w;
			_height = _controller.stage.stageHeight - y;
			
			init();
		}
		
		private function init():void
		{
			//trace("ControlPanelDisplay >> init");
			x = _x;
			y = _y;
			
			var panels:Vector.<Object> = new <Object>[ { panelRef:"_titlePanel", classRef:TitlePanel, title:"TITLE" },
													   { panelRef:"_confidencePanel", classRef:ConfidencePanel, title:"CONFIDENCE RATING" },								   
													   { panelRef:"_notesPanel", classRef:NotesPanel, title:"NOTES" },				 
													   { panelRef:"_unitsPanel", classRef:UnitsPanel, title:"UNIT OF MEASUREMENT" },
													   { panelRef:"_groupPanel", classRef:GroupPanel, title:"GROUP" },
													   { panelRef:"_viewPanel", classRef:ViewPanel, title:"VIEW FILTER" }
			];
			
			for (var i:int = 0; i<panels.length; i++)
			{
				var o:Object = panels[i];
				this[o.panelRef] = addChild( new o.classRef(this, o.title, _width, _height) ) as o.classRef;
				_panels.push(this[o.panelRef]);
			}
			for each (var panel:AbstractPanel in _panels)
				panel.init();
				
			_controller.addEventListener(ControllerEvent.STAGE_RESIZE, handleStageResize, false, 0, true);
			handleStageResize(null);
		}
		
		public function updateLayout( fromPanel:AbstractPanel = undefined ):void
		{
			var panel:AbstractPanel;
			
			// determine panel heights
			var notesHeight:Number = _height;
			for each (panel in _panels)
				if (panel.enabled && panel != _notesPanel) notesHeight -= panel.height
			
			if ( !_notesPanel.collapsed )
				_notesPanel.setSize(_width, notesHeight);
			
			var nY:int = 0;
			for each (panel in _panels)
			{
				if (panel.enabled)
				{
					panel.y = nY;
					//trace("\tpanel:"+panel+", panel.enabled:"+panel.enabled+", panel.y:"+panel.y+", panel.height:"+panel.height);
					nY += panel.height;
				}
			}
		}
		
		private function handleStageResize(e:ControllerEvent):void
		{
			var stage:Stage = _controller.stage;
			_height = stage.stageHeight - y; 
			graphics.clear();
			graphics.beginFill(0xE6E6E6, 1);
			graphics.drawRect(0, 0, _width, _height);
			graphics.endFill();
			
			updateLayout();
		}
	}
}