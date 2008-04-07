package {
	import com.suite75.papervision3d.quake1.QuakeEngine;

	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	[SWF(width='800',height='600',backgroundColor='0x000000',frameRate='10')]
	
	public class Main extends QuakeEngine
	{
		public function Main()
		{
		}
		
		protected override function init():void
		{
			super.init();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			loadMap("maps/e1m2.bsp");
		}
	}
}
