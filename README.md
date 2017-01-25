# XFLProcessor
Processor for Adobe Flash / Animate .xfl projects (xml / dat for bitmaps, sounds, video / etc).

# Main goals:

### **1. Be able to restore initial resource files from .dat files.**

**Graphic file formats**

File Format|Filename extension|Investigated
------------ | ------------- | -------------
Adobe Photoshop|PSD|**No**
Bitmap (16/24/32 bits)|BMP|**Yes**
GIF|GIF|**Yes**
JPEG|JPG, JPEG|**Yes**
PNG|PNG|**No**

**Audio file formats**

File Format|Filename extension|Investigated
------------ | ------------- | -------------
Wave|WAV|**No**
MP3|MP3|**No**

**Video file formats**

Not defined yet.

### **2. Construct some unified framework for rendering data outside the SWF files.**