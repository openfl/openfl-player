package;

import openfl.display.DisplayObject;
import swf.SWFLoader;
import swf.SWF;
import haxe.macro.Compiler;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.net.URLRequest;
import openfl.utils.Assets;
#if swflite
import swf.exporters.SWFLiteExporter;
import swf.exporters.swflite.SWFLiteLibrary;
import swf.exporters.swflite.BitmapSymbol;
#end
#if (openfl >= "9.5.0")
import swf.exporters.swflite.SWFLiteLoader;
import swf.SWFLoader;
#end

@:access(lime.utils.AssetLibrary)
class Main extends Sprite
{
	private var clip:Sprite;
	private var currentIndex = -1;
	private var loader:Loader;
	private var swfs = [ "assets/nyancat.swf", "assets/allyourbase.swf", "assets/badgerbadger.swf", "assets/nowheretohide.swf", "assets/kenya.swf" ];
	
	public function new()
	{
		super();
		
		init();

		#if (openfl >= "9.5.0")
		Loader.registerLoader(new #if swflite SWFLiteLoader() #else SWFLoader() #end);
		#end
		
		nextSWF();
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_onMouseDown);
		buttonMode = true;
	}

	private function init():Void
	{
		// -Dswf=1
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
	}
	
	#if (openfl >= "9.5.0")
	private function loadSWF(path:String):Void
	{
		if (clip != null)
		{
			removeChild(clip);
			clip = null;
		}
		
		if (loader != null)
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loader_onComplete);
		}

		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_onComplete);
		loader.load(new URLRequest(path));
	}
	
	#else

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
		
		#if swflite
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
		#else
		clip = new swf.runtime.MovieClip(swf.data);
		#end
		
		var mask = new Sprite();
		mask.graphics.beginFill(0xFF0000);
		mask.graphics.drawRect(0, 0, swf.width, swf.height);
		clip.mask = mask;
		addChild(clip);
	}
	#end
	
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

	private function loader_onComplete(event:Event):Void
	{
		var width = loader.contentLoaderInfo.width;
		var height = loader.contentLoaderInfo.height;

		clip = new Sprite();
		clip.graphics.beginFill(0x000000);
		clip.graphics.drawRect(0, 0, width, height);

		var mask = new Sprite();
		mask.graphics.beginFill(0xFF0000);
		mask.graphics.drawRect(0, 0, width, height);
		clip.mask = mask;

		clip.addChild(loader.content);
		addChild(clip);
	}
	
	private function stage_onMouseDown(event:MouseEvent):Void
	{
		nextSWF();
	}
}