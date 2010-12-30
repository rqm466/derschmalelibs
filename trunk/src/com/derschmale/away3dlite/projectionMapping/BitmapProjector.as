package com.derschmale.away3dlite.projectionMapping
{
	import away3dlite.arcane;
	import away3dlite.core.base.Object3D;

	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Transform;
	import flash.geom.Vector3D;

	use namespace arcane;

	/**
	 * A "Lamp" that has projection information which is used for projective texture mapping.
	 */
	public class BitmapProjector extends Object3D
	{
		private var _bitmap : BitmapData;
		private var _renderBitmap : BitmapData;

		private var _focalLength : Number = 1;
		private var _aspectRatio : Number;
		private var _origin : Point;

		private var _projectionMatrix : Matrix3D;
		private var _viewProjectionMatrix : Matrix3D;

		private var _projectionInvalid : Boolean = true;
		private var _viewProjectionInvalid : Boolean = true;

		/**
		 * Create a BitmapProjector object
		 *
		 * @param bitmap The texture to be used as the light's texture
		 */
		public function BitmapProjector(bitmap : BitmapData)
		{
			_projectionMatrix = new Matrix3D();
			_viewProjectionMatrix = new Matrix3D();

			_bitmap = bitmap;
			_renderBitmap = _bitmap.clone();
			_aspectRatio = bitmap.width/bitmap.height;
			_origin = new Point();

			focalLength = 1;
		}

		/**
		 * The projection matrix that transforms object (light)-space positions to homogeneous coordinates
		 */
		public function get projectionMatrix() : Matrix3D
		{
			if (_projectionInvalid)
				updateProjection();
			return _projectionMatrix;
		}

		/**
		 * A matrix that combines transformation to the light's point of view and the projection.
		 * It transforms scene positions to homogeneous coordinates
		 */
		public function get viewProjectionMatrix() : Matrix3D
		{
			if (_viewProjectionInvalid)
				updateViewProjection();
			return _viewProjectionMatrix;
		}

		/**
		 * The aspect ratio (width/height) of the texture, and as such of the projection
		 */
		public function get aspectRatio() : Number
		{
			return _aspectRatio;
		}

		/**
		 * The bitmap used as the projection texture
		 */
		public function get bitmap() : BitmapData
		{
			return _renderBitmap;
		}

		/**
		 * The distance between the lamp and the texture. focalLength = 1/tan(fov/2)
		 */
		public function get focalLength() : Number
		{
			return _focalLength;
		}

		public function set focalLength(value : Number) : void
		{
			_focalLength = value;
			_projectionInvalid = true;
		}

		/**
		 * Updates the projection matrix, DirectX-style matrix that maps z to (0, 1)
		 */
		private function updateProjection() : void
		{
			var raw : Vector.<Number> = new Vector.<Number>(16, true);

			// near and far planes don't really matter, we'll use 1 and 10000.
			var yMax : Number = 1/_focalLength;
			var xMax : Number = yMax*_aspectRatio;

			// use symmetric frustum
			raw[uint(0)] = 1/xMax;
			raw[uint(5)] = 1/yMax;
			raw[uint(10)] = 10000/9999;	// -far/(near-far)
			raw[uint(11)] = 1;
			raw[uint(1)] = raw[uint(2)] = raw[uint(3)] = raw[uint(4)] =
			raw[uint(6)] = raw[uint(7)] = raw[uint(8)] = raw[uint(9)] =
			raw[uint(12)] = raw[uint(13)] = raw[uint(15)] = 0;
			raw[uint(14)] = -raw[uint(10)];

			_projectionMatrix.rawData = raw;
			_projectionInvalid = false;
			_viewProjectionInvalid = true;
		}

		/**
		 * Updates the view projection matrix
		 */
		private function updateViewProjection() : void
		{
			_viewProjectionMatrix.identity();
			_viewProjectionMatrix.append(transform.matrix3D);
			_viewProjectionMatrix.invert();
			_viewProjectionMatrix.append(projectionMatrix);

			_viewProjectionInvalid = false;
		}


//
// override all methods and setters that will invalidate the matrices
//
		override protected function copyMatrix3D(m1 : Matrix3D, m2 : Matrix3D) : void
		{
			_viewProjectionInvalid = true;
			super.copyMatrix3D(m1, m2);
		}

		override public function moveForward(distance : Number) : void
		{
			_viewProjectionInvalid = true;
			super.moveForward(distance);
		}

		override public function moveBackward(distance : Number) : void
		{
			_viewProjectionInvalid = true;
			super.moveBackward(distance);
		}

		override public function moveLeft(distance : Number) : void
		{
			_viewProjectionInvalid = true;
			super.moveLeft(distance);
		}

		override public function moveRight(distance : Number) : void
		{
			_viewProjectionInvalid = true;
			super.moveRight(distance);
		}

		override public function moveUp(distance : Number) : void
		{
			_viewProjectionInvalid = true;
			super.moveUp(distance);
		}

		override public function moveDown(distance : Number) : void
		{
			_viewProjectionInvalid = true;
			super.moveDown(distance);
		}

		override public function translate(axis : Vector3D, distance : Number) : void
		{
			_viewProjectionInvalid = true;
			super.translate(axis, distance);
		}

		override public function pitch(degrees : Number) : void
		{
			_viewProjectionInvalid = true;
			super.pitch(degrees);
		}

		override public function yaw(degrees : Number) : void
		{
			_viewProjectionInvalid = true;
			super.yaw(degrees);
		}

		override public function roll(degrees : Number) : void
		{
			_viewProjectionInvalid = true;
			super.roll(degrees);
		}

		override public function rotate(degrees : Number, axis : Vector3D, pivotPoint : Vector3D = null) : void
		{
			_viewProjectionInvalid = true;
			super.rotate(degrees, axis, pivotPoint);
		}

		override public function lookAt(target : Vector3D, upAxis : Vector3D = null) : void
		{
			_viewProjectionInvalid = true;
			super.lookAt(target, upAxis);
		}

		override public function clone(object : Object3D = null) : Object3D
		{
			_viewProjectionInvalid = true;
			return super.clone(object);
		}

		override public function set scaleX(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.scaleX = value;
		}

		override public function set scaleY(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.scaleY = value;
		}

		override public function set scaleZ(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.scaleZ = value;
		}

		override public function set rotationX(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.rotationX = value;
		}

		override public function set rotationY(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.rotationY = value;
		}

		override public function set rotationZ(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.rotationZ = value;
		}

		override public function set transform(value : Transform) : void
		{
			_viewProjectionInvalid = true;
			super.transform = value;
		}

		override public function set x(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.x = value;
		}

		override public function set y(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.y = value;
		}

		override public function set z(value : Number) : void
		{
			_viewProjectionInvalid = true;
			super.z = value;
		}
	}
}