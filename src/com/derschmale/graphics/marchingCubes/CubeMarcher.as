package com.derschmale.graphics.marchingCubes
{
	import flash.display.Shader;
	import flash.display.ShaderData;
	import flash.display.ShaderJob;
	import flash.utils.ByteArray;

	/**
	 * CubeMarcher forms a base class for classes. Essentially, it simply calculates iso values for the marching cube
	 * algorithm to define whether a grid corner will be inside or outside the volume (which depends on the isoValue)
	 * 
	 * @author David Lenaerts
	 * http://www.derschmale.com
	 * 
	 */
	public class CubeMarcher
	{
		private var _gridX : Number;
		private var _gridY : Number;
		private var _gridZ : Number;
		
		protected var _vertexShader : Shader;
		protected var _shaderData : ShaderData;

		/**
		 * Creates a new CubeMarcher instance.
		 * @param kernel The Pixel Bender kernel that will be calculating iso values for the marching cube grid corners.
		 */
		public function CubeMarcher(kernel : ByteArray)
		{
			_vertexShader = new Shader(kernel);
			_shaderData = _vertexShader.data;
		}

		/**
		 * Assigns a grid to the shader. Called by MarchingCubesGrid
		 * @param grid A Vector containing the coordinates of the grid corner coordinates.
		 * @param width The width of the grid (in cells)
		 * @param height The height of the grid (in cells)
		 * @param depth The depth of the grid (in cells)
		 */
		public function setGrid(grid : Vector.<Number>, width : Number, height : Number, depth : Number) : void
		{
			_gridX = width + 1;
			_gridY = height + 1;
			_gridZ = depth + 1;
			_shaderData.grid.input = grid;
			_shaderData.grid.width = _gridX;
			_shaderData.grid.height = _gridY*_gridZ;
		}

		/**
		 * Run the shader.
		 * @param target The vector containing the iso values corresponding to each corner of the grid
		 */
		public function execute(target : Vector.<Number>) : void
		{
			new ShaderJob(_vertexShader, target, _gridX, _gridY*_gridZ).start(true);
		}
	}
}