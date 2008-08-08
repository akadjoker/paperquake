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
	
	public class BspModel
	{
		public var mins:Array;			// 12 [float][3]
		public var maxs:Array;			// 24 [float][3]
		public var origin:Array;		// 36 [float][3]
		public var headnode:Array;		// 52 [float][4]

		public var visleafs:int;		// 56 not including the solid leaf 0
		public var firstface:int;		// 60
		public var numfaces:int;		// 64
	
		public function BspModel()
		{
			
		}
		
		public function read( data:ByteArray ):void
		{
			this.mins = new Array( 3 );
			this.mins[0] = data.readFloat();
			this.mins[1] = data.readFloat();
			this.mins[2] = data.readFloat();
			
			this.maxs = new Array( 3 );
			this.maxs[0] = data.readFloat();
			this.maxs[1] = data.readFloat();
			this.maxs[2] = data.readFloat();
			
			this.origin = new Array( 3 );
			this.origin[0] = data.readFloat();
			this.origin[1] = data.readFloat();
			this.origin[2] = data.readFloat();
			
			this.headnode = new Array( 4 );
			this.headnode[0] = data.readInt();
			this.headnode[1] = data.readInt();
			this.headnode[2] = data.readInt();
			this.headnode[3] = data.readInt();
			
			this.visleafs = data.readInt();
			this.firstface = data.readInt();
			this.numfaces = data.readInt();
		}
	}
}