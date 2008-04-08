package com.suite75.quake1.io.mdl.types
{
	public class MDLSkinGroup extends MDLSkin
	{
		public var nb:int;			// number of pictures in group
		public var time:Array;		// float time[nb]; time values, for each picture
	
		public function MDLSkinGroup()
		{
			super();
		}
	}
}