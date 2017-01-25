/**
 * Created by mkamenyuk on 13.01.2017.
 */
package xfl {

    public class DOMSoundItem extends DOMItem {

        public function DOMSoundItem(xml:XML) {
            super(xml);
            _dataHRef = xml.@soundDataHRef;
        }
    }
}
