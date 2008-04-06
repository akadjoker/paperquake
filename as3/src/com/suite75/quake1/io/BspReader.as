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
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.*;
	import mx.utils.StringUtil;
		
	import com.suite75.quake1.io.*;

	/**
	 * 
	 */
	public class BspReader extends EventDispatcher
	{
		public var filename:String;
		
		public var data:ByteArray;
		
		public var header:BspHeader;
		public var planes:Array;
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
		 * 
		 * @param	filename
		 */
		public function BspReader( filename:String )
		{
			this.filename = filename;
			
			loadBsp();
		}
		
		/**
		 * 
		 */
		private function loadBsp():void
		{
			trace( "" );
			trace( "loading " + this.filename );
			
			this._loader = new URLLoader();
			this._loader.dataFormat = URLLoaderDataFormat.BINARY;
			this._loader.addEventListener( Event.COMPLETE, completeHandler );
			this._loader.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
			this._loader.addEventListener( ProgressEvent.PROGRESS, progressHandler );
			this._loader.load( new URLRequest( this.filename ) );
		}
		
		/**
		 * 
		 * @param	event
		 */
        private function completeHandler(event:Event):void 
		{
			trace( "complete" );
			
			this.data = this._loader.data as ByteArray;
			this.data.endian = Endian.LITTLE_ENDIAN;
			
			this.header = new BspHeader();
			this.header.read( this.data );
			
			readPlanes( this.data );
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
        private function errorHandler(event:IOErrorEvent):void 
		{
			trace( "error:" + event.text );
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function progressHandler(event:ProgressEvent):void
		{
			//trace( "loading " + event.bytesLoaded + " of " + event.bytesTotal );
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