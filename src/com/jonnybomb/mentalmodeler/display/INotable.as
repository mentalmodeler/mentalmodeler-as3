package com.jonnybomb.mentalmodeler.display
{
	public interface INotable
	{
		function get title():String
		function get notes():String
		function set notes(value:String):void
		function get units():String
		function set units(value:String):void
		function get confidence():Number
		function set confidence(value:Number):void
	}
}