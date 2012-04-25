package fseq.model
{

import fseq.view.ToolButtonView;

public class EditType extends Object
{
	
	public static const EDIT_FREEHAND_DRAW :String = "EDIT_FREEHAND_DRAW";
	public static const EDIT_LINE_DRAW :String = "EDIT_LINE_DRAW";
	public static const EDIT_TRANSPOSE :String = "EDIT_TRANSPOSE";
	public static const EDIT_VOWEL_DRAW :String = "EDIT_VOWEL_DRAW";
	public static const EDIT_FUNC_DRAW :String = "EDIT_FUNC_DRAW";
	
	public function EditType()
	{
		super();
	}
	
	public static function typeForTool( tool:String ) :String {
		switch( tool ) {
			case ToolButtonView.FREEHAND:		return EDIT_FREEHAND_DRAW;
			case ToolButtonView.LINE:			return EDIT_LINE_DRAW;
			case ToolButtonView.TRANSPOSE:		return EDIT_TRANSPOSE;
			case ToolButtonView.VOWEL_DRAW:		return EDIT_VOWEL_DRAW;
			case ToolButtonView.FUNC_DRAW:		return EDIT_FUNC_DRAW;
		}
		
		trace("** EditType.typeForTool: I don't recognize this tool:", tool);
		return null;
	}
}

}

