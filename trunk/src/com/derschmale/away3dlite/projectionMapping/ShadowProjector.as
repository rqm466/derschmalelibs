package com.derschmale.away3dlite.projectionMapping
{
	import away3dlite.arcane;
	import away3dlite.core.base.Face;
	import away3dlite.core.base.Mesh;

	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.TriangleCulling;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Utils3D;
	import flash.utils.Dictionary;

	use namespace arcane;

	/**
	 * Augments BitmapProjector with shadow casting functionality
	 */
	public class ShadowProjector extends BitmapProjector
	{
		private var _sourceBitmap : BitmapData;
		private var _origin : Point;
		private var _drawSprite : Sprite;
		private var _projectedVerts : Vector.<Number>;
		private var _indices : Dictionary;
		private var _drawMatrix : Matrix;

		/**
		 * Create a BitmapProjector object
		 *
		 * @param bitmap The texture to be used as the light's texture
		 */
		public function ShadowProjector(bitmap : BitmapData)
		{
			_sourceBitmap = bitmap;
			_origin = new Point();
			_projectedVerts = new Vector.<Number>();
			_drawSprite = new Sprite();
			_indices = new Dictionary(true);
			_drawMatrix = new Matrix();
			_drawMatrix.identity();
			_drawMatrix.translate(1, 1);
			_drawMatrix.scale(bitmap.width*.5, bitmap.height*.5);

			super(Assets.LIGHT_TEXTURE.clone());
		}

		/**
		 * Clears all shadows from the light texture.
		 */
		public function resetBitmapData() : void
		{
			bitmap.copyPixels(Assets.LIGHT_TEXTURE, _sourceBitmap.rect, _origin);
		}

		/**
		 * Draws a mesh as a shadow to the projection map.
		 * @param mesh The mesh casting the shadow.
		 * @param color The colour of the shadow.
		 */
		public function drawShadows(mesh : Mesh, color : int = 0x000000) : void
		{
			var graphics : Graphics = _drawSprite.graphics;
			var indices : Vector.<int>;

			// projection matrix that projects from local object space to the projector's texture space
			var matrix : Matrix3D = mesh.sceneMatrix3D.clone();
			matrix.append(viewProjectionMatrix);

			// if face indices weren't stored yet, need to generate them
			if (!_indices[mesh]) initIndices(mesh);
			indices = _indices[mesh];

			// shadow is just the object projected unto the texture. Just passing uvts since we have to...
			Utils3D.projectVectors(matrix, mesh.vertices, _projectedVerts, mesh._uvtData);

			// draw to the texture
			graphics.clear();
			graphics.beginFill(color);
			graphics.drawTriangles(_projectedVerts, indices, null, TriangleCulling.NEGATIVE);
			graphics.endFill();

			bitmap.draw(_drawSprite, _drawMatrix);
		}

		/**
		 * Creates the indices for a mesh based on the faces.
		 * @param mesh
		 */
		private function initIndices(mesh : Mesh) : void
		{
			var faces : Vector.<Face> = mesh.faces;
			var faceLen : int = faces.length;
			var face : Face;
			var j : int;
			var realIndices : Vector.<int> = new Vector.<int>(mesh._indicesTotal, true);

			for (var i : int = 0; i < faceLen; ++i) {
				face = faces[i];
				realIndices[j++] = face.i0;
				realIndices[j++] = face.i1;
				realIndices[j++] = face.i2;

				// if the face is a quad, add a second triangle
				if (face.i3) {
					realIndices[j++] = face.i0;
					realIndices[j++] = face.i2;
					realIndices[j++] = face.i3;
				}
			}

			_indices[mesh] = realIndices;
		}
	}
}