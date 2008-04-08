package com.suite75.quake1.io.mdl.types
{
	public class MDLHeader
	{
		public var id:int;            		// 0x4F504449 = "IDPO" for IDPOLYGON
		public var version:int;            	// Version = 6
		public var scale:Array;       		// Model scale factors.
		public var origin:Array;      		// Model origin.
		public var radius:Number;         	// Model bounding radius.
		public var offsets:Array;     		// Eye position (useless?)
		public var numskins:int;       		// the number of skin textures
		public var skinwidth:int;           // Width of skin texture
		                               		//           must be multiple of 8
		public var skinheight:int;          // Height of skin texture
		                               		//           must be multiple of 8
		public var numverts:int;            // Number of vertices
		public var numtris:int;             // Number of triangles surfaces
		public var numframes:int;           // Number of frames
		public var synctype:int;            // 0= synchron, 1= random
		public var flags:int;               // 0 (see Alias models)
		public var size:Number;             // average size of triangles
	}
}