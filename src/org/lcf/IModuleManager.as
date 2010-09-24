/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf
{
	import mx.core.IVisualElement;
	/**
	 *  模块管理器(用途：作为一个可显示模块管理器容器的内部实现。
	 */ 
	public interface IModuleManager
	{
		/**
		 * 打开一个新模块
		 */
		function open(moduleId:String, moduleName:String, moduleInfo:Object, icon:String=null,reload:Boolean=false,closable:Boolean=true):Boolean;
		/**
		 * 增加并展示此可视化对象
		 */
		function openModule(m:IModule,icon:String=null, reload:Boolean=false,closable:Boolean=true):Boolean;
		/**
		 * 关闭此可视化模块
		 */ 
		function close(moduleId:String):Boolean;
		/**
		 * 关闭其他可视化模块
		 */ 
		function closeOther(moduleId:String):Boolean;
		/**
		 * 关闭所有模块
		 */ 
		function closeAll():Boolean;
		/**
		 * 列出所有模块
		 */ 
		function list():XML;
		/**
		 * 切换到某个模块
		 */ 
		function switchTo(moduleId:String):Boolean;
		/**
		 * 获取当前模块,没有时，返回null
		 * 返回对象的属性:moduleId, moduleName, moduleObject,closable,position
		 */ 
		function get currentModuleInfo():ModuleInfo;
		/**
		 * 获取当前位置,返回-1表示没有指向任何模块
		 */ 
		function get currentPosition():int;
		/**
		 * 退到上个模块
		 */ 
		function back():Boolean;
		/**
		 * 前进到下一模块
		 */ 
		function forward():Boolean;
		
		function unloadAll():Boolean;
		/**
		 * 获取当前模块,没有时，返回null
		 * 返回对象的属性:moduleId, moduleName, moduleObject,position
		 */ 
		function moduleInfo(moduleId:String):ModuleInfo;
	}
}