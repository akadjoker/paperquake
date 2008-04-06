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
	
	public class BspNode
	{
		public var planenum:int;	// 4
		public var children:Array;	// 8 [short][2] negative numbers are -(leafs+1), not nodes
		public var mins:Array;		// 14 [short][3]
		public var maxs:Array;		// 20 [short][3]
		public var firstface:int;	// 22 [ushort]
		public var numfaces:int;	// 24 [ushort]

		public function BspNode()
		{
			
		}
		
		public function read( data:ByteArray ):void
		{
			this.planenum = data.readInt();
			this.children = new Array( 2 );
			this.children[0] = data.readShort();
			this.children[1] = data.readShort();
			
			this.mins = new Array( 3 );
			this.mins[0] = data.readShort();
			this.mins[1] = data.readShort();
			this.mins[2] = data.readShort();
			
			this.maxs = new Array( 3 );
			this.maxs[0] = data.readShort();
			this.maxs[1] = data.readShort();
			this.maxs[2] = data.readShort();
			
			this.firstface = data.readUnsignedShort();
			this.numfaces = data.readUnsignedShort();
		}
	}
}
