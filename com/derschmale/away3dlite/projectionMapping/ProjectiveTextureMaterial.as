package com.derschmale.away3dlite.projectionMapping
{
	import away3dlite.arcane;
	import away3dlite.core.base.Mesh;
	import away3dlite.materials.BitmapMaterial;

	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	use namespace arcane;

	public class ProjectiveTextureMaterial extends BitmapMaterial
	{
		private var _renderBitmap : BitmapData;
		private var _positionMap : BitmapData;
		private var _normalMap : BitmapData;
		private var _shader : Shader;
		private var _shaderData : Object;
		private var _projector : BitmapProjector;
		private var _forceScale : Number = 0;
		private var _ambientColor : uint = 0;

		private var _positionMatrices : Dictionary;
		
		[Embed(source="../../../../pb/projectionMapping/ProjectionMapper.pbj", mimeType="application/octet-stream")]
		private var Kernel : Class;

		private static var _calcMatrix : Matrix3D = new Matrix3D();

		/**
		 * Creates a new ProjectiveTextureMaterial
		 * @param bitmap The bitmapData object to be used as the diffuse texture
		 * @param positionMap The bitmapData object to be used as the position map. A position map indicates the position for every texel in absolute normalized object space (0-1)
		 * @param normalMap The bitmapData object to be used as the normal map.
		 * @param projector The projector to be used for projection mappping
		 * @param scaleIfNil The scale to use on the position map if the size of the dimension (fe: maxY-minY for a plane) is 0. This can be used to fake height on a plane.
		 */
		public function ProjectiveTextureMaterial(bitmap : BitmapData, positionMap : BitmapData, normalMap : BitmapData, projector : BitmapProjector, scaleIfNil : Number = 1)
		{
			_forceScale = scaleIfNil;
			_positionMatrices = new Dictionary(true);
			_renderBitmap = bitmap.clone();
			_positionMap = positionMap;
			_normalMap = normalMap;
			_projector = projector;
			_shader = new Shader(new Kernel());
			_shaderData = _shader.data;
			_shaderData.texture.input = bitmap;
			_shaderData.projective.input = _projector.bitmap;
			_shaderData.positionMap.input = positionMap;
			_shaderData.normalMap.input = normalMap;
			_shaderData.incandescence.value[0] = 7;
			super(bitmap);
			smooth = true;
		}

		/**
		 * The amount by which the diffuse lighting is multiplied, to create a more incandescent look while not over-illuminating the scene
		 */
		public function get incandescence() : Number
		{
			return _shaderData.incandescence.value[0];
		}

		public function set incandescence(value : Number) : void
		{
			_shaderData.incandescence.value[0] = value;
		}

		/**
		 * The ambient lighting (indirect global reflected light, ie a minimum amount of light) that hits the surface
		 */
		public function get ambientColor() : uint
		{
			return _ambientColor;
		}

		public function set ambientColor(value : uint) : void
		{
			_ambientColor = value;
			_shaderData.ambient.value = [	((_ambientColor >> 16) & 0xff)/255,
											((_ambientColor >> 8) & 0xff)/255,
											(_ambientColor & 0xff)/255 ];
		}

		/**
		 * @inheritDoc
		 */
		override public function set bitmap(val : BitmapData) : void
		{
			super.bitmap = val;
			if (_renderBitmap) _renderBitmap.dispose();
			_renderBitmap = val.clone();
		}

		/**
		 * Update the material for the given mesh. This needs to be done manually since we'll use this to hack some more later on.
		 * @param mesh The mesh for which to update the material
		 */
		public function update(mesh:Mesh):void
		{
			var raw : Vector.<Number>;
			var lightPos : Vector3D;
			var posMatrix : Matrix3D = getPositionMatrix(mesh);
			var meshTransform : Matrix3D = mesh.transform.matrix3D;

			// calculate the whole model view projection matrix for the object -> light texture projection
			_calcMatrix.identity();
			_calcMatrix.append(posMatrix);
			_calcMatrix.append(meshTransform);
			_calcMatrix.append(_projector.viewProjectionMatrix);

			raw = _calcMatrix.rawData;

			_shaderData.projectionMatrix.value = [ 	raw[0], raw[1], raw[2], raw[3],
													raw[4], raw[5], raw[6], raw[7],
													raw[8], raw[9], raw[10], raw[11],
													raw[12], raw[13], raw[14], raw[15]
												];

			_shaderData.halfMapSize.value = [ _projector.bitmap.width*.5, _projector.bitmap.height*.5 ];

			// calculate the lights position in POSITION MAP space! This prevents us from having to transform
			// the position map coords to a different space for every texel
			_calcMatrix.identity();
			_calcMatrix.append(posMatrix);
			_calcMatrix.append(meshTransform);
			_calcMatrix.invert();

			lightPos = _calcMatrix.transformVector(_projector.position);

			_shaderData.lightPos.value = [ lightPos.x, lightPos.y, lightPos.z ];

			// execute the shader
			new ShaderJob(_shader, _renderBitmap).start(true);
			_graphicsBitmapFill.bitmapData = _renderBitmap;
		}

		/**
		 * Generates a matrix that simply maps position map values (0, 0, 0) - (1, 1, 1) to object space values (minX, minY, minZ) - (maxX, maxY, maxZ)
		 * @param mesh The mesh for which to generate the position map
		 * @return A reference to the position map matrix
		 */
		private function getPositionMatrix(mesh : Mesh) : Matrix3D
		{
			var matrix : Matrix3D;
			var minX : Number, minY : Number, minZ : Number;
			var maxX : Number, maxY : Number, maxZ : Number;
			var vertices : Vector.<Number>;
			var i : int, len : int;
			var c : Number;

			if (_positionMatrices[mesh]) return _positionMatrices[mesh];

			// get bounds of mesh
			minX = Number.POSITIVE_INFINITY; minY = Number.POSITIVE_INFINITY; minZ = Number.POSITIVE_INFINITY;
			maxX = Number.NEGATIVE_INFINITY; maxY = Number.NEGATIVE_INFINITY; maxZ = Number.NEGATIVE_INFINITY;
			vertices = mesh.vertices;
			len = vertices.length;

			do {
				c = vertices[i++];
				if (c < minX) minX = c;
				if (c > maxX) maxX = c;
				c = vertices[i++];
				if (c < minY) minY = c;
				if (c > maxY) maxY = c;
				c = vertices[i++];
				if (c < minZ) minZ = c;
				if (c > maxZ) maxZ = c;
			} while (i < len);
			
			_positionMatrices[mesh] = matrix = new Matrix3D();

			// create a matrix that maps [0, 1] to [min, max]
			matrix.identity();
			var dx : Number = maxX - minX;
			var dy : Number = maxY - minY;
			var dz : Number = maxZ - minZ;
			// if almost infinitely thin, fake a thickness if forceScale is provided (can be used to give a plane some fake height displacement in the projection)
			if (dx < 0.1) dx = _forceScale;
			if (dy < 0.1) dy = _forceScale;
			if (dz < 0.1) dz = _forceScale;
			matrix.appendScale(dx, dy, dz);
			matrix.appendTranslation(minX, minY, minZ);

			return matrix;
		}
	}
}