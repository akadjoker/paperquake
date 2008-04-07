package com.suite75.quake1.io
{
	import flash.utils.ByteArray;
	
	/**
	 * class BspTexture.
	 * 
	 * <p>The Mip texture header is generally followed by (width * height) * (85 / 64) bytes, 
	 * that represent the color indexes of the textures pixels, at different scales. Do not rely on that size however, 
	 * rather consider the offsets described below.</p>
	 * 
	 * <p>The pixels are accessed by offsets, with offset1 (resp. 2, 3, 4) pointing to the beginning of the 
	 * color indexes of the picture scaled by 1 (resp. 1/2, 1/4, 1/8). These offsets are relative to the 
	 * beginning of miptex_t.</p>
	 * 
	 * <p>The name of the texture is rather irrelevant, except that:</p>
	 * <ul><li>if it begins by * it will be animated like lava or water.</li>
	 * <li>if it begins by + then it will be animated with frames, and the second letter of the name will be the frame number. Those numbers begin at 0, and go up to 9 at the maximum.</li>
     * <li>if if begins with sky if will double scroll like a sky.</li>
     * <li>Beware that sky textures are made of two distinct parts.</li></ul>
     * </p>
     */ 
	public class BspTexture
	{
		public var name:String; 	// [16] Name of the texture.
	    public var width:int;		// width of picture, must be a multiple of 8
	    public var height:int;		// height of picture, must be a multiple of 8
	    public var offset1:int;		// offset to u_char Pix[width   * height]
	    public var offset2:int;		// offset to u_char Pix[width/2 * height/2]
	    public var offset4:int;		// offset to u_char Pix[width/4 * height/4]
	    public var offset8:int;		// offset to u_char Pix[width/8 * height/8]
	  	public var position:int;
	  	
	  	public function get animated():Boolean
	  	{
	  		return (this.name.substr(0, 1) == "*" || this.name.substr(0, 1) == "+");	
	  	}
	  	
	  	/**
	  	 * 
	  	 */ 
		public function BspTexture()
		{
		}
		
		public function toString():String
		{
			var s:String = this.name + " animated: " + this.animated + "\n => ";
			s += "w:" + this.width + " h:" + this.height + " mip1:" + this.offset1 + " mip2:" + this.offset2;
			s += " mip4:" + this.offset4 + " mip8:" + this.offset8;
			return s;
		}
	}
}