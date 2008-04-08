package com.suite75.papervision3d.quake1.objects
{
	import com.suite75.quake1.data.QuakePalette;
	import com.suite75.quake1.io.mdl.MDLReader;
	import com.suite75.quake1.io.mdl.types.*;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import org.papervision3d.Papervision3D;
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * Quake 1 Entity Alias Model (MDL)
	 * <p>Alias models can be used for entities, like players, objects, or monsters. 
	 * Some entities can use sprite models (that are similar in appearance to those of DOOM, though the 
	 * structure is totally different) or even maybe models similar to those of the levels.</p>
	 */ 
	public class MDL extends TriangleMesh3D
	{
		/** Whether to center the mesh on origin. */
		public var centerMesh:Boolean;
		
		/** Scale to use when loading. */
		public var loadScale:Number;
		
		/** */
		public var frames:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param	centerMesh	Center the mesh on origin?
		 * @param	loadScale	Scale
		 * @param	name		Optional name for this mesh.
		 */ 
		public function MDL(centerMesh:Boolean=true, loadScale:Number=1, name:String=null)
		{
			super(null, [], [], name);
			this.centerMesh = centerMesh;
			this.loadScale = loadScale;
		}
		
		/**
		 * Load.
		 * 
		 * @param	asset 		Url or ByteArray.
		 * @param	material	An optional material for the model.
		 */ 
		public function load(asset:*, material:MaterialObject3D=null):void
		{
			_loadMaterial = material;
			
			var mdl:MDLReader = new MDLReader();
			mdl.addEventListener(Event.COMPLETE, onParseComplete);
			mdl.load(asset);
		}
		
		/**
		 * Project
		 */ 
		public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number
		{
			if(this.frames && this.frames.length)
			{
				_curFrame = _curFrame < this.frames.length - 1 ? _curFrame + 1 : 0;
				
				this.geometry = this.frames[_curFrame].geometry;
			}
			
			if(_queuedFrames.length)
			{
				buildFrame(_mdl, _queuedFrames.shift() as MDLSimpleFrame);
			}
			return super.project(parent, renderSessionData);
		}
		
		/**
		 * Builds the mesh.
		 * 
		 * @param 	mdl
		 */ 
		private function buildMesh(mdl:MDLReader):void
		{
			var header:MDLHeader = mdl.header;
			var frame:MDLSimpleFrame = mdl.frames[0].frame;
			var i:int, j:int;
			var texture:BitmapData = buildTextureFromSkin(0, mdl);

			this.material = _loadMaterial || new BitmapMaterial(texture);
			
			var verbose:Boolean = Papervision3D.VERBOSE;
			Papervision3D.VERBOSE = !verbose;
			buildFrames(mdl);
			Papervision3D.VERBOSE = verbose;
			
			this.geometry = this.frames[0].geometry;
			this.geometry.ready = true;
			this.rotationX = 90;
			
			_curFrame = 0;
			
			trace("MDL v:" + this.geometry.vertices.length + " f:" + this.geometry.faces.length);
		}
		
		/**
		 * 
		 */ 
		private function buildFrames(mdl:MDLReader):void
		{
			var header:MDLHeader = mdl.header;
			
			this.frames = new Array();
			_queuedFrames = new Array();
			
			for(var i:int = 0; i < header.numframes; i++)
			{
				var frame:MDLSimpleFrame = mdl.frames[i].frame;
				if(i)
					_queuedFrames.push(frame);
				else
					buildFrame(mdl, frame);
			}
		}
		
		/**
		 * Builds a frame.
		 * 
		 * @param	mdl
		 * @param	frame
		 */ 
		private function buildFrame(mdl:MDLReader, frame:MDLSimpleFrame):void
		{
			var header:MDLHeader = mdl.header;
		
			var tmpMesh:TriangleMesh3D = new TriangleMesh3D(null, [], [], frame.name);	
			
			for(var i:int = 0; i < header.numtris; i++)
			{
				var tri:MDLTriangle = mdl.triangles[i];
				var verts:Array = new Array();
				var uvs:Array = new Array();
			
				for(var j:int = 0; j < 3; j++)
				{
					var fv:MDLFrameVertex = frame.vertices[ tri.vertex[j] ];	
					var v:Vertex3D = new Vertex3D();
	    		
	    			// Calculate real vertex position
	    			v.x = ((header.scale[0] * fv.packedposition[0]) + header.offsets[0]) * this.loadScale;
	    			v.y = ((header.scale[1] * fv.packedposition[1]) + header.offsets[1]) * this.loadScale;
	    			v.z = ((header.scale[2] * fv.packedposition[2]) + header.offsets[2]) * this.loadScale;
	    			
	    			verts.push(v);

					// Compute texture coordinates
					var tx:MDLTexCoord = mdl.texcoords[ tri.vertex[j] ];
					var s:Number = tx.s;
					var t:Number = tx.t;
					
					if(!tri.facesfront && tx.onseam)
						s += header.skinwidth * 0.5; // Backface
						
					// Scale s and t to range from 0.0 to 1.0
	    			s = (s + 0.5) / header.skinwidth;
	    			t = (t + 0.5) / header.skinheight;
	    			
	    			uvs.push(new NumberUV(s, 1-t));
  				 }
  				 
  				tmpMesh.geometry.vertices = tmpMesh.geometry.vertices.concat(verts);
				tmpMesh.geometry.faces.push(new Triangle3D(tmpMesh, verts, this.material, uvs));
			}
			
			tmpMesh.mergeVertices();
			
			if(this.centerMesh)
			{
				var bbox:Object = tmpMesh.boundingBox();
				var dx:Number = -bbox.min.x-(bbox.size.x/2); 
				var dy:Number = -bbox.min.y-(bbox.size.y/2); 
				var dz:Number = -bbox.min.z-(bbox.size.z/2); 
				tmpMesh.transformVertices(Matrix3D.translationMatrix(dx, dy, 0));
			}
			
			this.frames.push(tmpMesh);
		}
		
		/**
		 * Make a texture given a skin index 'n'.
		 * 
		 * @param	n	skin index
		 * @param	mdl
		 */ 
		private function buildTextureFromSkin(n:int, mdl:MDLReader):BitmapData
		{
			var bitmap:BitmapData = new BitmapData(mdl.header.skinwidth, mdl.header.skinheight, false, 0xffffff);
			var colormap:Array = QuakePalette.rgb;
			var skin:MDLSkin = mdl.skins[n];
			var index:int = 0;
			
			for(var y:int = 0; y < mdl.header.skinheight; y++)
			{
				for(var x:int = 0; x < mdl.header.skinwidth; x++)
				{
					var rgb:Array = colormap[ skin.data[index++] ];
					var color:int = rgb[0] << 16 | rgb[1] << 8 | rgb[2];
					bitmap.setPixel(x, y, color);	
				}
			} 
			return bitmap;	
		}
		
		/**
		 * Fired when the mdl parse is complete.
		 * 
		 * @param 	event
		 */ 	
		private function onParseComplete(event:Event):void
		{
			_mdl = event.target as MDLReader;
			buildMesh(_mdl);	
		}
		
		private var _loadMaterial:MaterialObject3D;
		
		private var _curFrame:int = 0;
		
		private var _queuedFrames:Array;
		
		private var _parsing:Boolean;
		
		private var _mdl:MDLReader;
	}
}