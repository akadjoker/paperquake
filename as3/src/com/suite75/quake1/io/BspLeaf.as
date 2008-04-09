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
	
	/**
	 * class BspLeaf.
	 * 
	 * <p>leaf 0 is the generic CONTENTS_SOLID leaf, used for all solid areas. 
	 * all other leafs need visibility info</p>
	 */
	public class BspLeaf
	{
		public static const AMBIENT_WATER:uint = 0;
		public static const	AMBIENT_SKY:uint = 1;
		public static const	AMBIENT_SLIME:uint = 2;
		public static const	AMBIENT_LAVA:uint = 3;

		public static const	NUM_AMBIENTS:uint = 4;		// automatic ambient sounds

		public var contents:int;			// 4
		public var visofs:int;				// 8 -1 = no visibility info
		public var mins:Array;				// 14 [short][3]
		public var maxs:Array;				// 20 [short][3]
		public var firstmarksurface:uint; 	// 22 [ushort]
		public var nummarksurfaces:uint;	// 24 [ushort]
		public var ambient_level:Array;		// 28 [byte][4]
		
		public var visible:Boolean = false;
		
		/**
		 * 
		 */
		public function BspLeaf()
		{
			
		}
		
		/**
		 * 
		 * @param	pData
		 */
		public function read( pData:ByteArray ):void
		{
			this.contents = pData.readInt();
			this.visofs = pData.readInt();

			this.mins = new Array( 3 );
			this.mins[0] = pData.readShort();
			this.mins[1] = pData.readShort();
			this.mins[2] = pData.readShort();
			
			this.maxs = new Array( 3 );
			this.maxs[0] = pData.readShort();
			this.maxs[1] = pData.readShort();
			this.maxs[2] = pData.readShort();
			
			this.firstmarksurface = pData.readUnsignedShort();
			this.nummarksurfaces = pData.readUnsignedShort();
			
			this.ambient_level = new Array( 4 );
			this.ambient_level[0] = pData.readByte();
			this.ambient_level[1] = pData.readByte();
			this.ambient_level[2] = pData.readByte();
			this.ambient_level[3] = pData.readByte();
		}
	}
}
