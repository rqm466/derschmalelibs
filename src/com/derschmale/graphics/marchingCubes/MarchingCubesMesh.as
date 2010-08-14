package com.derschmale.graphics.marchingCubes
{
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.ShaderPrecision;
	import flash.geom.Vector3D;

	/**
	 * MarchingCubesMesh builds meshes based on isosurfaces using the marching cubes algorithm. It'll only end up
	 * vertices, with (normal-based) uvs, and indices, leaving any drawing up to the programme.
	 *
	 * If someone finds my keys in this code, let me know. They must be here somewhere.
	 *
	 * @author David Lenaerts
	 * http://www.derschmale.com
	 */
	public class MarchingCubesMesh
	{
		private var _gridX : int;
		private var _gridY : int;
		private var _gridZ : int;
		private var _cellWidth : Number;
		private var _cellHeight : Number;
		private var _cellDepth : Number;
		private var _width : Number;
		private var _height : Number;
		private var _depth : Number;
		private var _grid : Vector.<Number>;
		private var _isoValues : Vector.<Number>;
		private var _patterns : Vector.<Number>;	// actually contains ints
		private var _vertices : Vector.<Number>;
		private var _uvs : Vector.<Number>;
		private var _indices : Vector.<int>;
		private var _triLookUp : Vector.<MarchingCubeCase>;
		private var _marcher : CubeMarcher;
		private var _cornersYZ : Number;

		[Embed(source="/pb/marchingCubes/MarchingCubePatterns.pbj", mimeType="application/octet-stream")]
		private var PatternKernel : Class;

		[Embed(source="/pb/marchingCubes/GridNormals.pbj", mimeType="application/octet-stream")]
		private var NormalKernel : Class;

		[Embed(source="/pb/marchingCubes/CalculateUVs.pbj", mimeType="application/octet-stream")]
		private var UVKernel : Class;

		private var _patternShader : Shader;
		private var _normalShader : Shader;
		private var _uvShader : Shader;
		private var _cornerNormals : Vector.<Number>;
		private var _isoValue : Number;
		private var _cornersX : Number;
		private var _cornersY : Number;
		private var _cornersZ : Number;

		/**
		 * Create a new MarchingCubesMesh instance.
		 * @param marcher A concrete instance extending CubeMarcher.
		 * @param width The width of the grid boundaries
		 * @param height The height of the grid boundaries
		 * @param depth The depth of the grid boundaries
		 * @param gridW The amount of grid cells along the X-axis
		 * @param gridH The amount of grid cells along the Y-axis
		 * @param gridD The amount of grid cells along the Z-axis
		 */
		public function MarchingCubesMesh(marcher : CubeMarcher, width : Number, height : Number, depth : Number, gridW : int, gridH : int, gridD : int)
		{
			_triLookUp = MarchingCubeLookup.init();
			_marcher = marcher;
			_width = width;
			_height = height;
			_depth = depth;
			_cornersX = (_gridX = gridW) + 1;
			_cornersY = (_gridY = gridH) + 1;
			_cornersZ = (_gridZ = gridD) + 1;
			_cornersYZ = _cornersY*_cornersZ;
			init();
			isoValue = .5;
		}

		/**
		 * The threshold value, which will be the dividing value between inside and outside
		 */
		public function get isoValue() : Number
		{
			return _isoValue;
		}

		public function set isoValue(value : Number) : void
		{
			_isoValue = value;
			_patternShader.data.isoValue.value = [ value ];
		}

		/**
		 * The vertices generated with the last call to update
		 */
		public function get vertices() : Vector.<Number>
		{
			return _vertices;
		}

		/**
		 * The uvs generated with the last call to update. The uv values are actually based on the normals, so
		 * it's easy to use fake environment map lighting.
		 */
		public function get uvs() : Vector.<Number>
		{
			return _uvs;
		}

		/**
		 * The vertex indices for the faces.
		 */
		public function get indices() : Vector.<int>
		{
			return _indices;
		}


		/**
		 * Update the mesh
		 */
		public function update() : void
		{
			_vertices.length = 0;
			_indices.length = 0;
			_uvs.length = 0;
			_patterns.length = 0;
			_isoValues.length = 0;
			_cornerNormals.length = 0;
			_marcher.execute(_isoValues);
			new ShaderJob(_patternShader, _patterns, _gridX, _gridY*_gridZ).start(true);
			new ShaderJob(_normalShader, _cornerNormals, _cornersX, _cornersYZ).start(true);

			buildTriangles();

			if (_vertices.length > 0) updateUVs();
		}

		/**
		 * Create stuff. Kinda icky.
		 */
		private function init() : void
		{
			_vertices = new Vector.<Number>();
			_cornerNormals = new Vector.<Number>();
			_uvs = new Vector.<Number>();
			_indices = new Vector.<int>();
			_isoValues = new Vector.<Number>();
			_patterns = new Vector.<Number>();
			_patternShader = new Shader(new PatternKernel());
			_patternShader.precisionHint = ShaderPrecision.FULL;
			_normalShader = new Shader(new NormalKernel());
			_uvShader = new Shader(new UVKernel());
			_uvShader.data.cornerNormals.input = _cornerNormals;
			_uvShader.data.size.value = [_width, _height, _depth ];
			_uvShader.data.ratio.value = [ _cornersX/_width, _cornersY/_height, _cornersZ/_depth ];
			_patternShader.data.gridRes.value = [ _gridX, _gridY, _gridZ ];
			_uvShader.data.cornerRes.value = _normalShader.data.gridRes.value = _patternShader.data.cornerRes.value = [ _cornersX, _cornersY, _cornersZ ];
			_grid = new Vector.<Number>(_cornersX*_cornersYZ*3, true);
			_normalShader.data.insides.input = _patternShader.data.cornerStates.input = _isoValues;
			_uvShader.data.cornerNormals.width = _normalShader.data.insides.width = _patternShader.data.cornerStates.width = _cornersX;
			_uvShader.data.cornerNormals.height = _normalShader.data.insides.height = _patternShader.data.cornerStates.height = _cornersYZ;
			buildGrid();
		}

		/**
		 * Generates uvs for the coordinates
		 */
		private function updateUVs() : void
		{
			var len : int = _vertices.length; 	// /20 (dim) /3
			var w : int = Math.ceil(len/480); 	// /20 (dim) /3
			_vertices.length = w*480;	// add unused vertices if needed (to complete 20 height)
			_uvShader.data.vertices.input = _vertices;
			_uvShader.data.vertices.width = w;
			_uvShader.data.vertices.height = 160;
			new ShaderJob(_uvShader, _uvs, w, 160).start(true);
		}

		/**
		 * Create triangles based on the case presets.
		 */
		private function buildTriangles() : void
		{
			var len : int = _patterns.length;
			var pat : uint;
			var x : int, y : int, z : int;
			var data : MarchingCubeCase;
			var sourceVertices : Vector.<Number>;
			var sourceIndices : Vector.<int>;
			var k : int;
			var hw : Number = _width*.5;
			var hh : Number = _height*.5;
			var hd : Number = _depth*.5;
			var sourceLen : int;
			var numVertices : int;
			var numCoords : int;
			var numIndices : int;
			var cw : Number = _cellWidth, ch : Number = _cellHeight, cd : Number = _cellDepth;
			var verts : Vector.<Number> = _vertices;
			var inds : Vector.<int> = _indices;
			var v : Vector3D = new Vector3D();	// recycling this for interpolation

			for (var i : int = 0; i < len; i += 3) {
				pat = uint(_patterns[i]);
				if (pat != 0 && pat != 0xff) {
					data = _triLookUp[pat];

					sourceVertices = data.vertices;
					sourceIndices = data.indices;

					// BUILD TRIANGLES

					k = 0;
					sourceLen = data.verticesLength;
					while (k < sourceLen) {
						// damn, needed a method call after all 
						interpolatePosition(x, y, z, sourceVertices[k++], sourceVertices[k++], sourceVertices[k++], v);
						verts[numCoords++] = (v.x + x)*cw - hw;
						verts[numCoords++] = (v.y + y)*ch - hh;
						verts[numCoords++] = (v.z + z)*cd - hd;
					}

					sourceLen = data.numIndices;

					k = 0;
					while (k < sourceLen) {
						inds[numIndices++] = sourceIndices[k++] + numVertices;
						inds[numIndices++] = sourceIndices[k++] + numVertices;
						inds[numIndices++] = sourceIndices[k++] + numVertices;
					}

					numVertices += data.numVertices;
				}

				if (++x == _gridX) {
					x = 0;
					if (++y == _gridY) {
						y = 0;
						++z;
					}
				}
			}
		}

		/**
		 * Smooths out the otherwise cubey appearance by interpolating the position over the iso values
		 */
		private function interpolatePosition(x : int, y : int, z : int, vx : Number, vy : Number, vz: Number, vector : Vector3D) : void
		{
			if (vx != 0 && vy != 0 && vz != 0) {
				vector.x = vx;
				vector.y = vy;
				vector.z = vz;
				return;
			}

			var v1 : Number;
			var v2 : Number;
			var offs : int;
			var d : Number;
			var n : Number;

			vx += .5;
			vy += .5;
			vz += .5;


			if (vx == .5) {
				offs = (x + (y + vy + (z + vz)*_cornersY)*_cornersX)*3;
				v1 = _isoValues[offs];
				v2 = _isoValues[offs+3];
				
				// Remember kids: p = p1 + (isovalue - v1) (p2 - p1) / (v2 - v1)

				vector.y = vy-.5;
				vector.z = vz-.5;

				d = _isoValue - v1;
				if (d > -0.00001 && d < 0.00001) {
					vector.x = -.5;
					return;
				}
				d = _isoValue - v2;
				if (d > -0.00001 && d < 0.00001) {
					vector.x = .5;
					return;
				}
				d = v2 - v1;
				if (d > -0.00001 && d < 0.00001) {
					vector.x = -.5;
					return;
				}
				n = (_isoValue - v1)/d - .5;
				vector.x = 	n > .5 ? .5 :
							n < -.5 ? -.5 :
							n;

				return;
			}

			if (vy == .5) {
				offs = (x + vx + (y + (z + vz)*_cornersY)*_cornersX)*3;
				v1 = _isoValues[offs];
				v2 = _isoValues[offs+_cornersX*3];
				//P = P1 + (isovalue - V1) (P2 - P1) / (V2 - V1)
				vector.x = vx-.5;
				vector.z = vz-.5;

				d = _isoValue - v1;
				if (d > -0.00001 && d < 0.00001) {
					vector.y = -.5;
					return;
				}
				d = _isoValue - v2;
				if (d > -0.0001 && d < 0.00001) {
					vector.y = .5;
					return;
				}
				d = v2 - v1;
				if (d > -0.00001 && d < 0.00001) {
					vector.y = -.5;
					return;
				}
				n = (_isoValue - v1)/d - .5;
				vector.y = 	n > .5 ? .5 :
							n < -.5 ? -.5 :
							n;
				return;
			}
			if (vz == .5) {
				offs = (x + vx + (y + vy + z*_cornersY)*_cornersX)*3;
				v1 = _isoValues[offs];
				v2 = _isoValues[offs+_cornersX*_cornersY*3];
				//P = P1 + (isovalue - V1) (P2 - P1) / (V2 - V1)
				vector.x = vx-.5;
				vector.y = vy-.5;

				d = _isoValue - v1;
				if (d > -0.00001 && d < 0.00001) {
					vector.z = -.5;
					return;
				}
				d = _isoValue - v2;
				if (d > -0.00001 && d < 0.00001) {
					vector.z = .5;
					return;
				}
				d = v2 - v1;
				if (d > -0.00001 && d < 0.00001) {
					vector.z = -.5;
					return;
				}
				n = (_isoValue - v1)/d - .5;
				vector.z = 	n > .5 ? .5 :
							n < -.5 ? -.5 :
							n;
				return;
			}           
			vector.x = vx-.5;
			vector.y = vy-.5;
			vector.z = vz-.5;
		}

		/**
		 * Initializes the grid corner positions
		 */
		private function buildGrid() : void
		{
			var i : int;
			var len : int = _grid.length;
			var xb : int = _cornersX, yb : int = _cornersY;
			var xi : int, yi : int;
			var sx : Number = -_width*.5, sy : Number = -_height*.5, sz : Number = -_depth*.5;
			var x : Number = sx, y : Number = sy, z : Number = sz;

			_cellWidth =  _width/_gridX;
			_cellHeight = _height/_gridY;
			_cellDepth = _depth/_gridZ;

			do {
				_grid[i++] = x;
				_grid[i++] = y;
				_grid[i++] = z;

				if (++xi == xb) {
					xi = 0;
					x = sx;

					if (++yi == yb) {
						yi = 0;
						y = sy;
						z += _cellDepth;
					}
					else y += _cellHeight;
				}
				else x += _cellWidth;

			} while(i < len);

			_marcher.setGrid(_grid, _gridX, _gridY, _gridZ);
		}
	}
}