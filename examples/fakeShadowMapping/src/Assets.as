package
{
	import flash.display.BitmapData;

	/**
	 * Contains references to all the assets used in FakeShadowMapping
	 *
	 * @author David Lenaerts
	 */
	public class Assets
	{
		[Embed(source="../assets/spotlight.jpg")]
		private static const LightTexture : Class;

		[Embed(source="../assets/wall_diffuse.jpg")]
		private static const WallDiffuse : Class;

		[Embed(source="../assets/wall_normals.jpg")]
		private static const WallNormal : Class;

		[Embed(source="../assets/wall_position.png")]
		private static const WallPosition : Class;

		[Embed(source="../assets/cube_diffuse.jpg")]
		private static const CubeDiffuse : Class;

		[Embed(source="../assets/cube_positions.png")]
		private static const CubePosition : Class;

		[Embed(source="../assets/cube_normals.png")]
		private static const CubeNormals : Class;

		[Embed(source="../assets/sphere_diffuse.jpg")]
		private static const SphereDiffuse : Class;

		[Embed(source="../assets/sphere_normals.png")]
		private static const SphereNormals : Class;

		public static const LIGHT_TEXTURE : BitmapData = new LightTexture().bitmapData;

		public static const WALL_DIFFUSE : BitmapData = new WallDiffuse().bitmapData;
		public static const WALL_NORMALS : BitmapData = new WallNormal().bitmapData;
		public static const WALL_POSITIONS : BitmapData = new WallPosition().bitmapData;
		public static var CUBE_DIFFUSE : BitmapData = new CubeDiffuse().bitmapData;
		public static var CUBE_NORMALS : BitmapData = new CubeNormals().bitmapData;
		public static var CUBE_POSITIONS : BitmapData = new CubePosition().bitmapData;
		public static var SPHERE_DIFFUSE : BitmapData = new SphereDiffuse().bitmapData;
		public static var SPHERE_NORMALS_POSITIONS : BitmapData = new SphereNormals().bitmapData;
	}
}
