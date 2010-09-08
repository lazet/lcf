package org.lcf
{
	import flash.events.Event;
	
	import mx.modules.Module;
	
	import org.lcf.util.EventTransfer;

	public class AbstractModule extends mx.modules.Module implements IContainerModule,IEventPrefer
	{

		public var c:IContainer = new Container();
		protected var p:IContainer = null;
		protected var inEventTransfer:EventTransfer = null;
		protected var outEventTransfer:EventTransfer = null;
		
		public function AbstractModule()
		{
			c.put(this.id,this);
		}
		/**
		 * 建立父容器和本容器之间的事件通讯关系
		 */
		public function set parentCenter(parentCenter:IContainer):void
		{
			this.p = parentCenter;
			this.inEventTransfer  = new EventTransfer(this.id +  ".inEventTransfer." + this.className,this.transferInEvents, p, c);
			this.p.put(this.id +  ".inEventTransfer." + this.className,this.inEventTransfer);
			this.outEventTransfer = new EventTransfer(this.id + ".outEventTransfer." + this.className,this.transferOutEvents, c, p);
			this.c.put(this.id + ".outEventTransfer." + this.className, this.outEventTransfer);
		}
		
		public function get transferInEvents():Array
		{
			return new Array();
		}
		
		public function get transferOutEvents():Array
		{
			return new Array();
		}
		
		public function unload():void
		{
			c.remove(this.id);
			p.remove(inEventTransfer.id);
			c.remove(inEventTransfer.id);
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
		/**
		 *	 将对象放入容器
		 */
		public function put(name:String, ins:Object):void{
			this.c.put(name,ins);
		}
		/**
		 *	 将对象放入容器
		 */
		public function remove(name:String):void{
			this.c.remove(name);
		}
		/**
		 *	 将对象放入容器
		 */
		public function get(name:String):Object{
			return this.c.get(name);
		}
		
		/**
		 * 分发事件
		 */
		public function dispatch(e:Event):void{
			this.c.dispatch(e);
		}
		/**
		 * 关闭中心
		 */
		public function close():void{
			this.unload();	
		}
	}
}