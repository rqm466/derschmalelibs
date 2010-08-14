package com.derschmale.graphics.marchingCubes
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class MarchingCubeCase
	{
		public var verticesLength : int;
		public var numIndices : int;
		public var vertices : Vector.<Number>;
		public var indices : Vector.<int>;
		public var numVertices : int;

		public function MarchingCubeCase(vertices : Vector.<Number>, indices : Vector.<int>)
		{
			if (indices) {
				this.indices = indices;
				numIndices = indices.length;
				this.indices.fixed = true;
			}
			if (vertices) {
				this.vertices = vertices;
				verticesLength = vertices.length;
				numVertices = verticesLength/3;
				this.vertices.fixed = true;
			}
		}

		public function invert() : MarchingCubeCase
		{
			var inverse : MarchingCubeCase = new MarchingCubeCase(vertices , indices.concat().reverse());
			return inverse;
		}

		public function mirror(coordIndex : int) : MarchingCubeCase
		{
			var verts : Vector.<Number> = vertices.concat();
			var inds : Vector.<int> = indices.concat().reverse();
			var len : int = verts.length;
			var mirror : MarchingCubeCase = new MarchingCubeCase(verts, inds);
			var i : int = coordIndex;
			while (i < len) {
				verts[i] *= -1;
				i += 3;
			}

			return mirror;
		}

		public function rotate(axis : Vector3D, degrees : Number) : MarchingCubeCase
		{
			var verts : Vector.<Number> = new Vector.<Number>(vertices.length, true);
			var rotate : MarchingCubeCase = new MarchingCubeCase(verts, indices);
			var matrix : Matrix3D = new Matrix3D();
			matrix.appendRotation(degrees, axis);
			matrix.transformVectors(vertices, verts);
			for (var i : int = 0; i < verts.length; ++i) {                   
				verts[i] = Math.round(verts[i]*2)*.5;
			}
			return rotate;
		}
	}
}