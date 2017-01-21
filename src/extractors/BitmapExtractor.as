/**
 * Created by mkamenyuk on 20.01.2017.
 */
package extractors {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.filesystem.File;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import utils.FileUtil;

    /**
     * In fact, BitmapExtractor extends EventDispatcher
     * only because of JPEG extraction flow
     * where we need to wait for loader.loadBytes() execution.
     * And because I want them all to return ByteArray but not BitmapData.
     * All other extractions are able to return data immediately.

     * BitmapExtractor processes 1 file at once
     * I intent this to avoid queries / dictionaries / custom events and all this stuff
     */
    public class BitmapExtractor extends EventDispatcher {

        private static const TYPE_JPEG:int = 0xffd8;

        private var _isBusy:Boolean;
        private var _datBA:ByteArray;
        private var _outBA:ByteArray;
        private var _loader:Loader;
        private var _eventComplete:Event
        private var _itemName:String;

        public function BitmapExtractor() {
            _eventComplete = new Event(Event.COMPLETE);
        }

        public function extract(dat:File, itemName:String):Boolean {
            if(_isBusy){
                return false;
            }
            _itemName = itemName;
            _datBA = FileUtil.readFileAsBinary(dat);

            var type:uint = _datBA.readUnsignedShort();
            switch(type){
                case TYPE_JPEG :
                    extractJPEG();
                break;
            }
            return true;
        }

        public function get isBusy():Boolean {
            return _isBusy;
        }

        public function get itemName():String {
            return _itemName;
        }

        public function get extractedBytes():ByteArray {
            _outBA.position = 0;
            return _outBA;
        }

        // extractions section
        /**
         * .dat files for JPEG are same files with .dat extension.
         * Checked for YCbCr, RGB, CMYK.
         */
        private function extractJPEG():void {
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleJPEGLoaderComplete);
            _loader.loadBytes(_datBA);
            _datBA.clear();
        }

        private function handleJPEGLoaderComplete(event:Event):void {
            var bitmapData:BitmapData = (_loader.content as Bitmap).bitmapData;
            _outBA = bitmapData.getPixels(bitmapData.rect);
            bitmapData.dispose();
            bitmapData = null;
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handleJPEGLoaderComplete);
            _loader.unload();
            _loader = null;
            dispatchEvent(_eventComplete);
        }
    }
}
