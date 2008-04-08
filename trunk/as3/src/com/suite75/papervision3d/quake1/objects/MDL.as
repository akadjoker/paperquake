package com.suite75.papervision3d.quake1.objects
{
	import com.suite75.quake1.data.QuakePalette;
	import com.suite75.quake1.io.mdl.MDLReader;
	import com.suite75.quake1.io.mdl.types.*;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import org.papervision3d.core.geom.TriangleMesh3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.math.NumberUV;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.special.CompositeMaterial;
	import org.papervision3d.objects.special.UCS;
	
	/**
	 * Quake 1 Entity Alias Model (MDL)
	 * <p>Alias models can be used for entities, like players, objects, or monsters. 
	 * Some entities can use sprite models (that are similar in appearance to those of DOOM, though the 
	 * structure is totally different) or even maybe models similar to those of the levels.</p>
	 */ 
	public class MDL extends TriangleMesh3D
	{
		/**
		 * Constructor.
		 * 
		 * @param	name	An optional name for this mesh.
		 */ 
		public function MDL(name:String=null)
		{
			super(null, [], [], name);
		}
		
		/**
		 * Load.
		 * 
		 * @param	asset url or a ByteArray
		 */ 
		public function load(asset:*):void
		{
			var mdl:MDLReader = new MDLReader();
			mdl.addEventListener(Event.COMPLETE, onParseComplete);
			mdl.load(asset);
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
			
			this.material = new CompositeMaterial();
			CompositeMaterial(this.material).addMaterial(new BitmapMaterial(texture));
			//CompositeMaterial(this.material).addMaterial(new WireframeMaterial());
			
			this.geometry.vertices = new Array();
			this.geometry.faces = new Array();
			
			for(i = 0; i < header.numtris; i++)
			{
				var tri:MDLTriangle = mdl.triangles[i];
				var verts:Array = new Array();
				var uvs:Array = new Array();
				
				for(j = 0; j < 3; j++)
				{
					var fv:MDLFrameVertex = frame.vertices[ tri.vertex[j] ];	
					var v:Vertex3D = new Vertex3D();
	    		
	    			// Calculate real vertex position
	    			v.x = (header.scale[0] * fv.packedposition[0]) + header.offsets[0];
	    			v.y = (header.scale[1] * fv.packedposition[1]) + header.offsets[1];
	    			v.z = (header.scale[2] * fv.packedposition[2]) + header.offsets[2];
	    			
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
				
				this.geometry.vertices = this.geometry.vertices.concat(verts);
				this.geometry.faces.push(new Triangle3D(this, verts, this.material, uvs));
			}
			
			this.mergeVertices();
			this.geometry.ready = true;
			this.rotationX = 90;

			trace("MDL v:" + this.geometry.vertices.length + " f:" + this.geometry.faces.length);
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
			buildMesh(event.target as MDLReader);	
		}
	}
}