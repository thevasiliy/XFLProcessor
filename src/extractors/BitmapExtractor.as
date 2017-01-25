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
        private static const TYPE_8_BITS:int = 0x0303;
        private static const TYPE_16_BITS:int = 0x0304;
        private static const TYPE_32_BITS:int = 0x0305;

        private static const ALPHA_HEX:uint = 0xff000000;
        private static const RED_15_BITS_MASK:uint = 0x7c00;
        private static const GREEN_15_BITS_MASK:uint = 0x03e0;
        private static const BLUE_15_BITS_MASK:uint = 0x001f;

        private static const DEFAULT_COMPRESSED_OFFSET:int = 26;

        private var _isBusy:Boolean;
        private var _datBA:ByteArray;
        private var _outBA:ByteArray;
        private var _loader:Loader;
        private var _eventComplete:Event;
        private var _itemName:String;
        private var _imageWidth:int;
        private var _imageHeight:int;
        private var _transparent:Boolean;

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

                case TYPE_8_BITS :
                    extract8Bits();
                break;

                case TYPE_16_BITS :
                    extract16Bits();
                break;

                case TYPE_32_BITS :
                    extract32Bits();
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

        public function get transparent():Boolean {
            return _transparent;
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
            _transparent = false;
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

        /**
         * GIF
         */
        private function extract8Bits():void {
            readImageInfo();

            var paletteSize:int = _datBA.readUnsignedShort();
            var palette:Vector.<uint> = new <uint>[];
            _datBA.endian = Endian.BIG_ENDIAN;
            for(var i:int = 0; i < paletteSize; i++){
                palette.push(_datBA.readUnsignedInt());
            }
            _datBA.endian = Endian.LITTLE_ENDIAN;

            var decompressed:ByteArray = decompressChunks(_datBA.position + 1);
            var colormapRowLength:int = Math.ceil(_imageWidth / 4) * 4;
            var skipBytesNum:int = colormapRowLength - _imageWidth;
            var colorIndex:int;

            _outBA = new ByteArray();
            for(i = 0; i < _imageHeight; i++){
                for(var j:int = 0; j < _imageWidth; j++) {
                    colorIndex = decompressed.readUnsignedByte();
                    _outBA.writeUnsignedInt(palette[colorIndex]);
                }
                decompressed.position += skipBytesNum;
            }

            _datBA.clear();
            decompressed.clear();
            decompressed = null;

            dispatchEvent(_eventComplete);
        }

        /**
         * BMP saved with 16 bits per pixel
         */
        private function extract16Bits():void {
            readImageInfo();

            var decompressed:ByteArray = decompressChunks(DEFAULT_COMPRESSED_OFFSET);
           _outBA = new ByteArray();
            var pixelValue:uint;
            var pixelNum:int = decompressed.length >> 1;
            for(var i:int = 0; i < pixelNum; i++){
                pixelValue = decompressed.readUnsignedShort();
                _outBA.writeUnsignedInt(ALPHA_HEX |
                        7 + (((pixelValue & RED_15_BITS_MASK) >> 10) << 3) << 16 |
                        7 + (((pixelValue & GREEN_15_BITS_MASK) >> 5) << 3) << 8 |
                        7 + ((pixelValue & BLUE_15_BITS_MASK) << 3));
            }
            // 1x1 pixels has 2 x0 bytes so trim _outBA length
            _outBA.length = _imageWidth * _imageHeight * 4;

            _datBA.clear();
            decompressed.clear();
            decompressed = null;

            dispatchEvent(_eventComplete);
        }

        /**
         * BMP saved with 24/32 bits per pixel
         * PNG files of any kind
         * PSD
         */
        private function extract32Bits():void {
            readImageInfo();
            _outBA = decompressChunks(DEFAULT_COMPRESSED_OFFSET);
            _datBA.clear();
            dispatchEvent(_eventComplete);
        }

        private function readImageInfo():void {
            _datBA.endian = Endian.LITTLE_ENDIAN;
            _datBA.position = 4;
            _imageWidth = _datBA.readUnsignedShort();
            _imageHeight = _datBA.readUnsignedShort();
            _datBA.position = 24;
            _transparent = _datBA.readByte();
        }

        private function decompressChunks(position:int):ByteArray {
            _datBA.position = position;
            var compressedChunkLength:int = _datBA.readUnsignedShort();
            _datBA.position += 2;
            if(compressedChunkLength == 2){
                compressedChunkLength = _datBA.readUnsignedShort();
            }else{
                compressedChunkLength -= 2;
            }
            var decompressed:ByteArray = new ByteArray();
            while(compressedChunkLength > 0){
                _datBA.readBytes(decompressed, decompressed.length, compressedChunkLength);
                compressedChunkLength = _datBA.readUnsignedShort();
            }
            decompressed.inflate();
            decompressed.position = 0;
            return decompressed;
        }
    }
}
