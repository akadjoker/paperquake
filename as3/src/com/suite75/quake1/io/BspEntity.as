/*
 * Copyright 2007 (c) Tim Knip, suite75.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package com.suite75.quake1.io
{
	import mx.utils.StringUtil;
	import flash.utils.ByteArray;
	
	/**
	 * 
	 */
	public class BspEntity
	{
		public var classname:String;
		public var message:String;
		public var nextmap:String;
		public var sounds:int;
		public var origin:Array;
		public var angles:Array;
		public var noise:String;
		public var spawnflags:int;
		public var speed:int;
		public var model:String;
		public var light:int;
		public var angle:int = 0;
		public var lip:int;
		public var minlight:Number;
		public var target:String;
		public var worldtype:int;
		public var wad:String;
		public var style:int;
		public var wait:int;
		public var targetname:String;
		public var dmg:int;
		public var mangle:Array;
		public var killtarget:String;
		public var map:String;
		public var count:int;
		public var health:int;
		public var height:int;
		
		/**
		 * 
		 */
		public function BspEntity( entity:String )
		{
			var lines:Array = entity.split( "\n" );
			for( var j:int = 0; j < lines.length; j++ )
			{
				lines[j] = StringUtil.trim( lines[j] );
				var words:Array = lines[j].split( "\" \"" );
				
				words[0] = words[0].substr(1);
				if( words[1] )
					words[1] = words[1].substr(0, words[1].length-1);					
				lines[j] = words;
			}
			parseEntity( lines );
		}
		
		/**
		 * 
		 * @param	pEntity
		 */
		private function parseEntity( pEntityLines:Array ):void
		{
			for( var i:int = 0; i < pEntityLines.length; i++ )
			{
				switch( pEntityLines[i][0] )
				{
					case "classname":
						this.classname = pEntityLines[i][1];
						break;
					
					case "killtarget":
						this.killtarget = pEntityLines[i][1];
						break;
						
					case "dmg":
						this.dmg = parseInt(pEntityLines[i][1]);
						break;
						
					case "count":
						this.count = parseInt(pEntityLines[i][1]);
						break;
					
					case "height":
						this.height = parseInt(pEntityLines[i][1]);
						break;
					
					case "health":
						this.health = parseInt(pEntityLines[i][1]);
						break;
						
					case "style":
						this.style = parseInt(pEntityLines[i][1]);
						break;
					
					case "wait":
						this.wait = parseInt(pEntityLines[i][1]);
						break;
						
					case "worldtype":
						this.worldtype = parseInt(pEntityLines[i][1]);
						break;
					
					case "map":
						this.map = pEntityLines[i][1];
						//trace("MAP: " + this.map);
						break;
						
					case "wad":
						this.wad = pEntityLines[i][1];
						//trace("WAD: " + this.wad);
						break;
						
					case "targetname":
						this.targetname = pEntityLines[i][1];
						break;
						
					case "message":
						this.message = pEntityLines[i][1];
						break;
					
					case "nextmap":
						this.nextmap = pEntityLines[i][1];
						break;
					
					case "mangle":
						this.mangle = parseVector( pEntityLines[i][1] );
						break;
						
					case "origin":
						this.origin = parseVector( pEntityLines[i][1] );
						break;
					
					case "sounds":
						this.sounds = parseInt( pEntityLines[i][1], 10 );
						break;
					
					case "angles":
						this.angles = parseVector( pEntityLines[i][1] );
						break;
					
					case "noise":
						this.noise = pEntityLines[i][1];
						break;
						
					case "spawnflags":
						this.spawnflags = parseInt( pEntityLines[i][1], 10 );
						break;
					
					case "light":
						this.light = parseInt( pEntityLines[i][1], 10 );
						break;
					
					case "angle":
						this.angle = parseInt( pEntityLines[i][1], 10 );
						break;
					
					case "speed":
						this.speed = parseInt( pEntityLines[i][1], 10 );
						break;
						
					case "model":
						this.model = pEntityLines[i][1];
						//trace("MODEL: " + this.model);
						break;
					
					case "_minlight":
						this.minlight = parseFloat(pEntityLines[i][1]);
						break;
					
					case "target":
						this.target = pEntityLines[i][1];
						break;
					
					case "lip":
						this.lip = parseInt( pEntityLines[i][0], 10 );
						break;
						
					case "":
						break;
						
					default:
						trace( "not found: " + pEntityLines[i].join("-->") );
						break;
				}
			}
		}
		
		/**
		 * 
		 * @param	pString
		 * @return
		 */
		private function parseVector( pString:String ):Array
		{
			pString = StringUtil.trim( pString );
			var v:Array = new Array( 3 );
			var parts:Array = pString.split( " " );
			if( parts.length == 3 )
			{
				v[0] = parseFloat( StringUtil.trim(parts[0]) );
				v[1] = parseFloat( StringUtil.trim(parts[1]) );
				v[2] = parseFloat( StringUtil.trim(parts[2]) );
			}
			return v;
		}
	}
}