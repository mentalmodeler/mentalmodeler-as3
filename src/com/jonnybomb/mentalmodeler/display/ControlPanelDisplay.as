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
		
		private function getPanelsHeight():Number {
			var h:Number = 0;
			for each (var panel:AbstractPanel in _panels) {
				if (panel.enabled && panel != _notesPanel) {
					h += panel.height;
				}
			}
			return h;
		}
		
		public function updateLayout( fromPanel:AbstractPanel = undefined, fromUserAction:Boolean = false ):void
		{	
			//var canCollapse:Array = [ _notesPanel, _titlePanel, _unitsPanel, _groupPanel, _viewPanel, _confidencePanel ];			
			var canCollapse:Array = [ _groupPanel, _viewPanel, _unitsPanel, _notesPanel  ];
			var i:int = 0; 
			var diff:Number = _height - ( getPanelsHeight() + _notesPanel.minHeight );
			//trace('diff:'+diff);
			while ( diff < 0 && i < canCollapse.length ) {
				var panel:AbstractPanel = canCollapse[ i ];
				//trace('  --panel:'+panel,', fromPanel:'+fromPanel+', fromUserAction:'+fromUserAction);
				if ( !panel.collapsed ) {
					if ( !(panel == fromPanel && fromUserAction) ) {
						panel.toggle();
						diff = _height - ( getPanelsHeight() + _notesPanel.minHeight );	
					}
					//trace('       diff:'+diff);
				}
				i++;
			}
			_notesPanel.setSize( -1, _notesPanel.minHeight + diff );		
			var nY:int = 0;
			for each (panel in _panels) {
				if (panel.enabled) {
					panel.y = nY;
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