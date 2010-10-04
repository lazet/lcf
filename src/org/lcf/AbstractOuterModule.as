/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf
{
	import flash.events.Event;
	
	import mx.modules.Module;
	
	import org.lcf.util.EventTransfer;

	public class AbstractOuterModule extends mx.modules.Module implements IOuterModule,IEventPrefer
	{

		public var c:IContainer = new Container();
		
		public function AbstractOuterModule()
		{
			super();
			c.put(Constants.MODULE_SELF,this);
		}
		/**
		 *	获得容器
		 */        
		public function get container():IContainer{
			return c;	
		}
		public function get transferOutEvents():Array
		{
			return new Array();
		}
		public function get transferInEvents():Array
		{
			return new Array();
		}
		public function unload():void
		{
			c.close();
		}
		/**
		 * 注册事件监听程序定义
		 * 返回结果:
		 * 事件class的集合[{eventType='checkAccount',listener=function1}]
		 */ 
		public function get preferEventListeners():Array{
			return new Array();
			
		}
		
	}
}