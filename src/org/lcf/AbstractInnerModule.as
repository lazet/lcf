package org.lcf
{
	import mx.modules.Module;
	
	public class AbstractInnerModule extends Module implements IInnerModule, IEventPrefer
	{
		protected var c:IContainer;
		public function AbstractInnerModule()
		{
			super();
		}
		
		public function set container(c:IContainer):void
		{
			this.c = c;
		}
		
		
		
		public function get preferEventListeners():Array
		{
			return [];
		}
	}
}