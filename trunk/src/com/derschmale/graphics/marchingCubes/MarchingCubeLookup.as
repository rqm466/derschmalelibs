package com.derschmale.graphics.marchingCubes
{
	import flash.geom.Vector3D;

	public class MarchingCubeLookup
	{
		private static var _lookUp : Vector.<MarchingCubeCase>;
		private static const TLN_IN : int = 0x01;
		private static const TRN_IN : int = 0x02;
		private static const TLF_IN : int = 0x04;
		private static const TRF_IN : int = 0x08;
		private static const BLN_IN : int = 0x10;
		private static const BRN_IN : int = 0x20;
		private static const BLF_IN : int = 0x40;
		private static const BRF_IN : int = 0x80;
		private static const COMPL : int = 0x100;
		
		public static function init() : Vector.<MarchingCubeCase>
		{
			if (_lookUp) return _lookUp;
			_lookUp = new Vector.<MarchingCubeCase>(256, true);
			_lookUp[0] = new MarchingCubeCase(new Vector.<Number>(), new Vector.<int>());

			// well... this was boring to do
			// 1: bln in
			_lookUp[0x10] = new MarchingCubeCase(	Vector.<Number>([-.5, 0, -.5, 0 , -.5, -.5, -.5, -.5, 0 ]),
													Vector.<int>([0, 1, 2]));
			// 2: bln + brn
			_lookUp[0x30] = new MarchingCubeCase(	Vector.<Number>([-.5, 0, -.5, .5 , 0, -.5,  .5, -.5, 0, -.5, -.5, 0 ]),
													Vector.<int>([0, 1, 2, 0, 2, 3]));
			// 3: bln + trn
			_lookUp[0x12] = new MarchingCubeCase(	Vector.<Number>([-.5, 0, -.5, 0 , -.5, -.5, -.5, -.5, 0, 0, .5, -.5, .5, .5, 0, .5, 0, -.5]),
													Vector.<int>([0, 1, 2, 3, 4, 5]));
			// 4: bln + trf
			_lookUp[0x18] = new MarchingCubeCase(	Vector.<Number>([-.5, 0, -.5, 0 , -.5, -.5, -.5, -.5, 0, .5, .5, 0, 0, .5, .5, .5, 0, .5]),
													Vector.<int>([0, 1, 2, 3, 4, 5]));

			// 5: brn + blf + brf
			_lookUp[0xe0] = new MarchingCubeCase(	Vector.<Number>([ 0, -.5, -.5, -.5, -.5,  0, -.5, 0,  .5, .5, 0, .5, .5, 0, -.5]),
													Vector.<int>([2, 1, 0, 4, 2, 0, 4, 3, 2]));

			// 6: bln + brn + trf
			_lookUp[0x38] = new MarchingCubeCase(	Vector.<Number>([ -.5, 0, -.5, .5 , 0, -.5, .5, -.5, 0, -.5, -.5, 0, .5, .5, 0, 0, .5, .5, .5, 0, .5]),
													Vector.<int>([0, 1, 2, 0, 2, 3, 4, 5, 6]));

			// 7: tln + trf + brn
			_lookUp[0x29] = new MarchingCubeCase(	Vector.<Number>([ -.5, .5, 0, 0, .5, -.5, -.5, 0, -.5, .5, .5, 0, 0, .5, .5, .5, 0, .5, 0, -.5, -.5, .5, -.5, 0, .5, 0, -.5]),
													Vector.<int>([0, 1, 2, 3, 4, 5, 8, 7, 6]));

			// 8: bln + brn + blf + brf
			_lookUp[0xf0] = new MarchingCubeCase(	Vector.<Number>([ -.5, 0, -.5, .5, 0, -.5, .5, 0, .5, -.5, 0, .5]),
													Vector.<int>([0, 1, 2, 0, 2, 3]));

			// 9: bln + tlf + brf
			_lookUp[0xd4] = new MarchingCubeCase(	Vector.<Number>([ -.5, 0, -.5, 0, -.5, -.5, .5, -.5, 0, .5, 0, .5, 0, .5, .5, -.5, .5, 0 ]),
													Vector.<int>([0, 1, 4, 4, 5, 0, 4, 1, 3, 1, 2, 3]));


			// 10: tln + bln + trf + brf
			_lookUp[0x99] = new MarchingCubeCase(	Vector.<Number>([ -.5, .5, 0, 0, .5, -.5, 0, -.5, -.5, -.5, -.5, 0, .5, .5, 0, 0, .5, .5, 0, -.5, .5, .5, -.5, 0 ]),
													Vector.<int>([0, 1, 2, 0, 2, 3,	4, 5, 6, 4, 6, 7]));
			// 11: bln + brf + trf + blf
			_lookUp[0xd8] = new MarchingCubeCase(	Vector.<Number>([ -.5, 0, -.5, 0, -.5, -.5, .5, -.5, 0, .5, .5, 0, 0, .5, .5, -.5,  0, .5 ]),
													Vector.<int>([0, 1, 5, 1, 3, 5, 1, 2, 3, 3, 4, 5]));

			// 12: tln + brn + brf + blf
			_lookUp[0xe1] = new MarchingCubeCase(	Vector.<Number>([ -.5, .5, 0, 0, .5, -.5, -.5, 0, -.5, -.5, 0, .5, -.5, -.5, 0, 0, -.5, -.5, .5, 0, -.5, .5, 0, .5 ]),
													Vector.<int>([0, 1, 2, 3, 4, 6, 4, 5, 6, 7, 3, 6]));

			// 13: bln + trn + brf + tlf
			_lookUp[0x96] = new MarchingCubeCase(	Vector.<Number>([ -.5, 0, -.5, 0 , -.5, -.5, -.5, -.5, 0, 0, .5, -.5, .5, .5, 0, .5, 0, -.5, 0, -.5, .5, .5, 0, .5, .5, -.5, 0, -.5, .5, 0, -.5, 0, .5, 0, .5, .5 ]),
													Vector.<int>([0, 1, 2, 3, 4, 5, 8, 7, 6, 9, 10, 11]));
			// 14: tlf + blf + brf + brn
			_lookUp[0xe4] = new MarchingCubeCase(	Vector.<Number>([-.5, .5, 0, 0, .5, .5, .5, 0, .5, .5, 0, -.5,	0, -.5, -.5, -.5, -.5, 0 ]),
													Vector.<int>([2, 1, 0, 4, 2, 0, 4, 3, 2, 4, 0, 5]));

			// if inverse (~ of key) -> simply inverse indices
//			generateComplements();
			generateDependencies();

			return _lookUp;
		}

		private static function generateComplements() : void
		{
			// 3c: bln + trn
			_lookUp[0x112] = new MarchingCubeCase(	Vector.<Number>([ 0, .5, -.5, .5, .5, 0, .5, 0, -.5, 0, -.5, -.5, -.5, -.5, 0, -.5, 0, -.5 ]),
													Vector.<int>([4, 1, 0, 4, 2, 1, 4, 3, 2, 0, 5, 4]));

			// 6c: bln + brn + trf
			_lookUp[0x138] = new MarchingCubeCase(	Vector.<Number>([	0, .5, .5, .5, .5, 0, .5, 0, -.5, -.5, 0, -.5, .5, 0, .5, .5, -.5, 0, -.5, -.5, -.5 ]),
													Vector.<int>([ 0, 1, 2, 2, 3, 0, 5, 4, 0, 6, 5, 0, 3, 6, 0 ]));

			// 7c: tln + trf + brn
			_lookUp[0x129] = new MarchingCubeCase(	Vector.<Number>([ 	0, .5, -.5, .5, .5, 0, .5, 0, -.5, -.5, .5, 0, 0, .5, .5, .5, 0, .5, .5, -.5, 0, 0, -.5, -.5, -.5, 0, -.5 ]),
													Vector.<int>([ 0 ,1, 2, 7, 4, 3, 6, 5, 4, 7, 6, 4, 8, 7, 3 ]));

			// 10: tln + bln + trf + brf
			_lookUp[0x199] = new MarchingCubeCase(	Vector.<Number>([ -.5, .5, 0, 0, .5, .5, 0, -.5, .5, -.5, -.5, 0, 0, .5, -.5, .5, .5, 0, .5, -.5, 0, 0, -.5, -.5 ]),
													Vector.<int>([  2, 1, 0, 3, 2, 0, 4, 5, 6, 6, 7, 4]));

			// 12: tln + brn + brf + blf
			_lookUp[0x1e1] = new MarchingCubeCase(	Vector.<Number>([ -.5, 0, -.5, 0, -.5, -.5, -.5, -.5, 0, 0, .5, -.5, .5, 0, -.5, .5, 0, .5, -.5, 0, .5, -.5, .5, 0 ]),
													Vector.<int>([0, 1, 2, 6, 4, 3, 6, 5, 4, 7, 6, 3 ]));

			// 13: bln + trn + brf + tlf
			_lookUp[0x196] = new MarchingCubeCase(	Vector.<Number>([ -.5, .5, 0, 0, .5, -.5, -.5, 0, -.5, 0, -.5, -.5, .5, -.5, 0, .5, 0, -.5, 0, .5, .5, .5, .5, 0, .5, 0, .5, -.5, 0, .5, 0, -.5, .5, -.5, -.5, 0 ]),
													Vector.<int>([2, 1, 0 , 3, 4, 5, 6, 7, 8, 9, 10, 11]));
		}

		private static function generateDependencies() : void
		{
			// changed will be false once all slots are filled
			var changed : Boolean = true;

			while (changed) {
				changed = false
				for (var i : int = 1; i < 256; ++i) {
					if (_lookUp[i]) continue;
					changed = true;
					if (checkInverse(i)) continue;
					if (checkMirrorX(i)) continue;
					if (checkMirrorY(i)) continue;
					if (checkMirrorZ(i)) continue;
					if (checkRotateX(i)) continue;
					if (checkRotateY(i)) continue;
					//					if (checkRotateZ(i)) continue;
				}
			}
		}

		private static function checkInverse(i : uint) : Boolean
		{
			var invPattern : uint = (~i) & 0xff;

			var originalCase : MarchingCubeCase = _lookUp[invPattern];
			if (!originalCase) return false;

			_lookUp[i] = originalCase.invert();
			return true;
		}

		private static function checkMirrorX(i : uint) : Boolean
		{
			var mirrPattern : uint = i & COMPL;
			if (i & TLN_IN) mirrPattern |= TRN_IN;
			if (i & TRN_IN) mirrPattern |= TLN_IN;
			if (i & TLF_IN) mirrPattern |= TRF_IN;
			if (i & TRF_IN) mirrPattern |= TLF_IN;
			if (i & BLN_IN) mirrPattern |= BRN_IN;
			if (i & BRN_IN) mirrPattern |= BLN_IN;
			if (i & BLF_IN) mirrPattern |= BRF_IN;
			if (i & BRF_IN) mirrPattern |= BLF_IN;

			var originalCase : MarchingCubeCase = _lookUp[mirrPattern];
			if (!originalCase) return false;

			_lookUp[i] = originalCase.mirror(0);
			return true;
		}

		private static function checkMirrorY(i : uint) : Boolean
		{
			var mirrPattern : uint = i & COMPL;
			if (i & TLN_IN) mirrPattern |= BLN_IN;
			if (i & TRN_IN) mirrPattern |= BRN_IN;
			if (i & TLF_IN) mirrPattern |= BLF_IN;
			if (i & TRF_IN) mirrPattern |= BRF_IN;
			if (i & BLN_IN) mirrPattern |= TLN_IN;
			if (i & BRN_IN) mirrPattern |= TRN_IN;
			if (i & BLF_IN) mirrPattern |= TLF_IN;
			if (i & BRF_IN) mirrPattern |= TRF_IN;

			var originalCase : MarchingCubeCase = _lookUp[mirrPattern];
			if (!originalCase) return false;

			_lookUp[i] = originalCase.mirror(1);
			return true;
		}

		private static function checkMirrorZ(i : uint) : Boolean
		{
			var mirrPattern : uint = i & COMPL;
			if (i & TLN_IN) mirrPattern |= TLF_IN;
			if (i & TRN_IN) mirrPattern |= TRF_IN;
			if (i & TLF_IN) mirrPattern |= TLN_IN;
			if (i & TRF_IN) mirrPattern |= TRN_IN;
			if (i & BLN_IN) mirrPattern |= BLF_IN;
			if (i & BRN_IN) mirrPattern |= BRF_IN;
			if (i & BLF_IN) mirrPattern |= BLN_IN;
			if (i & BRF_IN) mirrPattern |= BRN_IN;

			var originalCase : MarchingCubeCase = _lookUp[mirrPattern];
			if (!originalCase) return false;

			_lookUp[i] = originalCase.mirror(2);

			return true;
		}

		private static function checkRotateX(i : uint) : Boolean
		{
			var mirrPattern : uint = i & COMPL;
			if (i & TLN_IN) mirrPattern |= TLF_IN;
			if (i & TRN_IN) mirrPattern |= TRF_IN;
			if (i & TLF_IN) mirrPattern |= BLF_IN;
			if (i & TRF_IN) mirrPattern |= BRF_IN;
			if (i & BLN_IN) mirrPattern |= TLN_IN;
			if (i & BRN_IN) mirrPattern |= TRN_IN;
			if (i & BLF_IN) mirrPattern |= BLN_IN;
			if (i & BRF_IN) mirrPattern |= BRN_IN;

			var originalCase : MarchingCubeCase = _lookUp[mirrPattern];
			if (!originalCase) return false;

			_lookUp[i] = originalCase.rotate(Vector3D.X_AXIS, -90);

			return true;
		}

		private static function checkRotateY(i : uint) : Boolean
		{
			var mirrPattern : uint = i & COMPL;
			if (i & TLN_IN) mirrPattern |= TLF_IN;
			if (i & TRN_IN) mirrPattern |= TLN_IN;
			if (i & TLF_IN) mirrPattern |= TRF_IN;
			if (i & TRF_IN) mirrPattern |= TRN_IN;
			if (i & BLN_IN) mirrPattern |= BLF_IN;
			if (i & BRN_IN) mirrPattern |= BLN_IN;
			if (i & BLF_IN) mirrPattern |= BRF_IN;
			if (i & BRF_IN) mirrPattern |= BRN_IN;

			var originalCase : MarchingCubeCase = _lookUp[mirrPattern];
			if (!originalCase) return false;

			_lookUp[i] = originalCase.rotate(Vector3D.Y_AXIS, -90);

			return true;
		}

		private static function checkRotateZ(i : uint) : Boolean
		{
			var mirrPattern : uint = i & COMPL;
			
			if (i & TLN_IN) mirrPattern |= BLN_IN;
			if (i & TRN_IN) mirrPattern |= BRN_IN;
			if (i & TLF_IN) mirrPattern |= TLN_IN;
			if (i & TRF_IN) mirrPattern |= TRN_IN;
			if (i & BLN_IN) mirrPattern |= BLF_IN;
			if (i & BRN_IN) mirrPattern |= BRF_IN;
			if (i & BLF_IN) mirrPattern |= TLF_IN;
			if (i & BRF_IN) mirrPattern |= TRF_IN;

			var originalCase : MarchingCubeCase = _lookUp[mirrPattern];
			if (!originalCase) return false;

			_lookUp[i] = originalCase.rotate(Vector3D.Z_AXIS, 90);
			return true;
		}

		public static function getCase(pattern : int) : MarchingCubeCase
		{
			return _lookUp[pattern];
		}
	}
}