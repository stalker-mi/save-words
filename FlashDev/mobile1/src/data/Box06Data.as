////Generated by Prefab3D 2.143, Wed Jan 21 16:38:51 GMT+0300 2015. www.closier.nl/prefab
package data {

	import away3d.core.base.Geometry;
	import data.ASDReader;

	public class Box06Data {

		[Embed(source="asd/Box06Data.asd", mimeType="application/octet-stream")]
		private var Box06DataASD:Class;

		public function get geometryData():Geometry
		{
			return ASDReader.decodeGeometry(new Box06DataASD());
		}

	}
}