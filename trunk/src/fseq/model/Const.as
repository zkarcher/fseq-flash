package fseq.model
{

import com.zacharcher.color.*;
import com.zacharcher.math.*;

public class Const extends Object
{
	// Audio settings
	public static const SAMPLE_RATE :Number = 44100;
	public static const BUFFER_SIZE :int = 4096;	// mono size, not stereo, so less than 4096 plz
	public static const LERP_SAMPLES :Number = 30;	// "Smoothly" transition between pitch/width/etc changes

	// Spectral & formant analysis
	public static const FFT_BINS :int = 1024;
	public static const SPECTRAL_BANDS :int = FFT_BINS/2 - 1;
	public static const FORMANT_DETECT_BANDWIDTH :int = 7;	// Formant detection analyzes this many bands*2-1
	public static const FORMANT_DETECT_DISALLOW_NEIGHBORS :int = 7;	// Disallow formants being this close together
	public static const PITCHED_REGION_OF_OVERTONE :Number = 0.25;	// Separates spectral energy into voiced/unvoiced. <0.5 plz
	public static const IMPORT_HIGHEST_FORMANT_FREQ :Number = 7000.0;
	
	// Fseq parameters
	public static const FRAMES :int = 512;
	public static const VOICED_OPS :int = 8;
	public static const UNVOICED_OPS :int = 8;
	
	// Fseq settings
	public static const ONE_WAY :String = "one way";
	public static const ROUND :String = "round";
	public static const FSEQ_PITCH :String = "fseq pitch";
	public static const FREE_PITCH :String = "free pitch";
	
	// View modes & color palettes, etc
	public static const FREQ :String = "FREQ";
	public static const AMP :String = "AMP";
	
	// Operator types
	public static const PITCH :String = "PITCH";
	public static const VOICED :String = "VOICED";
	public static const UNVOICED :String = "UNVOICED";
	public static const ALL :String = "ALL";
	
	// Editor
	public static const GRAPH_SCALE_X :Number = 2.0;
	public static const GRAPH_AMP_HEIGHT :Number = 100;
	public static const GRAPH_FREQ_HEIGHT :Number = 500;
	public static const VOICED_DOT :String = "VOICED_DOT";
	public static const INACTIVE_BRIGHTNESS :Number = 0.4;
	public static const HIGHEST_FREQ_IN_LINEAR_VIEW :Number = 7000.0;
	
	// Editor tools
	public static const FREEHAND :String = "freehand";
	public static const LINE :String = "line";
	public static const TRANSPOSE :String = "transpose";
	public static const VOWEL :String = "vowel";
	public static const ALL_TOOLS :Array = [FREEHAND,LINE,TRANSPOSE,VOWEL];
	
	
	public function Const()
	{
		super();
	}
	
	public static function color( type:String, id:int=0 ) :uint {
		var rgb:Object;
		
		switch( type ) {
			case Const.PITCH:
				return 0xffffff;
			
			case Const.VOICED:
				return [0xff4801,0xfe1d16,0xfe1f72,0xfd2096,0xf626ff,0xc749ff,0x9350ff,0x6b78ff][id];
				
			case Const.VOICED_DOT:
				var blend:uint = color( Const.VOICED, id );
				rgb = ColorUtil.rgb( blend );
				rgb.r = (rgb.r + 0xff) / 2;
				rgb.g = (rgb.g + 0xff) / 2;
				rgb.b = (rgb.b + 0xff) / 2;
				return (rgb.r << 16) | (rgb.g << 8) | rgb.b;
			
			case Const.UNVOICED:
				//return [0x00feed,0x00f6c0,0x00ec86,0x00db40,0x08c827,0x1cb827,0x459b34,0x787a52][id];	// green -> grey
				rgb = ColorUtil.rgb( Const.color(VOICED, id) );
				var grey:Number = 0.25;
				rgb.r = Num.interpolate( 255*grey, 255*(1-grey), rgb.r/255 );
				rgb.g = Num.interpolate( 255*grey, 255*(1-grey), rgb.g/255 );
				rgb.b = Num.interpolate( 255*grey, 255*(1-grey), rgb.b/255 );
				return (int(rgb.r)<<16) + (int(rgb.g)<<8) + int(rgb.b);
		}
		trace("** SequenceView: What weird color are you looking for? I only accept", Const.PITCH, Const.VOICED, Const.UNVOICED, "...", type, id);
		return 0x444444;
	}
	
}

}

