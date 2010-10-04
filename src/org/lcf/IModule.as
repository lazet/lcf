/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf
{
	import flash.utils.Dictionary;

	/**
	 * 多中心 的环境接口
	 */
	public interface IModule
	{
		
		function get name():String;
		
		function set name(name:String):void;
		
		function get id():String;
		
		function set id(id:String):void;
	}
}