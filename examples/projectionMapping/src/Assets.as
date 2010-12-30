package
{
	import flash.display.BitmapData;

	/**
	 * Contains references to all the assets used in ProjectiveTextureMapping
	 *
	 * @author David Lenaerts
	 */
	public class Assets
	{
		[Embed(source="../assets/stained_glass.jpg")]
		private static const LightTexture : Class;

		[Embed(source="../assets/floor_diffuse.jpg")]
		private static const FloorDiffuse : Class;

		[Embed(source="../assets/floor_normals.png")]
		private static const FloorNormal : Class;

		[Embed(source="../assets/floor_position.png")]
		private static const FloorPosition : Class;

		[Embed(source="../assets/wall_diffuse.jpg")]
		private static const WallDiffuse : Class;

		[Embed(source="../assets/wall_normals.png")]
		private static const WallNormal : Class;

		[Embed(source="../assets/wall_position.png")]
		private static const WallPosition : Class;

		[Embed(source="../assets/cube_diffuse.jpg")]
		private static const CubeDiffuse : Class;

		[Embed(source="../assets/cube_positions.png")]
		private static const CubePosition : Class;

		[Embed(source="../assets/cube_normals.png")]
		private static const CubeNormals : Class;

		public static const LIGHT_TEXTURE : BitmapData = new LightTexture().bitmapData;

		public static const FLOOR_DIFFUSE : BitmapData = new FloorDiffuse().bitmapData;
		public static const FLOOR_NORMALS : BitmapData = new FloorNormal().bitmapData;
		public static const FLOOR_POSITIONS : BitmapData = new FloorPosition().bitmapData;
		public static const WALL_DIFFUSE : BitmapData = new WallDiffuse().bitmapData;
		public static const WALL_NORMALS : BitmapData = new WallNormal().bitmapData;
		public static const WALL_POSITIONS : BitmapData = new WallPosition().bitmapData;
		public static var CUBE_DIFFUSE : BitmapData = new CubeDiffuse().bitmapData;
		public static var CUBE_NORMALS : BitmapData = new CubeNormals().bitmapData;
		public static var CUBE_POSITIONS : BitmapData = new CubePosition().bitmapData;
	}
}
