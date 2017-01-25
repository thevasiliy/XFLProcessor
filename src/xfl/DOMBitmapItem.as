/**
 * Created by mkamenyuk on 12.01.2017.
 */
package xfl {

    public class DOMBitmapItem extends DOMItem {

        private static const TWIPS_PER_PIXEL:int = 20;

        private var _width:Number;
        private var _height:Number;
        private var _isJPEG:Boolean;

        public function DOMBitmapItem(xml:XML) {
            super(xml);
            _dataHRef = xml.@bitmapDataHRef;
            _width = int(xml.@frameRight) / TWIPS_PER_PIXEL;
            _height = int(xml.@frameBottom) / TWIPS_PER_PIXEL;
            _isJPEG = String(xml.@isJPEG) == 'true';
        }

        public function get width():Number {
            return _width;
        }

        public function get height():Number {
            return _height;
        }

        public function get isJPEG():Boolean {
            return _isJPEG;
        }
    }
}
