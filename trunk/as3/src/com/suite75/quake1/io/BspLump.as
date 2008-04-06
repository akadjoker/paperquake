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
	public class BspLump
	{
		public static const BSPVERSION:uint = 29;
		public static const TOOLVERSION:uint = 2;
		
		public static const LUMP_ENTITIES:uint 			= 0;	// MAP entity text buffer	
		public static const LUMP_PLANES:uint 			= 1;	// Plane array
		public static const LUMP_TEXTURES:uint 			= 2;	// Plane array
		public static const LUMP_VERTEXES:uint 			= 3;	// Vertices array
		public static const LUMP_VISIBILITY:uint 		= 4;	// Compressed PVS data and directory for all clusters	
		public static const LUMP_NODES:uint 			= 5;	// Internal node array for the BSP tree	
		public static const LUMP_TEXTURE_INFO:uint 		= 6;	// Face texture application array	
		public static const LUMP_FACES:uint 			= 7;	// Face array	
		public static const LUMP_LIGHTING:uint 			= 8;	// Lightmaps
		public static const LUMP_CLIPNODES:uint 		= 9;	// 
		public static const LUMP_LEAVES:uint 			= 10;	// Internal leaf array of the BSP tree	
		public static const LUMP_MARKSURFACES:uint		= 11;	// Index lookup table for referencing the face array from a leaf	
		public static const LUMP_EDGES:uint 			= 12;	// Edge Array
		public static const LUMP_SURFEDGES:uint			= 13;	// Index lookup table for referencing the edge array from a face	
		public static const LUMP_MODELS:uint 			= 14;	// ?
		public static const HEADER_LUMPS:uint			= 15;	// ?
		
		public var offset:uint;     // offset (in bytes) of the data from the beginning of the file
		public var length:uint;     // length (in bytes) of the data
		
		/**
		 * 
		 * @param	offset
		 * @param	length
		 */
		public function BspLump( offset:uint = 0, length:uint = 0 )
		{
			this.offset = offset;
			this.length = length;
		}
	}
}
