/**
 * Created by mkamenyuk on 12.01.2017.
 */
package xfl {

    import flash.filesystem.File;

    import utils.FileUtil;

    public class XFLProject {

        private static const DOM_DOCUMENT:String = 'DOMDocument.xml';
        private static const DOM_BITMAP_ITEM:String = 'DOMBitmapItem';
        private static const DOM_SOUND_ITEM:String = 'DOMSoundItem';
        private static const BIN_DIRECTORY:String = 'bin';

        private var projectDirectory:File;
        private var binDirectory:File;

        private var domBitmapItems:Vector.<DOMBitmapItem>;
        private var domSoundItems:Vector.<DOMSoundItem>;

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

            list = domXML.media.descendants(DOM_SOUND_ITEM);
            domSoundItems = new <DOMSoundItem>[];
            for(i = 0; i < list.length(); i++){
                domSoundItems.push(new DOMSoundItem(list[i]));
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
                return binDirectory.resolvePath(domBitmapItem.dataHRef);
            }
            return null;
        }

        public function getDOMSoundItem(name:String):DOMSoundItem {
            for(var i:int = 0; i < domSoundItems.length; i++){
                if(domSoundItems[i].name == name){
                    return domSoundItems[i];
                }
            }
            return null;
        }

        public function getDOMSoundDatFile(name:String):File {
            var domSoundItem:DOMSoundItem = getDOMSoundItem(name);
            if(domSoundItem){
                return binDirectory.resolvePath(domSoundItem.dataHRef);
            }
            return null;
        }

        // TODO - or do getDOMItem() ? No matter the what type is, only name matters?

        public function get name():String {
            return projectDirectory.name;
        }
    }
}
