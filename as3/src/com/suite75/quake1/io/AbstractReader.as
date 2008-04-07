package com.suite75.quake1.io
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	public class AbstractReader extends EventDispatcher
	{
		public var dataFormat:String;
		
		/**
		 * Constructor.
		 * 
		 * @param 	dataFormat
		 */ 
		public function AbstractReader(dataFormat:String=null)
		{
			this.dataFormat = dataFormat || URLLoaderDataFormat.BINARY;
		}

		/**
		 * Load.
		 * 
		 * @param	asset An url or a ByteArray
		 */ 
		public function load(asset:*):void
		{
			if(asset is ByteArray)
			{
				parse(asset as ByteArray);
			}
			else if(asset is String)
			{
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = this.dataFormat;
				loader.addEventListener(Event.COMPLETE, onLoadComplete);
				loader.load(new URLRequest(String(asset)));
			}
			else
				throw new Error("Need a url or a ByteArray!");
		}
		
		/**
		 * Parse!
		 * 
		 * @param 	data
		 */ 
		protected function parse(data:ByteArray):void
		{
		}
		
		/**
		 * 
		 * @param	event
		 */ 
		protected function onLoadComplete(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			parse(loader.data);
		}
	}
}