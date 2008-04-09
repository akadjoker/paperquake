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
	
	public class BspFace
	{
		public var plane:uint;             	// [ushort] index of the plane the face is parallel to
		public var plane_side:int;        	// [ushort] set if the normal is parallel to the plane normal
		public var first_edge:int;        	// [uint] index of the first edge (in the face edge array)
		public var num_edges:uint;         	// [ushort] number of consecutive edges (in the face edge array)
		public var texture_info:uint;      	// [ushort] index of the texture info structure	
		public var lightmap_styles:Array; 	// [ubyte][4] styles (bit flags) for the lightmaps
		public var lightmap_offset:int;   	// [uint] offset of the lightmap (in bytes) in the lightmap lump
		
		public var min_s:Number;
		public var min_t:Number;
		public var max_s:Number;
		public var max_t:Number;
		public var size_s:Number;
		public var size_t:Number;
		public var cache_offset:Number;
		
		public function BspFace()
		{
			
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.plane = pData.readUnsignedShort();//2
			this.plane_side = pData.readShort(); //4
			this.first_edge = pData.readInt(); // 8
			this.num_edges = pData.readUnsignedShort(); // 10
			this.texture_info = pData.readUnsignedShort(); // 12
			this.lightmap_styles = new Array();
			this.lightmap_styles[0] = pData.readUnsignedByte(); //13
			this.lightmap_styles[1] = pData.readUnsignedByte(); // 14
			this.lightmap_styles[2] = pData.readUnsignedByte(); // 15
			this.lightmap_styles[3] = pData.readUnsignedByte(); // 16
			this.lightmap_offset = pData.readInt();  // 20
		}
	}
}
