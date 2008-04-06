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
	import com.suite75.quake1.io.BspLump;

	public class BspHeader
	{
		public var version:int;
		public var lumps:Array;
		
		/**
		 * 
		 */
		public function BspHeader()
		{
			
		}
		
		/**
		 * 
		 * @param	data
		 */
		public function read( data:ByteArray ):void
		{
			this.version = data.readInt();
			this.lumps = new Array( BspLump.HEADER_LUMPS );
			
			trace( "version: " + this.version );
			
			for( var i:int = 0; i < BspLump.HEADER_LUMPS; i++ )
			{
				this.lumps[i] = new BspLump();
				this.lumps[i].offset = data.readUnsignedInt();
				this.lumps[i].length = data.readUnsignedInt();
			}
		}
	}
}