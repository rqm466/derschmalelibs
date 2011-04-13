package
{
	import away3dlite.containers.View3D;

	import away3dlite.debug.AwayStats;
	import away3dlite.materials.BitmapMaterial;
	import away3dlite.materials.ColorMaterial;
	import away3dlite.primitives.Cube6;
	import away3dlite.primitives.Plane;

	import away3dlite.primitives.Sphere;

	import com.derschmale.away3dlite.projectionMapping.BitmapProjector;

	import com.derschmale.away3dlite.controller.HoverDragController;
	import com.derschmale.away3dlite.projectionMapping.ProjectiveTextureMaterial;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Vector3D;

	/**
	 * A demo to illustrate how Away3D Lite can be hacked to achieve more interesting shading effects, such as fake shadow mapping.
	 * This demo builds upon the ProjectiveTextureMapping demo to create shadows for convex objects.
	 *
	 * @author David Lenaerts
	 *
	 * http://www.derschmale.com
	 */
	[SWF(width=1024, height=576, frameRate=60, backgroundColor=0x000000)]
	public class ProjectiveTextureMapping extends Sprite
	{
		// shared properties of the shaders
		private const AMBIENT_COLOR : uint = 0x251410;
		private const INCANDESCENCE : Number = 10;

		// 3D rendering
		private var _view : View3D;
		private var _projector : BitmapProjector;

		// 3D models
		private var _cube : Cube6;
		private var _wall : Plane;
		private var _floor : Plane;

		// debug primitives to show the position of lamp + projective texture
		private var _lightSphere : Sphere;
		private var _lightPlane : Plane;

		// materials
		private var _floorMaterial : ProjectiveTextureMaterial;
		private var _wallMaterial : ProjectiveTextureMaterial;
		private var _cubeMaterial : ProjectiveTextureMaterial;

		// interaction/movement logic
		private var _camController : HoverDragController;
		private var _projectorDistance : Number = 500;
		private var _targetProjDistance : Number = 500;
		private var _projectorTarget : Vector3D = new Vector3D();
		private var _invertY : Vector3D = new Vector3D(0, 1, 0);

		public function ProjectiveTextureMapping()
		{
			// blur the light texture a bit, it looks better
			Assets.LIGHT_TEXTURE.applyFilter(Assets.LIGHT_TEXTURE, Assets.LIGHT_TEXTURE.rect, new Point(), new BlurFilter(5, 5, 3));

			// initialize the whole thing
			initView();
			initModels();
			initProjectorViz();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		/**
		 * Sets up the rendering components
		 */
		private function initView() : void
		{
			_view = new View3D();
			_view.x = stage.stageWidth*.5;
			_view.y = stage.stageHeight*.5;
			addChild(_view);

			_projector = new BitmapProjector(Assets.LIGHT_TEXTURE);
			_projector.focalLength = 1/Math.atan(60*Math.PI/180);	// vertical fov of 60�

			_camController = new HoverDragController(_view.camera, stage);

			addChild(new AwayStats(_view));
		}

		/**
		 * Creates all the primitives in the scene, and assigns the materials
		 */
		private function initModels() : void
		{
			// the floor
			_floorMaterial = new ProjectiveTextureMaterial(	Assets.FLOOR_DIFFUSE,
															Assets.FLOOR_POSITIONS,
															Assets.FLOOR_NORMALS,
															_projector, 30);

			_floorMaterial.ambientColor = AMBIENT_COLOR;
			_floor = new Plane(_floorMaterial, 1000, 1000);
			_floor.y = 500;
			_view.scene.addChild(_floor);

			// the opposite wall
			_wallMaterial = new ProjectiveTextureMaterial(	Assets.WALL_DIFFUSE,
															Assets.WALL_POSITIONS,
															Assets.WALL_NORMALS,
															_projector, 30);
			_wallMaterial.ambientColor = AMBIENT_COLOR;
			_wallMaterial.incandescence = INCANDESCENCE;
			_wall = new Plane(_wallMaterial, 1000, 1000, 1, 1, false);
			_wall.z = 500;
			_view.scene.addChild(_wall);

			// the center spinning cube
			_cubeMaterial = new ProjectiveTextureMaterial(	Assets.CUBE_DIFFUSE,
															Assets.CUBE_POSITIONS,
															Assets.CUBE_NORMALS,
															_projector);
			_cubeMaterial.ambientColor = AMBIENT_COLOR;
			_cubeMaterial.incandescence = INCANDESCENCE;

			_cube = new Cube6(_cubeMaterial, 200, 200, 200);
			_view.scene.addChild(_cube);
		}

		/**
		 * Initializes the debug primitives that will illustrate where the projector is
		 */
		private function initProjectorViz() : void
		{
			var fov : Number = 30;
			var h : Number = Math.sin(fov)*35;
			var w : Number = h*_projector.aspectRatio;
			_lightSphere = new Sphere(new ColorMaterial(0xffffee, .5), 3);
			_lightPlane = new Plane(new BitmapMaterial(Assets.LIGHT_TEXTURE), w, h, 1, 1, false);
			_lightPlane.bothsides = true;
			_lightPlane.scaleY = -1;
			_view.scene.addChild(_lightSphere);
			_view.scene.addChild(_lightPlane);
		}

		/**
		 * Moves the "lamp" closer or farther from the scene
		 */
		private function onMouseWheel(event : MouseEvent) : void
		{
			_targetProjDistance -= event.delta*10;
			if (_targetProjDistance < 100) _targetProjDistance = 100;
		}

		/**
		 * Updates and renders the scene
		 */
		private function onEnterFrame(event : Event) : void
		{
			// smooth projector distance to target distance
			_projectorDistance = _projectorDistance +(_targetProjDistance - _projectorDistance)*.2;

			// move projector position and aim at center
			_lightPlane.x = _lightSphere.x = _projector.x = _view.mouseX;
			_lightPlane.y = _lightSphere.y = _projector.y = _view.mouseY;
			_lightPlane.z = _lightSphere.z = _projector.z = -_projectorDistance;
			_projector.lookAt(_projectorTarget);

			// invert Y because uv is flipped, as a result, we also have to move backward to offset the plane
			_lightPlane.lookAt(_projectorTarget, _invertY);
			_lightPlane.moveBackward(35);

			// animate the cube
			_cube.rotationX += 1;
			_cube.rotationY += .9;
			_cube.rotationZ += 1.1;

			// manual texture updates for future hacking (to be continued... :) )
			_cubeMaterial.update(_cube);
			_wallMaterial.update(_wall);
			_floorMaterial.update(_floor);

			_view.render();
		}
	}
}
