package com.suite75.quake1.io.mdl
{
	import com.suite75.quake1.io.AbstractReader;
	import com.suite75.quake1.io.mdl.types.*;
	
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Entity Alias Model (MDL)
	 * <p>Alias models can be used for entities, like players, objects, or monsters. 
	 * Some entities can use sprite models (that are similar in appearance to those of DOOM, though the 
	 * structure is totally different) or even maybe models similar to those of the levels.</p>
	 * reference: http://tfc.duke.free.fr/coding/mdl-specs-en.html
	 * 
	 * @author Tim Knip
	 */ 
	public class MDLReader extends AbstractReader
	{
		/** */
		public var header:MDLHeader;
		
		/** */
		public var skins:Array;
		
		/** */
		public var texcoords:Array;
		
		/** */
		public var triangles:Array;
		
		/** */
		public var frames:Array;
		
		/**
		 * Constructor
		 */ 
		public function MDLReader()
		{
			super(URLLoaderDataFormat.BINARY);
		}
		
		/**
		 * Parse!
		 * 
		 * @param	data
		 */ 
		protected override function parse(data:ByteArray):void
		{
			data.endian = Endian.LITTLE_ENDIAN;
			data.position = 0;
			
			parseHeader(data);
			parseSkins(data);
			parseTexCoords(data);
			parseTriangles(data);
			parseFrames(data);
			
			trace("#skins: " + this.skins.length);
			trace("#texcoords: " + this.texcoords.length);
			trace("#triangles: " + this.triangles.length);
			trace("#frames: " + this.frames.length);
			
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
			this.header.version = data.readInt();
			
			if(this.header.id != 0x4F504449 && this.header.version != 6)
				throw new Error("Not a MDL file!");
			
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
		 * Parse the skins (usually one).
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
						
					skin.data = new Array(MDLSkinGroup(skin).nb);
					
					for(j = 0; j < MDLSkinGroup(skin).nb; j++)
					{
						skin.data[j] = new Array();
						for(x = 0; x < this.header.skinwidth; x++)
						{
							for(y = 0; y < this.header.skinheight; y++)	
								skin.data[j].push(data.readUnsignedByte());
						}
					}
				}
				else
				{
					skin = new MDLSkin();
					skin.data = new Array();
					for(x = 0; x < this.header.skinwidth; x++)
					{
						for(y = 0; y < this.header.skinheight; y++)	
							skin.data.push(data.readUnsignedByte());
					}
				}	
				skin.group = group;
				
				this.skins.push(skin);
			}	
		}
		
		/**
		 * Parse texcoords
		 * 
		 * @param	data
		 */ 
		private function parseTexCoords(data:ByteArray):void
		{
			this.texcoords = new Array();
			for(var i:int = 0; i < this.header.numverts; i++)
			{
				var texcoord:MDLTexCoord = new MDLTexCoord();
				texcoord.onseam = data.readInt();
				texcoord.s = data.readInt();
				texcoord.t = data.readInt();
				this.texcoords.push(texcoord);
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
				triangle.vertex = new Array();
				triangle.vertex.push(data.readInt());
				triangle.vertex.push(data.readInt());
				triangle.vertex.push(data.readInt());
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
		
		/**
		 * Reads a simple frame.
		 * 
		 * @param	data
		 * 
		 * @return the created frame
		 */ 
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

			frame.vertices = new Array();
			for(var j:int = 0; j < header.numverts; j++)
				frame.vertices.push(readFrameVertex(data));
			return frame;	
		}
		
		/**
		 * Read a frame vertex.
		 * 
		 * @param	data
		 * 
		 * @return	the created vertex
		 */ 
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
		
		/**
		 * Read a vertex.
		 * 
		 * @param	data
		 * 
		 * @return	the created vertex
		 */ 
		private function readVertex(data:ByteArray):Array
		{
			var values:Array = new Array();
			values.push(data.readFloat());	
			values.push(data.readFloat());
			values.push(data.readFloat());
			return values;
		}
	}
}
