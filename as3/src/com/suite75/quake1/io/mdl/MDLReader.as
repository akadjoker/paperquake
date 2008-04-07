package com.suite75.quake1.io.mdl
{
	import com.suite75.quake1.io.AbstractReader;
	
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Entity Alias Model
	 * <p>Alias models can be used for entities, like players, objects, or monsters. 
	 * Some entities can use sprite models (that are similar in appearance to those of DOOM, though the 
	 * structure is totally different) or even maybe models similar to those of the levels.</p>
	 * 
	 * @author Tim Knip
	 */ 
	public class MDLReader extends AbstractReader
	{
		public function MDLReader()
		{
			super(URLLoaderDataFormat.BINARY);
		}
		
		protected override function parse(data:ByteArray):void
		{
			data.endian = Endian.LITTLE_ENDIAN;
			data.position = 0;
			
			parseHeader(data);
			parseSkins(data);
			parseVertices(data);
			parseTriangles(data);
			parseFrames(data);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Parse the MDL header.
		 * 
		 * @param data
		 */ 
		private function parseHeader(data:ByteArray):void
		{
			this.header = new MDLHeader();
		
			this.header.id = data.readInt();
			
			if(this.header.id != 0x4F504449)
				throw new Error("Not a MDL file!");
			
			this.header.version = data.readInt();
			
			trace("MDL: " + this.header.id.toString(16) + " version:" + this.header.version);
				
			this.header.scale = new Array();
			this.header.scale.push(data.readFloat());
			this.header.scale.push(data.readFloat());
			this.header.scale.push(data.readFloat());
			
			this.header.origin = new Array();
			this.header.origin.push(data.readFloat());
			this.header.origin.push(data.readFloat());
			this.header.origin.push(data.readFloat());
			
			this.header.radius = data.readInt();
			
			this.header.offsets = new Array();
			this.header.offsets.push(data.readFloat());
			this.header.offsets.push(data.readFloat());
			this.header.offsets.push(data.readFloat());
			
			this.header.numskins = data.readInt();
			this.header.skinwidth = data.readInt();
			this.header.skinheight = data.readInt();
			this.header.numverts = data.readInt();
			this.header.numtris = data.readInt();
			this.header.numframes = data.readInt();
			this.header.synctype = data.readInt();
			this.header.flags = data.readInt();
			this.header.size = data.readInt();
		}
		
		/**
		 * Parse the skins.
		 * 
		 * @param	data
		 */ 
		private function parseSkins(data:ByteArray):void
		{
			var i:int, j:int, x:int, y:int;
			
			this.skins = new Array();
			for(i = 0; i < this.header.numskins; i++)
			{
				var skin:MDLSkin;
				var group:int = data.readInt();
				if(group)
				{
					skin = new MDLSkinGroup();
					MDLSkinGroup(skin).nb = data.readInt();
					MDLSkinGroup(skin).time = new Array();
					for(j = 0; j < MDLSkinGroup(skin).nb; j++)
						MDLSkinGroup(skin).time.push(data.readFloat());
						
					skin.skin = new Array(MDLSkinGroup(skin).nb);
					
					for(j = 0; j < MDLSkinGroup(skin).nb; j++)
					{
						skin.skin[j] = new Array();
						for(x = 0; x < this.header.skinwidth; x++)
						{
							for(y = 0; y < this.header.skinheight; y++)	
								skin.skin[j].push(data.readUnsignedByte());
						}
					}
				}
				else
				{
					skin = new MDLSkin();
					skin.skin = new Array();
					for(x = 0; x < this.header.skinwidth; x++)
					{
						for(y = 0; y < this.header.skinheight; y++)	
							skin.skin.push(data.readUnsignedByte());
					}
				}	
				skin.group = group;
				
				this.skins.push(skin);
			}	
		}
		
		/**
		 * Parse vertices
		 * 
		 * @param	data
		 */ 
		private function parseVertices(data:ByteArray):void
		{
			this.vertices = new Array();
			for(var i:int = 0; i < this.header.numverts; i++)
			{
				var vertex:MDLVertex = new MDLVertex();
				vertex.onseam = data.readInt();
				vertex.s = data.readInt();
				vertex.t = data.readInt();
				this.vertices.push(vertex);
			}
		}
		
		/**
		 * Parse triangles
		 * 
		 * @param	data
		 */ 
		private function parseTriangles(data:ByteArray):void
		{
			this.triangles = new Array();
			for(var i:int = 0; i < this.header.numtris; i++)
			{
				var triangle:MDLTriangle = new MDLTriangle();
				triangle.facesfront = data.readInt();
				triangle.vertices = new Array();
				triangle.vertices.push(data.readInt());
				triangle.vertices.push(data.readInt());
				triangle.vertices.push(data.readInt());
				this.triangles.push(triangle);
			}
		}
		
		/**
		 * Parse frames
		 * 
		 * @param	data
		 */ 
		private function parseFrames(data:ByteArray):void
		{
			this.frames = new Array();
			for(var i:int = 0; i < header.numframes; i++)
			{
				var type:int = data.readInt();
				if(type)
				{
					throw new Error("can't read models composed of group frames!");
					/*
					var group:MDLFrameGroup = new MDLFrameGroup();
					group.min = readFrameVertex(data);
					group.max = readFrameVertex(data);
					group.time = new Array();
					group.time.push(data.readFloat());
					group.frames = new Array();
					group.frames.push(readSimpleFrame(data));
					*/
				}
				else
				{
					var frame:MDLFrame = new MDLFrame();
					frame.type = type;
					frame.frame = readSimpleFrame(data);
					this.frames.push(frame);
				}
			}
		}
		
		private function readSimpleFrame(data:ByteArray):MDLSimpleFrame
		{
			var frame:MDLSimpleFrame = new MDLSimpleFrame();
			
			frame.min = readFrameVertex(data);
			frame.max = readFrameVertex(data);
			frame.name = "";
			
			var done:Boolean = false;
			for(var i:int = 0; i < 16; i++)
			{
				var c:int = data.readUnsignedByte();
				if(c && !done)
					frame.name += String.fromCharCode(c);
				else
					done = true;
			}

			frame.frame = new Array();
			for(var j:int = 0; j < header.numverts; j++)
				frame.frame.push(readFrameVertex(data));
			return frame;	
		}
		
		private function readFrameVertex(data:ByteArray):MDLFrameVertex
		{
			var v:MDLFrameVertex = new MDLFrameVertex();
			v.packedposition = new Array();
			v.packedposition.push(data.readUnsignedByte());
			v.packedposition.push(data.readUnsignedByte());
			v.packedposition.push(data.readUnsignedByte());
			v.lightnormalindex = data.readUnsignedByte();
			return v;
		}
		
		private function readVertex(data:ByteArray):Array
		{
			var values:Array = new Array();
			values.push(data.readFloat());	
			values.push(data.readFloat());
			values.push(data.readFloat());
			return values;
		}
		
		private var header:MDLHeader;
		private var skins:Array;
		private var vertices:Array;
		private var triangles:Array;
		private var frames:Array;
	}
}

class MDLHeader
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

class MDLSkin
{
	public var group:int;		// 0
	public var skin:Array;		// [skinwidth*skinheight] the skin picture
	public function MDLSkin(){}
}

class MDLSkinGroup extends MDLSkin
{
	public var nb:int;			// number of pictures in group
	public var time:Array;		// float time[nb]; time values, for each picture
	public function MDLSkinGroup(){}
}

class MDLVertex
{
	public var onseam:int;
	public var s:int;
	public var t:int;
}

class MDLTriangle
{
	public var facesfront:int;
	public var vertices:Array;
}

class MDLFrameVertex
{
	public var packedposition:Array;	// 3 bytes - X,Y,Z coordinate, packed on 0-255
	public var lightnormalindex:int;	// 1 byte  - index of the vertex normal
}

class MDLSimpleFrame
{
	public var min:MDLFrameVertex;
	public var max:MDLFrameVertex;
	public var name:String;		// [16]
	public var frame:Array;
}

class MDLFrame
{
	public var type:int;				// value = 0
	public var frame:MDLSimpleFrame;	// a single frame definition
}

class MDLFrameGroup
{
	public var type:int;				// value != 0
	public var min:MDLFrameVertex;
	public var max:MDLFrameVertex;
	public var time:Array;
	public var frames:Array;
}