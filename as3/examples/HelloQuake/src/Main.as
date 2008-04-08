package {
	import com.suite75.papervision3d.quake1.QuakeEngine;

	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	
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
		
		/**
		 * 
		 * 
		 * @param	event
		 */ 
		public override function loop3D(event:Event):void
		{
			if(_moveForward)
				this.camera.moveForward(10);
			if(_moveBackward)
				this.camera.moveBackward(10);
			if(_turnLeft)
				this.camera.yaw(-2);
			if(_turnRight)
				this.camera.yaw(2);
				
			super.loop3D(event);
		}
		
		/**
		 * 
		 * 
		 * @param	event
		 */ 
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case "W".charCodeAt():
					_moveForward = true;
					break;
				case "S".charCodeAt():
					_moveBackward = true;
					break;
				case "A".charCodeAt():
					_turnLeft = true;
					break;
				case "D".charCodeAt():
					_turnRight = true;
					break;
				default:
					break;
			}
		}
		
		/**
		 * 
		 * 
		 * @param	event
		 */ 
		private function onKeyUp(event:KeyboardEvent):void
		{
			_moveForward = _moveBackward = _turnLeft = _turnRight = false;
		}
		
		/**
		 * 
		 * 
		 * @param	event
		 */ 
		private function onMouseDown(event:MouseEvent):void
		{
			
		}
		
		/**
		 * 
		 * 
		 * @param	event
		 */ 
		private function onMouseMove(event:MouseEvent):void
		{
			
		}
		
		/**
		 * 
		 * 
		 * @param	event
		 */ 
		private function onMouseUp(event:MouseEvent):void
		{
			
		}
		
		private var _moveBackward:Boolean = false;
		private var _moveForward:Boolean = false;
		private var _turnLeft:Boolean = false;
		private var _turnRight:Boolean = false;
	}
}
