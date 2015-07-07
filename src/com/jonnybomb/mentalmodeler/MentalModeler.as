package com.jonnybomb.mentalmodeler
{
	import adobe.utils.XMLUI;
	
	import com.jonnybomb.mentalmodeler.controller.CMapController;
	import com.jonnybomb.mentalmodeler.display.ConceptDisplay;
	import com.jonnybomb.mentalmodeler.display.ControlPanelDisplay;
	import com.jonnybomb.mentalmodeler.display.MenuDisplay;
	import com.jonnybomb.mentalmodeler.display.controls.ConceptsContainer;
	import com.jonnybomb.mentalmodeler.display.controls.UIButton;
	import com.jonnybomb.mentalmodeler.display.controls.alert.Alert;
	import com.jonnybomb.mentalmodeler.display.controls.alert.AlertContentDefault;
	import com.jonnybomb.mentalmodeler.model.data.ColorData;
	import com.jonnybomb.mentalmodeler.model.data.ColorExtended;
	import com.jonnybomb.mentalmodeler.utils.displayobject.DisplayObjectUtil;
	import com.jonnybomb.mentalmodeler.utils.xml.XMLUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	public class MentalModeler extends Sprite // implements IInteractiveObject, IInteractiveObjectV2
	{
		public static const IN_SUITE:Boolean = false;
		public static const FULL_SCREEN:Boolean = true;//true;
		public static const MMP:String = '<![CDATA[H+]]>';
		
		//private var _api:IInteractiveObjectAPI;
		private var _initCompleteCallback:Function;
		private var _container:ConceptsContainer;
		private var _controller:CMapController;
		private var _menu:MenuDisplay;
		private var _controlPanelDisplay:ControlPanelDisplay;
		private var _parentPBox:DisplayObject
		private var _standAlone:Boolean = false;
		private var _width:int = 0;
		private var _height:int = 0;
		
		private var _canSaveAndLoad:Boolean = true;
		
		public function MentalModeler()
		{
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			visible = false;
		}
		
		override public function get width():Number
		{
			return _controller.rect.width;
		}
		
		private function handleAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			_standAlone = parent == stage;
			if (_standAlone)
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				/*
				var xml:XML = <xml><settings width="700" height="500" maxNodes="5"><bg strokeWeight="1" strokeColor="0xFF0000" fillColor="" showInsetShadow="true"/></settings></xml>
				init(xml);
				*/
				init(null);
				
				if (MMP is String && MMP.length > 0 ) {
					_controller.loadXML('../mmp/fish_wetland2.mmp');
				}
			}
		}
		
		private function init(xml:XML):void
		{
			//trace("MentalModeler, init, xml:"+((xml != null ) ? xml.toXMLString() : "null"));
			_container = addChild(new ConceptsContainer(CMapConstants.NOTES_WIDTH, CMapConstants.MENU_HEIGHT)) as ConceptsContainer;
			
			_controller = new CMapController(_container, _standAlone);
			_controller.model.canSaveAndLoad = !IN_SUITE;
			_controller.model.hasScreenshotAndFullscreen = FULL_SCREEN;
			_container.controller = _controller;
			if (IN_SUITE) // || FULL_SCREEN)
				_controlPanelDisplay = addChildAt(new ControlPanelDisplay(_controller, 0, 0, CMapConstants.NOTES_WIDTH), 0) as ControlPanelDisplay;
			else
				_controlPanelDisplay = addChildAt(new ControlPanelDisplay(_controller, 0, CMapConstants.MENU_HEIGHT, CMapConstants.NOTES_WIDTH), 0) as ControlPanelDisplay;
			Alert.parent = this;
			
			if (_standAlone)
			{
				//var rect:Rectangle = new Rectangle(0, 0, 800, 600); 
				build(null);
			}
			
			// check for use in permissible context
			var permitted:Boolean = false;
			var whitelist:Array = ['/jonnybomb/mentalmodeler','http://localhost:8080/','http://www.mentalmodeler', 'http://mentalmodeler'];  
			var url:String = stage.loaderInfo.url;
			for (var i:int=0; i<whitelist.length; i++) {
				if (url.indexOf(whitelist[i]) > -1) {
					permitted = true;
					break;
				}
			}
			/*
			if (ExternalInterface.available) {
				ExternalInterface.call('console.log', 'url:',url,', permitted:',permitted);
			}
			trace('url:',url,', permitted:',permitted);
			*/
			
			if (!permitted) {
				Alert.show(new AlertContentDefault(CMapConstants.UNAPPROVED_CONTEXT), null);
			}
			/*
			if (xml && "settings" in xml)
			{
			var settings:XML = xml.settings[0];
			
			if (XMLUtil.isInt(settings, "@width"))
			_width = parseInt(settings.@width);
			
			if (XMLUtil.isInt(settings, "@height"))
			_height = parseInt(settings.@height);
			
			if (XMLUtil.isInt(settings, "@maxNodes"))
			_controller.maxNodes = parseInt(settings.@maxNodes);
			
			if ("addNodeLabel" in settings && XMLUtil.hasTextNodeWithContent(settings.addNodeLabel[0]))
			_controller.addNodeLabel =  settings.addNodeLabel[0].text()[0];
			
			if ("nodePrefillText" in settings && XMLUtil.hasTextNodeWithContent(settings.nodePrefillText[0]))
			_controller.nodePrefillText =  settings.nodePrefillText[0].text()[0]
			
			if ("bg" in settings)
			{
			var bg:XML = settings.bg[0];
			
			if (XMLUtil.isInt(bg, "@strokeWeight"))
			_controller.strokeWeight = parseInt(bg.@strokeWeight);
			
			if (XMLUtil.isInt(bg, "@strokeColor"))
			_controller.strokeColor = parseInt(bg.@strokeColor);
			
			if (XMLUtil.isInt(bg, "@fillColor"))
			_controller.fillColor = parseInt(bg.@fillColor);
			
			if (XMLUtil.isNotEmptyString(bg, "@showInsetShadow"))
			_controller.showInsetShadow = bg.@showInsetShadow.toString().toLowerCase() == "true";
			}
			}
			*/
			
			/*
			if (_initCompleteCallback != null)
			_initCompleteCallback();
			*/
		}
		
		public function build(rect:Rectangle):void
		{
			//trace("CMapMM, build, rect:"+((rect != null ) ? rect : "null"));
			
			if (rect)
			{
				if (_width > 0)
					rect.width = _width;
				if (_height > 0)
					rect.height = _height;
				_controller.rect = rect;
			}
			else if (_width > 0 && _height > 0)
			{
				rect = new Rectangle(0, 0, _width, _height);	
				_controller.rect = rect;
			}
			
			_menu = addChild(new MenuDisplay(_controller)) as MenuDisplay; //_container.menu.addChild(new MenuDisplay(_controller)) as MenuDisplay;
			
			_controller.updateAddNodeEnabled();
			visible = true;
			
			_controller.init();
			
			//if (_standAlone && stage && !rect)
			//_menu.handleResize(null);
			
			//if (!_showMenu)
			//_controller.loadMap();
			
			//_controller.addDebug();
			
			return;
			
			// debug
			var s:Sprite = addChild(new Sprite()) as Sprite;
			var g:Graphics = s.graphics;
			g.beginFill(0xFF0000);
			g.drawRoundRect(0, 0, 20, 20, 6, 6);
			g.endFill();
			s.addEventListener(MouseEvent.CLICK, handleTestClick, false, 0, true);
			s.x = s.y = 10;
		}
		
		private function handleTestClick(e:MouseEvent):void
		{
			//var xml:XML = 
			//var xml:XML = <app><node id="1" x="53.15" y="40" w="187" h="268"><![CDATA[aaa aa aaaaa aa aaaa a a aaaaaa aa a a aaaaaaaa a aa aaaaaaaaaa a a a aaaaaaa a a aaaaa a aaa]]></node><node id="2" x="310.15" y="354" w="347" h="99"><![CDATA[bbb bbb b bbbbbb b b b bbbbbb bb bbb b b b b bbbb b bbbb bb bbbbbb b bbb b b b bbbbbbb b bbbbb b bbbbb bbbbbb bbbbb bbbbb]]></node><node id="0" x="384.15" y="44" w="164" h="64"><![CDATA[ccc cc cccccccc ccc cc cc cccc ccc ccc c]]></node></app>;
			//var xml:XML = <app><node id="2" x="310.15" y="354" w="347" h="99"><![CDATA[bbb bbb b bbbbbb b b b bbbbbb bb bbb b b b b bbbb b bbbb bb bbbbbb b bbb b b b bbbbbbb b bbbbb b bbbbb bbbbbb bbbbb bbbbb]]></node></app>;
			//_controller.onMapLoaded(xml);
		}
		
		public function updateSize(rect:Rectangle):void
		{
			_controller.rect = rect;
			_menu.handleResize(null);
		}
		
		// ----------------------------- IInteractive Object API -----------------------------
		public function finalize():void
		{
			if (_controller)
				_controller.finalize();
			
			DisplayObjectUtil.finalizeAndRemove(_menu);
			
			_container = null;
			_parentPBox = null
			//_api = null;
			_initCompleteCallback = null;
			_container = null;
			_controller = null;
			_menu = null;
		}
		
		/*
		public function initializeObject(api:IInteractiveObjectAPI, xml:XML, initCompleteCallback:Function ):void
		{
		_api = api;
		_initCompleteCallback = initCompleteCallback;
		init(xml);
		}
		*/
		
		public function restoreState(xml:XML):void
		{
			_controller.onMapLoaded(xml);
		}
		
		public function getState():XML
		{ 
			return _controller.getState();
		}
	}
}