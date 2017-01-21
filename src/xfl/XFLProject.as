/**
 * Created by mkamenyuk on 12.01.2017.
 */
package xfl {

    import flash.filesystem.File;

    import utils.FileUtil;

    public class XFLProject {

        private static const DOM_DOCUMENT:String = 'DOMDocument.xml';
        private static const DOM_BITMAP_ITEM:String = 'DOMBitmapItem';
        private static const BIN_DIRECTORY:String = 'bin';

        private var projectDirectory:File;
        private var binDirectory:File;

        private var domBitmapItems:Vector.<DOMBitmapItem>;

        public function XFLProject(directory:File) {
            projectDirectory = directory;
            binDirectory = projectDirectory.resolvePath(BIN_DIRECTORY);

            var i:int;
            var domXML:XML = new XML(FileUtil.readFileAsText(projectDirectory.resolvePath(DOM_DOCUMENT)).replace(/ xmlns(?:.*?)?=".*?"/gi, ''));

            var list:XMLList = domXML.media.descendants(DOM_BITMAP_ITEM);
            domBitmapItems = new <DOMBitmapItem>[];
            for(i = 0; i < list.length(); i++){
                domBitmapItems.push(new DOMBitmapItem(list[i]));
            }
        }

        public function getDOMBitmapItem(name:String):DOMBitmapItem {
            for(var i:int = 0; i < domBitmapItems.length; i++){
                if(domBitmapItems[i].name == name){
                    return domBitmapItems[i];
                }
            }
            return null;
        }

        public function getDOMBitmapDatFile(name:String):File {
            var domBitmapItem:DOMBitmapItem = getDOMBitmapItem(name);
            if(domBitmapItem){
                return binDirectory.resolvePath(domBitmapItem.bitmapDataHRef);
            }
            return null;
        }

        public function get name():String {
            return projectDirectory.name;
        }
    }
}
