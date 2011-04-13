package
{
	import away3dlite.containers.View3D;

	import away3dlite.core.base.Mesh;
	import away3dlite.debug.AwayStats;
	import away3dlite.materials.BitmapMaterial;
	import away3dlite.materials.ColorMaterial;
	import away3dlite.primitives.Cube6;
	import away3dlite.primitives.Plane;

	import away3dlite.primitives.Sphere;

	import com.derschmale.away3dlite.projectionMapping.BitmapProjector;

	import com.derschmale.away3dlite.controller.HoverDragController;
	import com.derschmale.away3dlite.projectionMapping.ProjectiveTextureMaterial;
	import com.derschmale.away3dlite.projectionMapping.ProjectiveTextureMaterial;

	import com.derschmale.away3dlite.projectionMapping.ShadowProjector;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	/**
	 * A demo to illustrate how Away3D Lite can be hacked to achieve more interesting shading effects, such as projective texture mapping.
	 *
	 * @author David Lenaerts
	 *
	 * http://www.derschmale.com
	 */
	[SWF(width=1024, height=576, frameRate=60, backgroundColor=0x000000)]
	public class FakeShadowMapping extends Sprite
	{
		// shared properties of the shaders
		private const AMBIENT_COLOR : uint = 0x251410;
		private const INCANDESCENCE : Number = 10;

		// 3D rendering
		private var _view : View3D;
		private var _projector : ShadowProjector;

		// 3D models
		private var _cube1 : Cube6;
		private var _cube2 : Cube6;
		private var _sphere1 : Sphere;
		private var _sphere2 : Sphere;
		private var _wall : Plane;
		private var _objects : Vector.<Mesh>;

		// debug primitives to show the position of lamp + projective texture
		private var _lightSphere : Sphere;
		private var _lightPlane : Plane;

		// materials
		private var _wallMaterial : ProjectiveTextureMaterial;
		private var _cubeMaterial1 : ProjectiveTextureMaterial;
		private var _cubeMaterial2 : ProjectiveTextureMaterial;
		private var _sphereMaterial1 : ProjectiveTextureMaterial;
		private var _sphereMaterial2 : ProjectiveTextureMaterial;

		// interaction/movement logic
		private var _camController : HoverDragController;
		private var _projectorDistance : Number = 500;
		private var _targetProjDistance : Number = 500;
		private var _projectorTarget : Vector3D = new Vector3D();
		private var _invertY : Vector3D = new Vector3D(0, 1, 0);

		// keeps distances to light for each object, used for sorting
		private var _lightDistances : Dictionary;

		public function FakeShadowMapping()
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

			// use the shadow version of the texture!
			_projector = new ShadowProjector(Assets.LIGHT_TEXTURE);
			_projector.focalLength = 1/Math.atan(60*Math.PI/180);	// vertical fov of 60�

			_camController = new HoverDragController(_view.camera, stage);

			addChild(new AwayStats(_view));
		}

		/**
		 * Creates all the primitives in the scene, and assigns the materials
		 */
		private function initModels() : void
		{
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

			// spinning cubes and spheres
			_cubeMaterial1 = new ProjectiveTextureMaterial(	Assets.CUBE_DIFFUSE, Assets.CUBE_POSITIONS, Assets.CUBE_NORMALS, _projector);
			_cubeMaterial2 = new ProjectiveTextureMaterial(	Assets.CUBE_DIFFUSE, Assets.CUBE_POSITIONS, Assets.CUBE_NORMALS, _projector);
			_cubeMaterial2.ambientColor = _cubeMaterial1.ambientColor = AMBIENT_COLOR;
			_cubeMaterial2.incandescence = _cubeMaterial1.incandescence = INCANDESCENCE;

			_sphereMaterial1 = new ProjectiveTextureMaterial(	Assets.SPHERE_DIFFUSE, Assets.SPHERE_NORMALS_POSITIONS, Assets.SPHERE_NORMALS_POSITIONS, _projector);
			_sphereMaterial2 = new ProjectiveTextureMaterial(	Assets.SPHERE_DIFFUSE, Assets.SPHERE_NORMALS_POSITIONS, Assets.SPHERE_NORMALS_POSITIONS, _projector);
			_sphereMaterial2.ambientColor = _sphereMaterial1.ambientColor = AMBIENT_COLOR;
			_sphereMaterial2.incandescence = _sphereMaterial1.incandescence = INCANDESCENCE;

			_cube1 = new Cube6(_cubeMaterial1, 150, 150, 150);
			_cube1.x = -100;
			_cube1.y = 100;
			_cube1.z = -100;
			_cube2 = new Cube6(_cubeMaterial2, 150, 150, 150);
			_cube2.x = 100;
			_cube2.y = -100;
			_cube2.z = 100;
			_sphere1 = new Sphere(_sphereMaterial1, 75);
			_sphere1.x = 100;
			_sphere1.y = 100;
			_sphere1.z = -100;
			_sphere2 = new Sphere(_sphereMaterial2, 75);
			_sphere2.x = -100;
			_sphere2.y = -100;
			_sphere2.z = 100;
			_view.scene.addChild(_cube1);
			_view.scene.addChild(_cube2);
			_view.scene.addChild(_sphere1);
			_view.scene.addChild(_sphere2);

			_objects = new Vector.<Mesh>();
			_objects.push(_wall);
			_objects.push(_cube1);
			_objects.push(_cube2);
			_objects.push(_sphere1);
			_objects.push(_sphere2);

			_lightDistances = new Dictionary(true);
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

			// animate the objects
			_cube1.rotationX += 1;
			_cube1.rotationY += .9;
			_cube1.rotationZ += 1.1;
			_cube2.rotationX += .95;
			_cube2.rotationY += 1.2;
			_cube2.rotationZ += .85;
			_sphere1.rotationX += .5;
			_sphere1.rotationY += .4;
			_sphere1.rotationZ += .45;
			_sphere2.rotationX += .45;
			_sphere2.rotationY += .55;
			_sphere2.rotationZ += .33;

			updateMaterials();

			_view.render();
		}

		/**
		 * Updates the materials and draws shadows to the projection map
		 */
		private function updateMaterials() : void
		{
			var numObjects : uint = _objects.length;
			var mesh : Mesh;
			var dx : Number, dy : Number, dz : Number;
			var i : uint;

			_projector.resetBitmapData();

			// calculate the distances between all objects and the projector
			for (i = 0; i < numObjects; ++i) {
				mesh = _objects[i];
				// don't need to do sqrt, since comparison will remain intact
				dx = mesh.x - _projector.x;
				dy = mesh.y - _projector.y;
				dz = mesh.z - _projector.z;
				_lightDistances[mesh] = dx*dx + dy*dy + dz*dz;
			}

			// sort based on the distance we calculated
			_objects.sort(compareOnDistanceToLight);

			// update all the materials and draw shadows in the correct order
			for (i = 0; i < numObjects; ++i) {
				mesh = _objects[i];
				ProjectiveTextureMaterial(mesh.material).update(mesh);
				// if not the last object, draw the shadow to the light map
				if (i < numObjects - 1) _projector.drawShadows(mesh, 0x000000);
			}
		}

		/**
		 * Just a Vector sort compare function based on distance.
		 */
		private function compareOnDistanceToLight(objA : Mesh, objB : Mesh) : int
		{
			var distA : Number = _lightDistances[objA];
			var distB : Number = _lightDistances[objB];

			return 	distA < distB? -1 :
					distA > distB? 	1 :
									0;
		}
	}
}
