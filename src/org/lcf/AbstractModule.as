package org.lcf
{
	import flash.events.Event;
	
	import mx.modules.Module;
	
	import org.lcf.util.EventTransfer;

	public class AbstractModule extends mx.modules.Module implements IModule,IEventPrefer
	{

		public var c:IContainer = new Container();
		
		public function AbstractModule()
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