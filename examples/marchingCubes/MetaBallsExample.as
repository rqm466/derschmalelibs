package
{
	import com.derschmale.graphics.marchingCubes.MarchingCubesMesh;

	import com.derschmale.graphics.marchingCubes.MetaBallsMarcher;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display.TriangleCulling;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Utils3D;
	import flash.text.TextField;
	                                    
	[SWF(frameRate="60", width="800", height="476", backgroundColor="0x000000")]
	public class MetaBallsExample extends Sprite
	{
		private var _screens : Vector.<Number>;
		private var _views : Vector.<Number>;
		private var _projectionMatrix : Matrix3D;
		
		private var _container : Sprite;
		private var _metaBalls : MetaBallsMarcher;
		private var _marchingCubes : MarchingCubesMesh;

		[Embed(source="lightMap.jpg")]
		private var Texture1 : Class;

		[Embed(source="blueish.jpg")]
		private var Texture2 : Class;
		
		[Embed(source="whiteMap.jpg")]
		private var Texture3 : Class;


		private var _textureIndex : int = 0;
		private var _textures : Array = [];
		private var _currentMap : BitmapData;

		private var _count : Number = 0;

		private var _textField : TextField;

		public function MetaBallsExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;           
			stage.quality = StageQuality.LOW;

			init();
			
			addChild(new Stats());

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function init() : void
		{
			// init display list
			_container = addChild(new Sprite()) as Sprite;
			_container.x = stage.stageWidth * .5;
			_container.y = stage.stageHeight * .5;

			_textField = addChild(new TextField()) as TextField;
			_textField.textColor = 0xffffff;
			_textField.width = 200;
			_textField.x = stage.stageWidth- 220;
			_textField.y = 10;

			// init matrices and vertex buffers
			initProjection();
			_screens = new Vector.<Number>();
			_views = new Vector.<Number>();

			// init textures
			_textures = [ new Texture1().bitmapData, new Texture2().bitmapData, new Texture3().bitmapData ];
			_currentMap = _textures[0];

			// init metaballs. This one has 5 predefined points (because of PB)
			_metaBalls = new MetaBallsMarcher();
			_metaBalls.size1 = 90;
			_metaBalls.size2 = 150;
			_metaBalls.size3 = 200;
			_metaBalls.size4 = 70;
			_metaBalls.size5 = 120;

			// init marching cubes
			_marchingCubes = new MarchingCubesMesh(_metaBalls, 1100, 1100, 1000, 32, 32, 32);
			_marchingCubes.isoValue = .007;	// this kind of depends on the generator, .007 is nice for this 
			_marchingCubes.update();
			
		}

		// switch textures on click
		private function onClick(event : MouseEvent) : void
		{
			_currentMap = _textures[++_textureIndex % _textures.length];
		}

		// inits the projection matrix
		private function initProjection() : void
		{
			var transformation : Matrix3D = new Matrix3D();
			var projection : PerspectiveProjection = new PerspectiveProjection();

			transformation.identity();
			transformation.appendTranslation(0, 0, -1500);	// set "camera" position

			// prepend transformation matrix before projection matrix so we can transform & project in 1 call
			_projectionMatrix = projection.toMatrix3D();
			_projectionMatrix.prepend(transformation);
		}                             

		private function onEnterFrame(event : Event) : void
		{
			// errr... yeah. You spin me right round, baby, right round
			_metaBalls.pos1.x = Math.sin(_count/50)*300;
			_metaBalls.pos1.y = Math.sin(_count/40)*200;
			_metaBalls.pos1.z = Math.cos(_count/15)*300;
			_metaBalls.pos2.x = Math.cos(_count/30)*300;
			_metaBalls.pos2.y = Math.cos(_count/50)*300;
			_metaBalls.pos2.z = Math.cos(_count/30)*300;
			_metaBalls.pos3.x = Math.sin(_count/40)*300;
			_metaBalls.pos3.y = Math.cos(_count/20)*250;
			_metaBalls.pos3.z = Math.sin(_count/10)*250;
			_metaBalls.pos4.x = Math.sin(_count/15)*270;
			_metaBalls.pos4.y = Math.cos(_count/30)*350;
			_metaBalls.pos4.z = Math.sin(_count/28)*250;
			_metaBalls.pos5.x = -_metaBalls.pos1.x;
			_metaBalls.pos5.y = -_metaBalls.pos2.y;
			_metaBalls.pos5.z = -_metaBalls.pos3.z;

			_count += 0.8;

			// recreate the marching cube grid
			_marchingCubes.update();

			// reset buffers
			_screens.length = 0;                       
			_views.length = 0;

			// one call for all
			Utils3D.projectVectors(_projectionMatrix, _marchingCubes.vertices, _screens, _marchingCubes.uvs);

			// no sorting needed, marching cube grid guarantees correct (enough) order
			                
			// render
			_container.graphics.clear();
			_container.graphics.beginBitmapFill(_currentMap, null, false);
			_container.graphics.drawTriangles(_screens, _marchingCubes.indices, _marchingCubes.uvs, TriangleCulling.NEGATIVE);
			_container.graphics.endFill();
			
			_textField.text = "Triangles: " + (_marchingCubes.indices.length/3);
		}
	}
}
