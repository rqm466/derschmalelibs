package com.derschmale.graphics.marchingCubes
{
	import flash.display.ShaderPrecision;
	import flash.geom.Vector3D;

	/**
	 * A cube marcher for meta balls. This example has 5 prebuilt metaballs, since it's using PB
	 */
	public class MetaBallsMarcher extends CubeMarcher
	{
		[Embed(source="/pb/Metaballs.pbj", mimeType="application/octet-stream")]
		private var Kernel : Class;

		private var _pos1 : Vector3D;
		private var _pos2 : Vector3D;
		private var _pos3 : Vector3D;
		private var _pos4 : Vector3D;
		private var _pos5 : Vector3D;
		private var _size1 : Number = 200;
		private var _size2 : Number = 200;
		private var _size3 : Number = 200;
		private var _size4 : Number = 200;
		private var _size5 : Number = 200;

		public function MetaBallsMarcher()
		{
			super(new Kernel());
			_pos1 = new Vector3D();
			_pos2 = new Vector3D();
			_pos3 = new Vector3D();
			_pos4 = new Vector3D();
			_pos5 = new Vector3D();

			// meh :)
			_vertexShader.precisionHint = ShaderPrecision.FAST;
		}

		/**
		 * Size of metaball nr 1
		 */
		public function get size1() : Number
		{
			return _size1;
		}

		public function set size1(value : Number) : void
		{
			_size1 = value;
		}

		/**
		 * Size of metaball nr 2
		 */
		public function get size2() : Number
		{
			return _size2;
		}

		public function set size2(value : Number) : void
		{
			_size2 = value;
		}

		/**
		 * Size of metaball nr 3
		 */
		public function get size3() : Number
		{
			return _size3;
		}

		public function set size3(value : Number) : void
		{
			_size3 = value;
		}

		/**
		 * Size of metaball nr 4
		 */
		public function get size4() : Number
		{
			return _size4;
		}

		public function set size4(value : Number) : void
		{
			_size4 = value;
		}

		/**
		 * The amount of breads to be ordered from the bakery next door.
		 */
		public function get size5() : Number
		{
			return _size5;
		}

		public function set size5(value : Number) : void
		{
			_size5 = value;
		}

		/**
		 * Position of metaball nr 1
		 */
		public function get pos1() : Vector3D
		{
			return _pos1;
		}

		public function set pos1(value : Vector3D) : void
		{
			_pos1 = value;
		}

		/**
		 * Position of metaball nr 2
		 */
		public function get pos2() : Vector3D
		{
			return _pos2;
		}

		public function set pos2(value : Vector3D) : void
		{
			_pos2 = value;
		}

		/**
		 * Position of metaball nr 3
		 */
		public function get pos3() : Vector3D
		{
			return _pos3;
		}

		public function set pos3(value : Vector3D) : void
		{
			_pos3 = value;
		}

		/**
		 * Position of metaball nr 4
		 */
		public function get pos4() : Vector3D
		{
			return _pos4;
		}

		public function set pos4(value : Vector3D) : void
		{
			_pos4 = value;
		}

		/**
		 * Position of your mom!
		 */
		public function get pos5() : Vector3D
		{
			return _pos5;
		}

		public function set pos5(value : Vector3D) : void
		{
			_pos5 = value;
		}

		/**
		 * @inheritDoc
		 */
		override public function execute(target : Vector.<Number>) : void
		{
			_shaderData.position1.value = [ _pos1.x, _pos1.y, _pos1.z ];
			_shaderData.position2.value = [ _pos2.x, _pos2.y, _pos2.z ];
			_shaderData.position3.value = [ _pos3.x, _pos3.y, _pos3.z ];
			_shaderData.position4.value = [ _pos4.x, _pos4.y, _pos4.z ];
			_shaderData.position5.value = [ _pos5.x, _pos5.y, _pos5.z ];
			// sneaking these in together
			_shaderData.size1.value = [ _size1, _size2, _size3 ];
			_shaderData.size2.value = [ _size4, _size5 ];
			super.execute(target);
		}
	}
}