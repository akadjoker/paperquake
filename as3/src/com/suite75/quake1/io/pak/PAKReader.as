package com.suite75.quake1.io.pak
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class PAKReader extends EventDispatcher
	{
		public var signature:String;
		
		public var directories:Array;
		
		public var directory_offset:int;
		
		public var directory_length:int;
		
		/**
		 * Constructor.
		 */
		public function PAKReader()
		{
		}
		
		/**
		 * Load
		 *
		 * @param	url
		 */  
		public function load(url:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest(url));
		}
		
		/**
		 * Fired when the PAK was loaded from disk.
		 * 
		 * @param	event
		 */ 
		private function onLoadComplete(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			_data = loader.data;
			_data.position = 0;
			_data.endian = Endian.LITTLE_ENDIAN;
			
			this.signature = readSignature();
			
			if(this.signature != "PACK")
				throw new Error("This isn't a Quake1 PAK file!");
				
			this.directory_offset = _data.readInt();
			this.directory_length = _data.readInt();
			
			readEntries();
		}
		 
		/**
		 * Reads all entries.
		 */
		private function readEntries():void
		{
			var bytesRead:int = 0;
			
			_data.position = this.directory_offset;	
			
			this.directories = new Array();
			_entryByName = new Object();
			
			while(bytesRead < this.directory_length)
			{
				var directory:PAKEntry = new PAKEntry();
				
				directory.name = readString();
				directory.offset = _data.readInt();
				directory.length = _data.readInt();
				
				directories.push(directory);
				_entryByName[ directory.name ] = directory;
				
				trace(directory.name);
				
				bytesRead += 64;
			}
		}
		
		/**
		 * Reads the PAK file signature. (should be 'PACK')
		 */ 
		private function readSignature():String
		{
			var signature:String = "";
			for(var i:int = 0; i < 4; i++)
				signature += String.fromCharCode(_data.readByte());
			return signature;
		}
		
		/**
		 * Reads a string
		 * 
		 * @param	maxChars
		 * 
		 * @return The String read.
		 */ 
		private function readString(maxChars:int = 56):String
		{
			var s:String = "";
			for(var i:int = 0; i < maxChars; i++)
			{
				var c:int = _data.readByte();
				if(c)
					s += String.fromCharCode(c);
			}
			return s;
		}
		
		private var _data:ByteArray;
		
		private var _entryByName:Object;
	}
}

class PAKEntry
{
	public var name:String;
	public var offset:int;
	public var length:int;
}