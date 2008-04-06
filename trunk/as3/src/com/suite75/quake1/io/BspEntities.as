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
	import flash.utils.ByteArray;
	import mx.utils.StringUtil;

	import com.suite75.quake1.io.BspEntity;
	import com.suite75.quake1.io.BspLump;
	
	/**
	 * 
	 */
	public class BspEntities
	{
		public var entities:Array;
		
		/**
		 * 
		 */
		public function BspEntities()
		{
			
		}
		
		public function findEntitiesByClassName( pClassName:String ):Array
		{
			var ents:Array = new Array();
			for( var i:int = 0; i < this.entities.length; i++ )
			{
				var ent:BspEntity = this.entities[i] as BspEntity;
				if( ent.classname == pClassName )
					ents.push( ent );
			}
			return ents;
		}
		
		/**
		 * 
		 * @param	pClassName
		 * @return
		 */
		public function findEntityByClassName( pClassName:String ):BspEntity
		{
			var ents:Array = findEntitiesByClassName( pClassName );
			return ents[0] as BspEntity;
		}
		
		/**
		 * 
		 * @return
		 */
		public function findRandomSpawnOrigin():Array 
		{
			var ents:Array = findEntitiesByClassName( "info_player_deathmatch" );
			var idx:int = Math.round( Math.random() * ents.length-1 );
			return BspEntity( ents[idx] ).origin;
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray, length:uint ):void
		{
			var s:String = pData.readMultiByte( length, "iso-8859-1" );
			
			this.entities = s.split( "}" );
			
			var num:uint = 0;
			
			for( var i:int = 0; i < this.entities.length; i++ )
			{
				var pos:int = this.entities[i].indexOf( "{" );
				this.entities[i] = this.entities[i].substr(pos+1);
				this.entities[i] = StringUtil.trim( this.entities[i] );
				this.entities[i] = new BspEntity( this.entities[i] );
			}
		}
	}
}