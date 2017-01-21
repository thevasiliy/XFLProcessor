/**
 * Created by mkamenyuk on 12.01.2017.
 */
package xfl {

    public class DOMBitmapItem {

        private static const TWIPS_PER_PIXEL:int = 20;

        public var name:String;
        public var itemID:String;
        public var sourceExternalFilepath:String;
        public var bitmapDataHRef:String;
        public var width:int;
        public var height:int;
        public var isJPEG:Boolean;

        public function DOMBitmapItem(xml:XML) {
            name = xml.@name;
            itemID = xml.@itemID;
            sourceExternalFilepath = xml.@sourceExternalFilepath;
            bitmapDataHRef = xml.@bitmapDataHRef;
            width = int(xml.@frameRight) / TWIPS_PER_PIXEL;
            height = int(xml.@frameBottom) / TWIPS_PER_PIXEL;
            isJPEG = String(xml.@isJPEG) == 'true';
        }
    }
}
