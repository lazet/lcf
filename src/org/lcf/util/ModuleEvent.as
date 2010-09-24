/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf.util
{
	import flash.events.Event;
	
	public class ModuleEvent extends Event
	{
		public var moduleId:String;
		
		public var moduleName:String;
		
		public var moduleInfo:Object;
		
		public var closable:Boolean;
		
		public var reloadable:Boolean;
		
		public var icon:String;
		
		public function ModuleEvent(type:String,moduleId:String,moduleName:String = null, moduleInfo:String = null,closable:Boolean = true, reloadable:Boolean = true,  bubbles:Boolean=false, cancelable:Boolean=false,icon:String = null)
		{
			super(type, bubbles, cancelable);
			this.moduleId = moduleId;
			this.moduleName = moduleName;
			this.moduleInfo = moduleInfo;
			this.closable = closable;
			this.reloadable = reloadable;
			this.icon = icon;
		}
	}
}