package
{
	import away3d.Away3D;
    import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.core.managers.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import away3d.lights.*;	
	import away3d.materials.lightpickers.*;
	import away3d.materials.methods.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

    [SWF(width="480", height="640", frameRate="30", backgroundColor="#000000")]
    public class Main extends Sprite
    {
        
			// Materials
		private var cubeMaterial : TextureMaterial;

		// Objects
		private var cube1 : Mesh;
		private var cube2 : Mesh;
		private var cube3 : Mesh;
		private var cube4 : Mesh;
		private var cube5 : Mesh;
		
		private var groundMaterial:ColorMaterial;
		private var ground:Mesh;
		
		// Away3D view instances
		private var away3dView : View3D;
		
		private var stage3DProxy:Stage3DProxy;

		// Camera controllers 
		private var hoverController : HoverController;
		
		private var lastPanAngle : Number = 0;
		private var lastTiltAngle : Number = 0;
		private var lastMouseX : Number = 0;
		private var lastMouseY : Number = 0;
		private var mouseDown : Boolean;
		
		
        public function Main()
        {
			if (stage) init();
			else addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
		private function init(e:flash.events.Event = null):void 
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.showDefaultContextMenu = true;
			stage.stageFocusRect = false;
			
			var stage3DManager:Stage3DManager = Stage3DManager.getInstance(stage);
			// Create a new Stage3D proxy to contain the separate views
			stage3DProxy = stage3DManager.getFreeStage3DProxy();
			stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, init_starling);
			stage3DProxy.antiAlias = 8;
			stage3DProxy.color = 0xe3e1ed;		
			
		}
		
		private function init_starling(event : Stage3DEvent):void{
			// создание старлинга
			
			away3dView = new View3D();
			away3dView.stage3DProxy = stage3DProxy;
			away3dView.shareContext = true;

			hoverController = new HoverController(away3dView.camera, null, 45, 30, 1200, 5, 89.999);
			
			addChild(away3dView);
			
			
		   
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		  stage3DProxy.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		 
			initMaterials();
			 initLights();
			initObjects();
			
			
		}
		
		
		/**
		 * Initialise the materials
		 */
		private function initMaterials() : void {
			//Create a material for the cubes
			var cubeBmd:BitmapData = new BitmapData(128, 128, false, 0x0);
			cubeBmd.perlinNoise(7, 7, 5, 12345, true, true, 7, true);
			cubeMaterial = new TextureMaterial(new BitmapTexture(cubeBmd));
			cubeMaterial.gloss = 20;
			cubeMaterial.ambientColor = 0x808080;
			cubeMaterial.ambient = 1;
			
			groundMaterial = new ColorMaterial(0x63414c);
			groundMaterial.addMethod(new FogMethod(1000, 3000, 0xe3e1ed));
			groundMaterial.ambient = 0.25;
		}
		
		private function initObjects() : void {
			// Build the cubes for view 1
			var cG:CubeGeometry = new CubeGeometry(300, 300, 300);
			cube1 = new Mesh(cG, cubeMaterial);
			cube2 = new Mesh(cG, cubeMaterial);
			cube3 = new Mesh(cG, cubeMaterial);
			cube4 = new Mesh(cG, cubeMaterial);
			cube5 = new Mesh(cG, cubeMaterial);
			
			// Arrange them in a circle with one on the center
			cube1.x = -750; 
			cube2.z = -750;
			cube3.x = 750;
			cube4.z = 750;
			cube1.y = cube2.y = cube3.y = cube4.y = cube5.y = 150;
			
			// Add the cubes to view 1
			away3dView.scene.addChild(cube1);
			away3dView.scene.addChild(cube2);
			away3dView.scene.addChild(cube3);
			away3dView.scene.addChild(cube4);
			away3dView.scene.addChild(cube5);
			/*
			var _prefabOutput:Milling_Machine = new Milling_Machine();
			_prefabOutput.scale(3);
			_prefabOutput.x = -230;
			_prefabOutput.y = -50;
			_prefabOutput.materials[0].lightPicker = lightPicker;
			

			away3dView.scene.addChild(_prefabOutput);
			away3dView.camera.lookAt(_prefabOutput.position);
			*/
			
			
			//create the ground plane
			
			ground = new Mesh(new PlaneGeometry(50000, 50000), groundMaterial);
			ground.geometry.scaleUV(50, 50);
			//ground.y = -51;
			away3dView.scene.addChild(ground);
			
			//away3dView.scene.addChild(new WireframePlane(2500, 2500, 20, 20, 0xbbbb00, 1.5, WireframePlane.ORIENTATION_XZ));
			//away3dView.scene.addChild(new WireframeAxesGrid(10, 1000, 3, 0x0000FF, 0xFF0000, 0x00FF00));
		}
		
		
		private function initLights():void
		{
			//create a light for shadows that mimics the sun's position in the skybox
			var sunLight:DirectionalLight = new DirectionalLight(0, -1, 0.5);
			sunLight.color = 0xffffff;
			sunLight.castsShadows = true;
			sunLight.ambient = 1;
			sunLight.diffuse = 1;
			sunLight.specular = 1;
			away3dView.scene.addChild(sunLight);
			
			//create a light for ambient effect that mimics the sky
			var skyLight:PointLight = new PointLight();
			skyLight.y = 300;
			skyLight.color = 0x99AAff;
			skyLight.diffuse = 1;
			skyLight.specular = 0.5;
			skyLight.radius = 2000;
			skyLight.fallOff = 2500;
			away3dView.scene.addChild(skyLight);
			
			
			//var wireframeAxesGrid:WireframeAxesGrid = new WireframeAxesGrid(10, 1000, 3, 0x0000FF, 0xFF0000, 0x00FF00);
			//scene.addChild(wireframeAxesGrid);
			var lightPicker:StaticLightPicker = new StaticLightPicker([sunLight, skyLight]);
			
			
			var filteredShadowMapMethod:SoftShadowMapMethod = new SoftShadowMapMethod(sunLight);
			filteredShadowMapMethod.epsilon = 0.005;
			
			// apply the lighting effects to the ground material
			
			groundMaterial.lightPicker = lightPicker;
			groundMaterial.shadowMethod = filteredShadowMapMethod;
			
			cubeMaterial.lightPicker = lightPicker;
			cubeMaterial.shadowMethod = filteredShadowMapMethod;
			
		}
		/**
		 * Handle the mouse down event and remember details for hovercontroller
		 */
		
		private function onMouseDown(event : MouseEvent) : void {
			mouseDown = true;
			lastPanAngle = hoverController.panAngle;
			lastTiltAngle = hoverController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
		}

		/**
		 * Clear the mouse down flag to stop the hovercontroller
		*/
		private function onMouseUp(event : MouseEvent) : void {
			mouseDown = false; 
		}
		
		
		private function onEnterFrame(event : flash.events.Event) : void {
			
			if (mouseDown) {
				hoverController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				hoverController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			away3dView.render();
		}

    }
}