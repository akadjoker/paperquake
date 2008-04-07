package com.suite75.quake1.io.pak
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * class PAKReader
	 * <p></p>
	 * 
	 * @author Tim Knip
	 */ 
	public class PAKReader extends EventDispatcher
	{
		/** The file's signature, should be 'PACK' */
		public var signature:String;
		
		public var entries:Array;
		
		public var entries_offset:int;
		
		public var entries_length:int;
		
		/**
		 * Constructor.
		 */
		public function PAKReader()
		{
		}
		
		public function getEntryByName(name:String):ByteArray
		{
			var entry:PAKEntry = _entryByName[name];
			if(!entry)
				return null;
				
			var ba:ByteArray = new ByteArray();
			
			//_data.position = entry.offset;
			ba.writeBytes(_data, entry.offset, entry.length);
			return ba;
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
				
			this.entries_offset = _data.readInt();
			this.entries_length = _data.readInt();
			
			readEntries();
			
			dispatchEvent(event);
		}
		 
		/**
		 * Reads all entries.
		 */
		private function readEntries():void
		{
			var bytesRead:int = 0;
			
			_data.position = this.entries_offset;	
			
			this.entries = new Array();
			_entryByName = new Object();
			
			while(bytesRead < this.entries_length)
			{
				var entry:PAKEntry = new PAKEntry();
				
				entry.name = readString();
				entry.offset = _data.readInt();
				entry.length = _data.readInt();
				
				entries.push(entry);
				_entryByName[ entry.name ] = entry;
				
				trace(entry.name);
				
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