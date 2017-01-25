/**
 * Created by mkamenyuk on 12.01.2017.
 */
package utils {

    import flash.utils.ByteArray;

    public class ByteArrayUtil {
        public static function cloneByteArray(input:ByteArray):ByteArray {
            var output:ByteArray = new ByteArray();
            output.writeObject(input);
            output.position = 0;
            return output.readObject() as ByteArray;
        }

        // удаляет первые count байтов
        public static function shiftByteArray(ba:ByteArray, count:int):void {
            ba.position = 0;
            ba.writeBytes(ba, count, ba.length - count);
            ba.length = ba.length - count;
        }

        public static function byteArrayAsHEX(ba:ByteArray):Object {
            var count:int = 0;
            var chars:Array = [];
            var value:int;
            var char:String;
            var bytes:Array = [];
            ba.position = 0;
            while(ba.bytesAvailable){
                value = ba.readUnsignedByte();
                bytes.push(value);
                char = value.toString(16);
                if(char.length == 1){
                    char = '0' + char;
                }
                if(count % 2){
                    chars[chars.length - 1] += char;
                }else{
                    chars.push(char);
                }
                count++;
            }
            ba.position = 0;
            return {
                chars: chars,
                bytes: bytes
            };
        }

        public static function byteArrayAsHEXGrouped(ba:ByteArray, groupLen:int):String {
            var chars:Array = byteArrayAsHEX(ba).chars;
            var result:String = '';
            while(chars.length){
                result += chars.splice(0, groupLen).join(' ') + '\n';
            }
            return result;
        }
    }
}
