package org.lcf.util
{
	import flash.events.Event;
	
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	public class ModuleEvent extends Event
	{
		public var moduleId:String;
		
		public var moduleName:String;
		
		public var moduleInfo:Object;
		
		public var closable:Boolean;
		
		public var reloadable:Boolean;
		
		public function ModuleEvent(type:String,moduleId:String,moduleName:String = null, moduleInfo:String = null,closable:Boolean = true, reloadable:Boolean = true,  bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.moduleId = moduleId;
			this.moduleName = moduleName;
			this.moduleInfo = moduleInfo;
			this.closable = closable;
			this.reloadable = reloadable;
		}
	}
}