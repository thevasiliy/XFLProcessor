/**
 * Created by mkamenyuk on 25.01.2017.
 */
package xfl {

    public class DOMItem {

        protected var _name:String;
        protected var _itemID:String;
        protected var _sourceExternalFilepath:String;
        protected var _dataHRef:String;

        public function DOMItem(xml:XML) {
            _name = xml.@name;
            _itemID = xml.@itemID;
            _sourceExternalFilepath = xml.@sourceExternalFilepath;
        }

        public function get name():String {
            return _name;
        }

        public function get itemID():String {
            return _itemID;
        }

        public function get sourceExternalFilepath():String {
            return _sourceExternalFilepath;
        }

        public function get dataHRef():String {
            return _dataHRef;
        }
    }
}
