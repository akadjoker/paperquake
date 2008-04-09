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
	import com.suite75.quake1.data.QuakePalette;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;

	/**
	 * 
	 */
	public class BspReader extends AbstractReader
	{
		public var data:ByteArray;
		
		public var header:BspHeader;
		public var planes:Array;
		public var textures:Array;
		public var tex_info:Array;
		public var vertices:Array;
		public var faces:Array;
		public var edges:Array;
		public var surfedges:Array;
		public var visibility:Array;
		public var models:Array;
		public var nodes:Array;
		public var clipnodes:Array;
		public var marksurfaces:Array;
		public var leaves:Array;
		public var entities:BspEntities;
		
		/**
		 * Constructor.
		 */
		public function BspReader()
		{
		}
		
		protected override function parse(data:ByteArray):void
		{
			trace( "complete" );
			
			this.data = data;
			this.data.endian = Endian.LITTLE_ENDIAN;
			
			this.header = new BspHeader();
			this.header.read( this.data );
			
			readPlanes( this.data );
			readTextures(this.data);
			readTextureInfo( this.data );
			readVertexes( this.data );
			readFaces( this.data );
			readEdges( this.data );
			readVisibility( this.data );
			readNodes( this.data );
			readModels( this.data );
			readClipNodes( this.data );
			readMarkSurfaces( this.data );
			readLeaves( this.data );
			readEntities( this.data );
			readSurfEdges( this.data );
			
			trace( "#planes : " + this.planes.length );
			trace( "#textures : " + this.textures.length );
			trace( "#tex_info : " + this.tex_info.length );
			trace( "#vertices : " + this.vertices.length );
			trace( "#faces : " + this.faces.length );
			trace( "#edges : " + this.edges.length );
			trace( "#visibility : " + this.visibility.length );
			trace( "#nodes : " + this.nodes.length );
			trace( "#models : " + this.models.length );
			trace( "#clipnodes : " + this.clipnodes.length );
			trace( "#marksurfaces : " + this.marksurfaces.length );
			trace( "#leaves : " + this.leaves.length );
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		/**
		 * 
		 * @param	event
		 */
		protected override function onLoadProgress(event:ProgressEvent):void
		{
			dispatchEvent(event);
		}

		/**
		 * 
		 * @param	data
		 */
		private function readClipNodes( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_CLIPNODES];
			data.position = lump.offset;
			
			this.clipnodes = new Array();
			var num:uint = lump.length / 8;
			
			for( var i:int = 0; i < num; i++ )
			{
				var node:BspClipNode = new BspClipNode();
				node.read( data );
				this.clipnodes.push( node );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readEdges( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_EDGES];
			data.position = lump.offset;
			
			this.edges = new Array();
			var num:uint = lump.length / 4;
			
			for( var i:int = 0; i < num; i++ )
			{
				var edge:BspEdge = new BspEdge( data.readUnsignedShort(), data.readUnsignedShort() );
				this.edges.push( edge );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readEntities( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_ENTITIES];
			data.position = lump.offset;
			this.entities = new BspEntities();
			this.entities.read( data, lump.length );
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readFaces( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_FACES];
			data.position = lump.offset;
			
			this.faces = new Array();
			
			// facelump is 20 bytes
			var nFaces:uint = lump.length / 20;
			
			for( var i:int = 0; i < nFaces; i++ )
			{
				var f:BspFace = new BspFace();
				f.read( data );
				this.faces.push( f );
			}
		}

		/**
		 * 
		 * @param	data
		 */
		private function readLeaves( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_LEAVES];
			data.position = lump.offset;
			
			this.leaves = new Array();
			
			// leaflump is 28 bytes
			var num:uint = lump.length / 28;
			
			for( var i:int = 0; i < num; i++ )
			{
				var leaf:BspLeaf = new BspLeaf();
				leaf.read( data );
				this.leaves.push( leaf );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readMarkSurfaces( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_MARKSURFACES];
			data.position = lump.offset;
			
			this.marksurfaces = new Array();
			
			for( var i:int = 0; i < lump.length; i++ )
			{
				this.marksurfaces.push( data.readUnsignedShort() );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readModels( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_MODELS];
			data.position = lump.offset;
			
			var num:uint = lump.length / 64;
			
			this.models = new Array();
			for( var i:int = 0; i < num; i++ )
			{
				var model:BspModel = new BspModel();
				model.read( data );
				this.models.push( model );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readNodes( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_NODES];
			data.position = lump.offset;
			
			var num:uint = lump.length / 24;
			
			this.nodes = new Array();
			for( var i:int = 0; i < num; i++ )
			{
				var node:BspNode = new BspNode();
				node.read( data );
				this.nodes.push( node );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readPlanes( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_PLANES];
			data.position = lump.offset;
			
			this.planes = new Array();
			
			// planes lump is 20 bytes
			var nPlanes:uint = lump.length / 20;
			
			for( var i:int = 0; i < nPlanes; i++ )
			{
				var p:BspPlane = new BspPlane();
				p.read( data );
				this.planes.push( p );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readSurfEdges( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_SURFEDGES];
			data.position = lump.offset;
			
			this.surfedges = new Array();
			
			for( var i:int = 0; i < lump.length; i++ )
			{
				this.surfedges.push( data.readInt() );
			}
		}
		
		/**
		 * Reads a string
		 * 
		 * @param	maxChars
		 * 
		 * @return The String read.
		 */ 
		private function readString(maxChars:int = 16):String
		{
			var s:String = "";
			var atEnd:Boolean = false;
			for(var i:int = 0; i < maxChars; i++)
			{
				var c:int = data.readByte();
				if(c && !atEnd)
					s += String.fromCharCode(c);
				else
					atEnd = true;
			}
			return s;
		}

		/**
		 * 
		 * @param	data
		 */
		private function readTextureInfo( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_TEXTURE_INFO];
			data.position = lump.offset;
			
			// textureinfo lump is 40 bytes
			var num:uint = lump.length / 40;
			
			this.tex_info = new Array();
			
			for( var i:int = 0; i < num; i++ )
			{
				var texinfo:BspTexInfo = new BspTexInfo();
				texinfo.read( data );
				this.tex_info.push( texinfo );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readTextures( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_TEXTURES];
			data.position = lump.offset;
			
			this.textures = new Array();
			
			var startOffset:int = data.position;
			
			var numtex:int = data.readInt();
			var offsets:Array = new Array();
			var i:int;
			
			for(i = 0; i < numtex; i++)
				offsets.push(data.readInt());
			
			for(i = 0; i < numtex; i++)
			{
				data.position = offsets[i] < 0 ? startOffset + 4 + (numtex*4) : startOffset + offsets[i];
				
				var texture:BspTexture = new BspTexture();
				
				texture.position = data.position;
				texture.name = readString(16);
				texture.width = data.readUnsignedInt();
				texture.height = data.readUnsignedInt();
				texture.offset1 = data.readUnsignedInt();
				texture.offset2 = data.readUnsignedInt();
				texture.offset4 = data.readUnsignedInt();
				texture.offset8 = data.readUnsignedInt();
				
				this.textures.push(texture);
				
				// move file pointer to start of color indices 
				data.position = texture.position + texture.offset1;
				
				texture.bitmap = new BitmapData(texture.width, texture.height, true, 0xff000000);
				
				for(var x:int = 0; x < texture.width; x++)
				{
					for(var y:int = 0; y < texture.height; y++)
					{
						var index:uint = data.readUnsignedByte();
						
						var pal:Array = QuakePalette.rgb[index];
	
						var r:uint = pal[0];
						var g:uint = pal[1];
						var b:uint = pal[2];
						var col:uint = (r<<16 | g<<8 | b);
					
						texture.bitmap.setPixel(x, y, col);			
					}
				}
			}
		}
			
		/**
		 * 
		 * @param	data
		 */
		private function readVertexes( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_VERTEXES];
			data.position = lump.offset;
			
			this.vertices = new Array();
			var nVerts:uint = lump.length / 4 / 3;
			
			for( var i:int = 0; i < nVerts; i++ )
			{
				var pt:Array = new Array();
				pt[0] = data.readFloat();
				pt[1] = data.readFloat();
				pt[2] = data.readFloat();
				this.vertices.push( pt );
			}
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function readVisibility( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_VISIBILITY];
			data.position = lump.offset;
			
			this.visibility = new Array();
			
			for( var i:int = 0; i < lump.length; i++ )
			{
				this.visibility.push( data.readByte() );
			}
		}
		
		private var _loader:URLLoader;
	}
}