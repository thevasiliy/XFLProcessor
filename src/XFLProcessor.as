package {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filesystem.File;
    import flash.utils.ByteArray;

    import extractors.ImageExtractor;
    import extractors.SoundExtractor;
    import utils.FileUtil;
    import xfl.DOMBitmapItem;
    import xfl.XFLProject;

    public class XFLProcessor extends Sprite {

        private var xflProject:XFLProject;
        private var imageExtractor:ImageExtractor;
        private var soundExtractor:SoundExtractor;

        public function XFLProcessor() {
            loadProject();
        }

        private function loadProject():void {
            var projectDirectory:File = new File;
            projectDirectory.addEventListener(Event.SELECT, handleProjectSelection);
            projectDirectory.browseForDirectory('');
        }

        private function handleProjectSelection(event:Event):void {
            xflProject = new XFLProject(event.target as File);

            /*
            imageExtractor = new ImageExtractor();
            imageExtractor.addEventListener(Event.COMPLETE, handleExtractionComplete);
            extractSomeImage();
            */

            soundExtractor = new SoundExtractor();
            extractSomeSound();
        }

        /**
         * Do whatever you want with extracted images
         * Compose a spritesheet for JS ? =)
         */
        private function handleExtractionComplete(event:Event):void {
            var domItem:DOMBitmapItem = xflProject.getDOMBitmapItem(imageExtractor.itemName);
            var bitmapData:BitmapData = new BitmapData(domItem.width, domItem.height);
            bitmapData.setPixels(bitmapData.rect, imageExtractor.extractedBytes);
            var bitmap:Bitmap = new Bitmap(bitmapData);
            //bitmap.scaleX = bitmap.scaleY = 8;
            addChild(bitmap);
        }


        //-------------
        private function extractSomeImage():void {
            var name:String = 'PSD_CC.psd Asset/Layer 3';
            var datFile:File = xflProject.getDOMBitmapDatFile(name);

            imageExtractor.extract(datFile, name);
        }

        private function extractSomeSound():void {
            var name:String = 'sound.wav';
            var datFile:File = xflProject.getDOMSoundDatFile(name);

            var extractedSoundBA:ByteArray = soundExtractor.extract(datFile, name);
            FileUtil.saveFile(extractedSoundBA, File.desktopDirectory.resolvePath(name).nativePath);
            extractedSoundBA.clear();
        }
    }
}
