package com.jonnybomb.mentalmodeler.controller
{
	import com.adobe.images.PNGEncoder;
	
	import com.jonnybomb.mentalmodeler.display.controls.alert.Alert;
	import com.jonnybomb.mentalmodeler.display.controls.alert.AlertContentDefault;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import com.jonnybomb.mentalmodeler.model.CMapModel;
	import com.jonnybomb.mentalmodeler.CMapConstants;
	
	public class IOController extends EventDispatcher
	{
		private var _model:CMapModel;
		private var _controller:CMapController;
		private var _fileRef:FileReference;
		private var _filter:Array = [new FileFilter(CMapConstants.FILE_FILTER_NAME, "*" + CMapConstants.FILE_EXTENSION)];
		//private var _file:File;
		
		public function IOController(model:CMapModel, controller:CMapController)
		{
			XML.ignoreWhitespace = true;
			_model = model;
			_controller = controller;
		}
		
		////////////////
		// PNG Export //
		////////////////
		
		public function savePNG():void
		{
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.COMPLETE, handlePngSave, false, 0, true);
			_fileRef.addEventListener(Event.CANCEL,handlePngSaveCancel, false, 0, true);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, handlePngSaveError, false, 0, true);
			
			try
			{
				Alert.show(new AlertContentDefault(CMapConstants.MESSAGE_SCREENSHOT_SELECT), null);
				
				var w:int = Math.max(_controller.maxW, _controller.stage.stageWidth);
				var h:int = Math.max(_controller.maxH, _controller.stage.stageHeight);
				var bmd:BitmapData = new BitmapData(w, h, true, 0);
				var g:Graphics = _controller.container.graphics;
				g.beginFill(0xFFFFFF, 1);
				g.drawRect(0, 0, w, h);
				g.endFill();
				_controller.container
				bmd.draw(_controller.container);
				g.clear();
				var byteArray:ByteArray = PNGEncoder.encode(bmd);
				_fileRef.save(byteArray, ".png");
				
			}
			catch (e:IllegalOperationError)
			{
				removeSavePNGHandlers();
				_fileRef = null;
			}
			catch (e:SecurityError)
			{
				removeSavePNGHandlers();
				_fileRef = null;
			}
		}
		
		private function handlePngSave(e:Event):void
		{
			removeSavePNGHandlers();
			_fileRef = null;
		}
		
		private function handlePngSaveCancel(e:Event):void
		{
			removeSavePNGHandlers();
			_fileRef = null;
		}
		
		private function handlePngSaveError(e:IOErrorEvent):void
		{
			removeSavePNGHandlers();
			_fileRef = null;
		}
		
		private function removeSavePNGHandlers():void
		{
			Alert.close();
			
			if (!_fileRef)
				return;
			_fileRef.removeEventListener(Event.COMPLETE, handlePngSave, false);
			_fileRef.removeEventListener(Event.CANCEL,handlePngSaveCancel, false);
			_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, handlePngSaveError, false);
		}
		
		/////////////////////////
		// File Reference Save //
		/////////////////////////
		
		public function saveFileRef():void
		{
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.COMPLETE, handleFileRefSave, false, 0, true);
			_fileRef.addEventListener(Event.CANCEL,handleFileRefSaveCancel, false, 0, true);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleFileRefSaveError, false, 0, true);
			
			try
			{
				Alert.show(new AlertContentDefault(CMapConstants.MESSAGE_SAVE_SELECT), null);
				_fileRef.save(_model.stringToSave, CMapConstants.FILE_EXTENSION);
			}
			catch (e:IllegalOperationError)
			{
				removeFileRefSaveHandlers();
				_fileRef = null;
			}
			catch (e:SecurityError)
			{
				removeFileRefSaveHandlers();
				_fileRef = null;
			}
		}
		
		private function handleFileRefSave(e:Event):void
		{
			removeFileRefSaveHandlers();
			_fileRef = null;
		}
		
		private function handleFileRefSaveCancel(e:Event):void
		{
			removeFileRefSaveHandlers();
			_fileRef = null;
		}
		
		private function handleFileRefSaveError(e:IOErrorEvent):void
		{
			removeFileRefSaveHandlers();
			_fileRef = null;
		}
		
		private function removeFileRefSaveHandlers():void
		{
			Alert.close();
			
			if (!_fileRef)
				return;
			_fileRef.removeEventListener(Event.COMPLETE, handleFileRefSave, false);
			_fileRef.removeEventListener(Event.CANCEL,handleFileRefSaveCancel, false);
			_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, handleFileRefSaveError, false);
		}
		
		/////////////////////////
		// File Reference Load //
		/////////////////////////
		
		public function loadFileRef():void
		{
			_fileRef = new FileReference();
			_fileRef.addEventListener(Event.SELECT, handleFileRefSelect, false, 0, true);
			_fileRef.addEventListener(Event.CANCEL,handleFileRefSelectCancel, false, 0, true);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleFileRefSelectIOError, false, 0 , true);
			try
			{
				Alert.show(new AlertContentDefault(CMapConstants.MESSAGE_LOAD_SELECT), null);
				_fileRef.browse(_filter);
			}
			catch (e:IllegalOperationError)
			{
				removeFileRefSelectHandlers();
				_fileRef = null;
			}
			catch (e:SecurityError)
			{
				removeFileRefSelectHandlers();
				_fileRef = null;
			}
		}
		
		private function handleFileRefSelect(e:Event):void
		{
			removeFileRefSelectHandlers();
			_fileRef.addEventListener(Event.COMPLETE, handleFileRefLoadComplete, false, 0, true);
			_fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleFileRefLoadError, false, 0, true);
			_fileRef.load();
		}
		
		private function handleFileRefSelectCancel(e:Event):void
		{
			removeFileRefSelectHandlers()
			_fileRef = null;
		}
		
		private function handleFileRefSelectIOError(e:Event):void
		{
			removeFileRefSelectHandlers()
			_fileRef = null;
		}
		
		private function removeFileRefSelectHandlers():void
		{
			Alert.close();
			
			if (!_fileRef)
				return;
			_fileRef.removeEventListener(Event.SELECT, handleFileRefSelect, false);
			_fileRef.removeEventListener(Event.CANCEL,handleFileRefSelectCancel, false);
			_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, handleFileRefSelectIOError, false);
		}
		
		private function handleFileRefLoadComplete(e:Event):void
		{
			var data:ByteArray = _fileRef.data;
			_controller.onMapLoaded(new XML(data.readUTFBytes(data.bytesAvailable)))
			removeFileRefLoadHandlers();
			_fileRef = null;
		}
		
		private function handleFileRefLoadError(e:IOErrorEvent):void
		{
			removeFileRefLoadHandlers();
			_fileRef = null;
		}
		
		private function removeFileRefLoadHandlers():void
		{
			Alert.close();
			
			if (!_fileRef)
				return;
			_fileRef.removeEventListener(Event.COMPLETE, handleFileRefLoadComplete, false);
			_fileRef.removeEventListener(IOErrorEvent.IO_ERROR, handleFileRefLoadError, false);
		}
		
		///////////////
		// File Save //
		///////////////
		/*
		public function saveFile():void
		{
			_file = new File();
			_file.addEventListener(Event.SELECT, handleFileSaveSelect, false, 0 , true);
			_file.addEventListener(Event.CANCEL, handleFileSaveSelectCancel, false, 0, true);
			_file.addEventListener(IOErrorEvent.IO_ERROR, handleFileSaveSelectIOError, false, 0 , true);
			
			try
			{
				_file.browseForSave("Save As");
			}
			catch (e:IllegalOperationError)
			{
				removeFileSaveSelectListeners();
				_file = null;
			}
			catch (e:SecurityError)
			{
				removeFileSaveSelectListeners();
				_file = null;
			}
		}
		
		private function handleFileSaveSelect(e:Event):void
		{
			var xmlString:String = "";
			var stream:FileStream = new FileStream();
			var file:File = e.target as File;
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(xmlString);
			stream.close();
			
			removeFileSaveSelectListeners();
			_file = null;
		}
		
		private function handleFileSaveSelectCancel(e:Event):void
		{ 
			removeFileSaveSelectListeners();
			_file = null;
		}
		
		private function handleFileSaveSelectIOError(e:IOErrorEvent):void
		{ 
			removeFileSaveSelectListeners();
			_file = null;
		}
		
		private function removeFileSaveSelectListeners():void
		{
			if (!_file)
				return
			_file.removeEventListener(Event.SELECT, handleFileSaveSelect, false);
			_file.removeEventListener(Event.CANCEL, handleFileSaveSelectCancel, false);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, handleFileSaveSelectIOError, false);
		}
		
		///////////////
		// File Load //
		///////////////
		
		public function loadFile():void
		{
			_file = new File();
			_file.addEventListener(Event.SELECT, handleFileSelect, false, 0 , true);
			_file.addEventListener(Event.CANCEL, handleFileSelectCancel, false, 0, true);
			_file.addEventListener(IOErrorEvent.IO_ERROR, handleFileSelectIOError, false, 0 , true);
			
			try
			{
				_file.browseForOpen("Select CMap file.", _filter);
			}
			catch (e:IllegalOperationError)
			{
				removeFileSelectListeners();
			}
			catch (e:SecurityError)
			{
				removeFileSelectListeners();
			}
		}
		
		private function handleFileSelect(e:Event):void
		{
			var stream:FileStream = new FileStream();
			var file:File = e.target as File;
			stream.open(file, FileMode.READ);
			var fileData:String = stream.readUTFBytes(stream.bytesAvailable);
			var xml:XML = new XML(fileData);
			
			removeFileSelectListeners();
			_file = null;
		}
		
		private function handleFileSelectCancel(e:Event):void
		{ 
			removeFileSelectListeners();
			_file = null;
		}
		
		private function handleFileSelectIOError(e:IOErrorEvent):void
		{ 
			removeFileSelectListeners();
			_file = null;
		}
		
		private function removeFileSelectListeners():void
		{
			if (!_file)
				return
			_file.removeEventListener(Event.SELECT, handleFileSelect, false);
			_file.removeEventListener(Event.CANCEL, handleFileSelectCancel, false);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, handleFileSelectIOError, false);
		}
		*/
	}
}