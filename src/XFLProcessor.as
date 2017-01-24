package {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filesystem.File;

    import extractors.BitmapExtractor;
    import xfl.DOMBitmapItem;
    import xfl.XFLProject;

    public class XFLProcessor extends Sprite {

        private var xflProject:XFLProject;
        private var bitmapExtractor:BitmapExtractor;

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

            bitmapExtractor = new BitmapExtractor();
            bitmapExtractor.addEventListener(Event.COMPLETE, handleExtractionComplete);

            extractSomething();
        }

        /**
         * Do whatever you want with extracted images
         * Compose a spritesheet for JS ? =)
         */
        private function handleExtractionComplete(event:Event):void {
            var domItem:DOMBitmapItem = xflProject.getDOMBitmapItem(bitmapExtractor.itemName);
            var bitmapData:BitmapData = new BitmapData(domItem.width, domItem.height);
            bitmapData.setPixels(bitmapData.rect, bitmapExtractor.extractedBytes);
            var bitmap:Bitmap = new Bitmap(bitmapData);
            //bitmap.scaleX = bitmap.scaleY = 8;
            addChild(bitmap);
        }


        //-------------
        private function extractSomething():void {
            var name:String = 'animated/animated_0';
            var domItem:DOMBitmapItem = xflProject.getDOMBitmapItem(name);
            var datFile:File = xflProject.getDOMBitmapDatFile(name);

            bitmapExtractor.extract(datFile, domItem.name);
        }
    }
}
