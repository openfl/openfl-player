package;

import format.swf.exporters.SWFLiteExporter;
import format.SWF;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;

import lime.graphics.Image;
import openfl._internal.formats.swf.SWFLiteLibrary;
import openfl._internal.symbols.BitmapSymbol;
import openfl.display.BitmapData;
import openfl.utils.Assets;
@:access(lime.utils.AssetLibrary)

class Main extends Sprite
{
    public function new()
    {
        super();

        var bytes = openfl.utils.Assets.getBytes("assets/nyancat.swf");
         var swf = new SWF(bytes);
        // TODO: No intermediate format
        var exporter = new SWFLiteExporter(swf.data);
        var swfLite = exporter.swfLite;
        var library = new SWFLiteLibrary("test");
        swfLite.library = library;
        library.swf = swfLite;

        for (id in exporter.bitmaps.keys())
        {
            var type = exporter.bitmapTypes.get(id) == BitmapType.PNG ? "png" : "jpg";
            var symbol:BitmapSymbol = cast swfLite.symbols.get(id);
            symbol.path = id + "." + type;
            swfLite.symbols.set(id, symbol);

            library.cachedImages.set(symbol.path, Image.fromBytes(exporter.bitmaps.get(id)));

            if (exporter.bitmapTypes.get(id) == BitmapType.JPEG_ALPHA)
            {
                symbol.alpha = id + "a.png";

                library.cachedImages.set(symbol.alpha, Image.fromBytes(exporter.bitmapAlpha.get(id)));
            }
        }

        var clip = exporter.swfLite.createMovieClip("");
        addChild(clip);

        // var loader = new URLLoader();
        // loader.addEventListener(Event.COMPLETE, loader_onComplete);
        // loader.addEventListener(IOErrorEvent.IO_ERROR, loader_onError);
        // loader.load(new URLRequest("https://github.com/openfl/openfl-samples/raw/master/demos/NyanCat/Assets/library.swf"));
    }

    // private function loader_onComplete(event:Event):Void
    // {
    //     var loader:URLLoader = cast event.currentTarget;
    //     var bytes:ByteArray = loader.data;
    //     bytes.position = 0;
    //     trace(bytes.length);
    //     var swf = new SWF(bytes);
    //     // TODO: No intermediate format
    //     var exporter = new SWFLiteExporter(swf.data);
    //     var clip = exporter.swfLite.createMovieClip("");
    //     addChild(clip);
    // }

    // private function loader_onError(event:IOErrorEvent):Void
    // {
    //     trace(event);
    // }
}