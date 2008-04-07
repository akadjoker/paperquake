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
 
package com.suite75.papervision3d.quake1
{
	import com.suite75.quake1.io.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.cameras.*;
	import org.papervision3d.core.geom.*;
	import org.papervision3d.core.geom.renderables.*;
	import org.papervision3d.core.math.*;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	public class QuakeEngine extends Sprite
	{
		public var scene:Scene3D;
		
		public var camera:FreeCamera3D;
		
		public var viewport:Viewport3D;
		
		public var renderer:BasicRenderEngine
		
		public var map:TriangleMesh3D;
		
		/**
		 * 
		 * @param	name
		 * @param	geometry
		 * @param	initObject
		 */
		public function QuakeEngine()
		{
			init();
		}
		
		protected function init():void
		{
			Papervision3D.log( "" );
			Papervision3D.log( "Quake Engine v0.1" );
			
			this.viewport = new Viewport3D(800, 600);
			
			addChild(this.viewport);
			
			this.renderer = new BasicRenderEngine();
			this.scene = new Scene3D();
			
			this.camera = new FreeCamera3D();	
			
			this.camera.zoom = 5;
			this.camera.focus = 30;
		}
		
		/**
		 * 
		 * @param	mapName
		 */
		public function loadMap(mapName:String):void
		{
			_reader = new BspReader( mapName );
			_reader.addEventListener( Event.COMPLETE, readerCompleteHandler );
		}
		
		/**
		 * Builds materials.
		 * 
		 * @param	instance The DisplayObject3D to create the materials for.
		 */ 
		private function buildMaterials(instance:DisplayObject3D):void
		{
			if(!this._reader || !this._reader.textures)
				return;
				
			_bitmapMaterials = new Array();
			instance.materials = instance.materials || new MaterialsList();
			
			for(var i:int = 0; i < this._reader.textures.length; i++)
			{
				var texture:BspTexture = this._reader.textures[i];
				if(!texture || !texture.bitmap)
					continue;
					
				var name:String = texture.name;
				var material:BitmapMaterial = new BitmapMaterial(texture.bitmap);

				if(name.indexOf("+") != -1 || name.indexOf("*") != -1)
					name = name.substr(1);
				
				material.name = name;
					
				_bitmapMaterials.push(instance.materials.addMaterial(material, name));
			}
		}
		
		/**
		 * 
		 * @param	event
		 */
		private function loop3D( event:Event ):void
		{
			if( this.map )
			{
				//this.camera.pitch(1);
				//this.camera.yaw(1);
				//this.camera.roll(1);
				this.camera.rotationZ++;
				
				this.renderer.renderScene(scene, camera, viewport);
			}
		}
		
		/**
		 * 
		 * @param	point
		 * @return
		 */
		private function findLeaf(point:Vertex3D):int
		{
			var idx:int = BspModel( this._reader.models[0] ).headnode[0];
			var pt:Number3D = new Number3D( point.x, point.y, point.z );
			
			while( idx >= 0 )
			{
				var node:BspNode = this._reader.nodes[idx] as BspNode;
				var plane:BspPlane = this._reader.planes[node.planenum];	
				var normal:Number3D = new Number3D( plane.a, plane.b, plane.c );
				var dot:Number = Number3D.dot(normal, pt) - plane.d;
				idx = dot >= 0 ? node.children[0] : node.children[1];
			}
			return -(idx+1);
		}
		
		/**
		 * 
		 */
		private function decompressVis( leaf:BspLeaf ):Array
		{
			var decompressed:Array = new Array();
			
			var lump:BspLump = this._reader.header.lumps[BspLump.LUMP_VISIBILITY] as BspLump;
			var num:int = (this._reader.leaves.length+7) >> 3;
		
			if( leaf.visofs < 0 )
			{
				while( num )
				{
					decompressed.push( 0xff );
					num--;
				}
			}
			else
			{
				var pos:uint = lump.offset + leaf.visofs;
				var data:ByteArray = this._reader.data;
				
				var out:uint = 0;
				var cnt:uint = 0;
				
				do
				{
					if( data[pos] )
					{
						out = data[pos++];
						decompressed.push( out );
						continue;
					}
					
					var c:uint = data[pos+1];
					pos += 2;
					while( c )
					{
						out = 0;
						decompressed.push( out );
						c--;
					}
					
				} while( decompressed.length < num );
			}
			return decompressed;
		}
		
		/**
		 * 
		 */
		private function makeVisible( camPos:Vertex3D ):void
		{
			_curLeaf = findLeaf( camPos );
			var leaf:BspLeaf = this._reader.leaves[_curLeaf];
			
			trace( "mins:" + leaf.mins );
			trace( "maxs:" + leaf.maxs );
			trace( "visofs:" + leaf.visofs );
			trace( "contents:" + leaf.contents );
			
			var lump:BspLump = this._reader.header.lumps[BspLump.LUMP_VISIBILITY] as BspLump;
			var num:int = (this._reader.leaves.length+7) >> 3;
			
			trace( "vis => len:" + lump.length + " num:" + num );
			
			var src:uint = lump.offset + leaf.visofs;
			var dest:uint = 0;
			
			try
			{
				var visinfo:Array = decompressVis( leaf );
				trace( "visinfo: " + visinfo.length );
				makeWorldFaces( visinfo );
			}
			catch( e:Error )
			{
				trace( "ERROR in makeWorldFaces " + e.toString() + e.getStackTrace() );
			}
		}
		
		private function makeWorldFaces( visinfo:Array ):void
		{
			var i:int, j:int, k:int;
			var vis_byte:int;
			var vis_mask:int;
			var allreadyViz:Object = new Object();
			
			this.map.geometry.vertices = new Array()
			this.map.geometry.faces = new Array();
			
			var model:BspModel = this._reader.models[0] as BspModel;
			
			var numleaves:uint = this._reader.leaves.length;
			var marked:Object = new Object();
			
			for( i = 0; i < numleaves; i++ )
			{
				var leaf:BspLeaf = this._reader.leaves[i];
				
				vis_byte = visinfo[i >> 3];
				vis_mask = 1 << (i & 7);
				
				if( vis_byte & vis_mask )
				{
					for( j = 0; j < leaf.nummarksurfaces; j++ )
						marked[leaf.firstmarksurface + j] = true;
				}
			}
			
			var surf:BspFace = this._reader.faces[model.firstface];
			var numsurfaces:uint = model.numfaces;
			
			// loop over all polygons
			for(i = 0; i < numsurfaces; i++)
			{
				if( !marked[i] ) continue;
				
				var material:MaterialObject3D;
				var tmp:Array = new Array();
				var uvs:Dictionary = new Dictionary(true);
				
				// get texture info	
				var texInfo:BspTexInfo = this._reader.tex_info[surf.texture_info];
				
				// texture axis
				var u:Number3D = new Number3D(texInfo.u_axis[0], texInfo.u_axis[1], texInfo.u_axis[2]);
				var v:Number3D = new Number3D(texInfo.v_axis[0], texInfo.v_axis[1], texInfo.v_axis[2]);
					
				// loop over the edges
				for( j = 0; j < surf.num_edges; j++ )
				{
					var idx:int = this._reader.surfedges[surf.first_edge + j];
					
					var edge_idx:int = idx < 0 ? -idx : idx;
					var edge:BspEdge = this._reader.edges[edge_idx];
					var coord:int = idx < 0 ? edge.endvertex : edge.startvertex;
					
					// get the Quake-vertex
					var pt:Array = this._reader.vertices[coord];

					// create PV3D vertex
					var vertex:Vertex3D = new Vertex3D(pt[0], pt[1], pt[2]);

					// create PV3D texcoord
					uvs[vertex] = new NumberUV(
						Number3D.dot(vertex.toNumber3D(), u) + texInfo.u_offset,
						-Number3D.dot(vertex.toNumber3D(), v) + texInfo.v_offset
					);
					
					// save vertex for triangulation
					tmp.push(vertex);
					
					// setup the polygon's material
					material = _bitmapMaterials[surf.texture_info];
				}
				
				// fix uvs
				fixUV(surf, uvs);
				
				// need to triangulate, because loop above creates polygons
				var triangles:Array = triangulate(tmp);
				
				for( k = 0; k < triangles.length; k++ )
				{
					var p0:Vertex3D = triangles[k][0] as Vertex3D;
					var p1:Vertex3D = triangles[k][1] as Vertex3D;
					var p2:Vertex3D = triangles[k][2] as Vertex3D;
					
					map.geometry.vertices.push(p0, p1, p2);
					 
					var t0:NumberUV = uvs[ p0 ];
					var t1:NumberUV = uvs[ p1 ];
					var t2:NumberUV = uvs[ p2 ];
					
					var triangle:Triangle3D = new Triangle3D(this.map, [p0, p1, p2], material, [t0, t1, t2]);
					
					map.geometry.faces.push(triangle);
				}
				
				// next polygon
				surf = this._reader.faces[model.firstface + i];
			}
			
			//map.material.oneSide = false;
			map.mergeVertices();
			map.geometry.ready = true;
			
			Papervision3D.log( "created mesh v:" + map.geometry.vertices.length + " f:" + map.geometry.faces.length );
		}
	
		/**
         * 
         * @param       face
         * @param       uvs
         */
        private function fixUV(face:BspFace, uvs:Dictionary):void
        {
        	var uv:NumberUV;
        	
            face.min_s = face.min_t = Number.MAX_VALUE;
            face.max_s = face.max_t = Number.MIN_VALUE;
            
            for each(uv in uvs)
            {
                face.min_s = Math.min(face.min_s, uv.u);
                face.min_t = Math.min(face.min_t, uv.v);
                face.max_s = Math.max(face.max_s, uv.u);
                face.max_t = Math.max(face.max_t, uv.v);
            }
            
            face.size_s = face.max_s - face.min_s;
            face.size_t = face.max_t - face.min_t;

            for each(uv in uvs)
            {
                uv.u -= face.min_s;
                uv.v -= face.min_t;
                
                uv.u /= face.size_s;
                uv.v /= face.size_t;
            }
        }
        
		/**
		 * 
		 * @param	event
		 */
		private function readerCompleteHandler( event:Event ):void
		{
			trace( "COMPLETE" );
			
			var ent:BspEntity = this._reader.entities.findEntityByClassName("info_player_start");
			
			var camPos:Vertex3D = new Vertex3D( ent.origin[0], ent.origin[1], ent.origin[2] );
			
			camera.x = camPos.x;
			camera.y = camPos.y;
			camera.z = camPos.z;
			camera.rotationX = -90;
			
			trace( "info_player_start: " + camPos.x + "," + camPos.y + "," + camPos.z  );
			
			this.map = new TriangleMesh3D(null, [], [], "q1-map");
			
			buildMaterials(this.map);
			
			makeVisible( camPos );
			
			this.scene.addChild(map);
			
			addEventListener(Event.ENTER_FRAME, loop3D);
		}
		
		/**
		 * 
		 * @param	points
		 */
		private function triangulate( points:Array ):Array
		{
			var result:Array = new Array();
			result.push( [points[0], points[1], points[2]] );
			for( var i:int = 2; i < points.length; i++ )
			{
				var j:int = (i+1) % points.length;
				result.push( [points[0], points[i], points[j]] );
			}
			return result;			
		}
		
		private var _reader:BspReader;
		
		private var _curLeaf:int;
		
		private var _bitmapMaterials:Array;
	}
}