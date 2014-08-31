package com.jonnybomb.ui.components.radiobutton
{
	/**
	 * @author DCD - Jonathan Elbom
	 */
	
	public interface IRadioButtonContentRenderer
	{
		function build(data:Object, w:int = -1, h:int = -1):void
		function finalize():void
	}
}