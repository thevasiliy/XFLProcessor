/**
 * Created by mkamenyuk on 20.01.2017.
 */
package extractors {

    import flash.filesystem.File;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import utils.FileUtil;

    public class SoundExtractor {

        private static const TYPE_WAV:int = 0;
        private static const TYPE_MP3:int = 1;

        private static const WAV_RIFF:String = 'RIFF';
        private static const WAV_WAVE:String = 'WAVE';
        private static const WAV_FMT:String = 'fmt ';
        private static const WAV_DATA:String = 'data';

        private var _datBA:ByteArray;
        private var _itemName:String;

        public function SoundExtractor() {}

        /**
         * So far only WAV, MP3 is under investigation
         */
        public function extract(dat:File, itemName:String):ByteArray {
            _itemName = itemName;
            _datBA = FileUtil.readFileAsBinary(dat);

            var type:int = TYPE_WAV;
            switch(type) {
                case TYPE_WAV :
                    return extractWAV();

                case TYPE_MP3 :
                    return null;
            }

            return null;
        }

        public function get itemName():String {
            return _itemName;
        }

        private function extractWAV():ByteArray {
            var outBA:ByteArray = new ByteArray();
            outBA.endian = Endian.LITTLE_ENDIAN;

            // TODO - settings should be taken from DOMSoundItem
            var channels:int = 2;
            var rate:int = 44100;
            var bits:int = 16;

            outBA.writeUTFBytes(WAV_RIFF);
            outBA.writeInt(uint(_datBA.length + 44));
            outBA.writeUTFBytes(WAV_WAVE);
            outBA.writeUTFBytes(WAV_FMT);
            outBA.writeInt(uint(16));
            outBA.writeShort(uint(1));
            outBA.writeShort(channels);
            outBA.writeInt(rate);
            outBA.writeInt(uint(rate * channels * (bits >> 3)));
            outBA.writeShort(uint(channels * (bits >> 3)));
            outBA.writeShort(bits);
            outBA.writeUTFBytes(WAV_DATA);
            outBA.writeInt(_datBA.length);
            outBA.writeBytes(_datBA);
            outBA.position = 0;

            return outBA;
        }
    }
}
