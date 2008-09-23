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
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
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
		public var lightmaps:Array;
		
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
		//	readLightMaps( this.data );

			for each(var surf:BspFace in this.faces)
				calcSurfaceExtents(surf);
				
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
			//trace( "#lightmaps : " + this.lightmaps.length );
			
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
		 * Builds a lightmap for a surface.
		 * 
		 * @param	surf
		 * @param	bitmap
		 * 
		 * @return
		 */ 
		public function buildLightMap(surf:BspFace, bitmap:BitmapData):BitmapData
		{
			var smax:uint,
				tmax:uint,
				blocklights:Array = new Array(64*64),
				size:int,
				i:int,
				maps:int,
				l:int = surf.lightmap_offset,
				scl:uint,
				lightdata:ByteArray = this.data,
				lightlump:BspLump = this.header.lumps[BspLump.LUMP_LIGHTING],
				bl_pos:int = 0;
				
			smax = (surf.extents[0] >> 4) + 1;
            tmax = (surf.extents[1] >> 4) + 1;
            size = smax * tmax;
            
            lightdata.position = 0;;
            l += lightlump.offset;
            
            for(i = 0; i < 364; i++)
                blocklights[i] = 0;
                
            for(maps = 0; maps < 4 && surf.lightmap_styles[maps] != 255; maps++)
            {
                scl = 264;

                for (i = 0; i < size; i++)
                    blocklights[i] += lightdata[l + i] * scl;

                l += size;
            }
            
            var buf:ByteArray = new ByteArray();

			for(i = 0; i < size; i++, bl_pos++)
			{
				var t:uint = blocklights[bl_pos];
			
				t >>= 7;
				
				if (t > 255)
					t = 255;

				buf.writeUnsignedInt(0xff << 24 | t << 16 | t << 8 | t);
            }
            
            buf.position = 0;
    
            var lightmap:BitmapData = new BitmapData(smax, tmax, true, 0x00000000);
			
			lightmap.setPixels(new Rectangle(0, 0, smax, tmax), buf);

			var bm:BitmapData = bitmap.clone();
			var matrix:Matrix = new Matrix();
			
			matrix.scale(bm.width/smax, bm.height/tmax);
		
			bm.draw(lightmap, matrix, null, BlendMode.MULTIPLY, null, true);
			
			return bm;
		}
		
		/**
		 * 
		 * @param	data
		 */
		private function calcSurfaceExtents(surf:BspFace):void
		{
			var i:int,
				e:int,
				v:Array,
				edge:BspEdge,
				tex:BspTexInfo,
				mins:Array = new Array(2),
				maxs:Array = new Array(2),
				bmins:Array = new Array(2),
				bmaxs:Array = new Array(2);
			
			mins[0] = mins[1] = 999999;
            maxs[0] = maxs[1] = -99999;
            
			tex = this.tex_info[surf.texture_info];
			
			for(i = 0; i < surf.num_edges; i++)
			{
				e = this.surfedges[surf.first_edge + i];
				
				if (e >= 0)
				{
					edge = this.edges[e];
                    v = this.vertices[edge.startvertex];
    			}
                else
                {
                	edge = this.edges[-e];
                    v = this.vertices[edge.endvertex];
                }
                
                var sval:Number = v[0] * tex.u_axis[0] + v[1] * tex.u_axis[1] + v[2] * tex.u_axis[2] + tex.u_offset;
                var tval:Number = v[0] * tex.v_axis[0] + v[1] * tex.v_axis[1] + v[2] * tex.v_axis[2] + tex.v_offset;
                
                if(sval < mins[0])
                	mins[0] = sval;
                if(sval > maxs[0])
                	maxs[0] = sval;
                if(tval < mins[1])
                	mins[1] = tval;
                if(tval > maxs[1])
                	maxs[1] = tval;
			}
			
			surf.extents = new Array(2);
			surf.texturemins = new Array(2);
			
			for(i = 0; i < 2; i++)
			{
				bmins[i] = Math.floor(mins[i] / 16);
				bmaxs[i] = Math.ceil(maxs[i] / 16);
				
				surf.texturemins[i] = bmins[i] * 16;
                surf.extents[i] = (bmaxs[i] - bmins[i]) * 16;
			}
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
		private function readLightMaps( data:ByteArray ):void
		{
			var lump:BspLump = this.header.lumps[BspLump.LUMP_LIGHTING];
			data.position = lump.offset;
			
			this.lightmaps = new Array();
			for( var i:int = 0; i < lump.length; i++ )
				this.lightmaps.push(data.readUnsignedByte());
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
			
			var nSurfEdges:uint = lump.length / 4;
			
			for( var i:int = 0; i < nSurfEdges; i++ )
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
				
				for(var y:int = 0; y < texture.height; y++)
				{
					for(var x:int = 0; x < texture.width; x++)
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