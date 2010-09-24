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
		
		/**
		 *	获得容器
		 */        
		function get container():IContainer;
		/**
		 * 定义可以接收从父容器传入的事件集合;这个方法要由子类覆盖
		 * 返回集合是事件类型，事件class的集合['checkAccount']
		 */
		function get transferInEvents():Array;
		
		/**
		 * 定义可以传出给父容器的事件集合；这个方法要由子类覆盖
		 * 返回集合是事件类型，事件class的集合['checkAccount','addProductItem']
		 */
		function get transferOutEvents():Array;
		/**
		 * Modules need a method for cleanup and removal of the module from 
		 * memory to make them available for garbage collection. 
		 * 
		 */        
		function unload():void;
		
		function get name():String;
		
		function set name(name:String):void;
		
		function get id():String;
		
		function set id(id:String):void;
	}
}