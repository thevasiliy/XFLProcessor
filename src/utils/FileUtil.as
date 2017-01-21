/**
 * Created by mkamenyuk on 19.01.2017.
 */
package utils {

    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

    public class FileUtil {
        public static function readFileAsBinary(file:File):ByteArray {
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.READ);
            var ba:ByteArray = new ByteArray();
            fileStream.readBytes(ba, 0, fileStream.bytesAvailable);
            fileStream.close();
            fileStream = null;
            file = null;
            ba.position = 0;
            return ba;
        }

        public static function readFileAsText(file:File):String {
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.READ);
            var result:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();
            fileStream = null;
            file = null;
            return result;
        }
    }
}
