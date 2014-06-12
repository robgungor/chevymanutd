package com.oddcast.mmo
{	
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.Viewport3D;
	import flash.events.MouseEvent;

	public class InteractiveScene3d extends BasicView
	{				
		public function InteractiveScene3d(viewportWidth:Number=640, viewportHeight:Number=320, scaleToStage:Boolean=true, interactive:Boolean=false, cameraType:String="CAMERA3D")
		{
			super(viewportWidth, viewportHeight, scaleToStage, interactive, cameraType);
			//temp solution to draggin probelm?
			/*
			viewport.interactiveSceneManager.virtualMouse.disableEvent(MouseEvent.MOUSE_DOWN);
			viewport.interactiveSceneManager.virtualMouse.disableEvent(MouseEvent.MOUSE_MOVE);
			viewport.interactiveSceneManager.virtualMouse.disableEvent(MouseEvent.MOUSE_UP);
			*/ 
			
			//flvPlayer = new SwfVideoPlayer(false);
			//flvPlayer.green.addEventListener(MouseEvent.CLICK,clicked);
			//flvPlayer.playMovie("test_vid.flv");
			//flvPlayer.width = 640;
			//flvPlayer.height = 480;
			//var material:MovieMaterial = new MovieMaterial(flvPlayer);
			//material.animated = true;
			//material.interactive = true;
			//material.smooth = true;			
			//material.doubleSided = true;
			//material.allowAutoResize = true;			
			
			//plane = new Plane(material,800,600);						
			//scene.addChild(plane);			
			//startRendering();
		}
		
		public function doRender():void
		{
			renderer.renderScene(scene,_camera,viewport); 
		}
		
		public function getCamera():*
		{			
			return this._camera;
		}
		
		public function getViewport():Viewport3D
		{
			return this.viewport;
		}
		/*		
		override protected function onRenderTick(event:Event=null):void
		{
			//plane.yaw(1);
			//renderer.renderScene(scene,camera,viewport);
		}
		*/
		
	}
}