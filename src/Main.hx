package;

import format.swf.exporters.SWFLiteExporter;
import format.SWF;
import haxe.macro.Compiler;
import lime.graphics.Image;
import openfl._internal.formats.swf.SWFLiteLibrary;
import openfl._internal.symbols.BitmapSymbol;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.utils.Assets;
@:access(lime.utils.AssetLibrary)

class Main extends Sprite
{
	private var clip:MovieClip;
	private var currentIndex = -1;
	private var swfs = [ "assets/nyancat.swf", "assets/allyourbase.swf", "assets/badgerbadger.swf", "assets/nowheretohide.swf", "assets/kenya.swf" ];
	
	public function new()
	{
		super();
		
		var defineSWF = Compiler.getDefine("swf");
		if (defineSWF != null)
		{
			var asInt = Std.parseInt(defineSWF);
			if (Std.string(asInt) == defineSWF)
			{
				currentIndex = asInt - 1;
			}
			else
			{
				for (i in 0...swfs.length)
				{
					if (swfs[i].indexOf(defineSWF) > -1)
					{
						currentIndex = i - 1;
						break;
					}
				}
			}
		}
		
		nextSWF();
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
		buttonMode = true;
	}
	
	private function loadSWF(path:String):Void
	{
		if (clip != null)
		{
			removeChild(clip);
			clip = null;
		}
		
		var bytes = Assets.getBytes(path);
		var swf = new SWF(bytes);
		stage.color = swf.backgroundColor;
		
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

		clip = exporter.swfLite.createMovieClip("");
		var mask = new Sprite();
		mask.graphics.beginFill(0xFF0000);
		mask.graphics.drawRect(0, 0, swf.width, swf.height);
		clip.mask = mask;
		addChild(clip);
	}
	
	private function nextSWF():Void
	{
		currentIndex++;
		if (currentIndex >= swfs.length)
		{
			currentIndex = 0;
		}
		loadSWF(swfs[currentIndex]);
	}
	
	// Event Handlers
	
	private function stage_onMouseDown(event:MouseEvent):Void
	{
		nextSWF();
	}
}