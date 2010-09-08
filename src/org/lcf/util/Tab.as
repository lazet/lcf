package org.lcf.util
{
	
	import flash.events.MouseEvent;
	
	import mx.controls.Image;
	import mx.skins.spark.ButtonBarFirstButtonSkin;
	
	import org.lcf.Constants;
	import org.lcf.EventListenerModel;
	import org.lcf.IContainer;
	import org.lcf.IEventPrefer;
	import org.lcf.util.ModuleEvent;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	
	[SkinState("selected")]
	[SkinState("idle")]
	public class Tab extends SkinnableComponent implements IEventPrefer
	{
		public var closable:Boolean;
		
		[Inject(name="container")]
		public function set container(c:IContainer):void{
			this.c = c;
		}
		private var c:IContainer;
		[SkinPart(required="false")]
		public var closeButton:Button;
		[SkinPart(required="true")]
		public var title:Label;
		[Binding]
		public var iconSource:String;
		
		public var icon:Image;
		
		public var selected:Boolean = true;
		
		public function Tab(id:String, name:String,iconSoucre:String,closable:Boolean)
		{
			super();
			this.id = id;
			this.name = name;
			this.iconSource= iconSoucre;
			this.closable = closable;
			this.setStyle("skinClass",TabSkin);
		}
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == closeButton)
			{
				if(this.closable == false){
					this.closeButton.visible=false;
				}
				closeButton.addEventListener(MouseEvent.CLICK, onClose);
			}
			if (instance == title)
			{
				title.addEventListener(MouseEvent.CLICK, onClick);
				if(name.length>10){
					this.title.text = name.substr(0,8) + '..';
				}
				else
					this.title.text = name;
				this.title.toolTip = name;
			}
			if (instance == icon)
			{
				icon.addEventListener(MouseEvent.CLICK,onClick);
				if( iconSource != null){
					this.icon.source  = this.iconSource;	
				}
				
			}	
			
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == closeButton)
			{
				closeButton.removeEventListener(MouseEvent.CLICK, onClose);
			}
			if (instance == title)
			{
				title.removeEventListener(MouseEvent.CLICK, onClick);
			}
			if (instance == icon)
			{
				icon.removeEventListener(MouseEvent.CLICK,onClick);
			}	
		}
		
		public function onClick(e:MouseEvent):void{
			this.c.dispatch(new ModuleEvent(Constants.SELECT_MODULE_EVENT,this.id));
		}
		public function onClose(e:MouseEvent){
			this.c.dispatch(new ModuleEvent(Constants.CLOSE_MODULE_EVENT,this.id));
		}
		/**
		 * 注册事件监听程序定义
		 * 返回结果:
		 * 事件class的集合[EventListenerModel,...]
		 */ 
		public function get preferEventListeners():Array{
			var selectElm:EventListenerModel = new EventListenerModel(Constants.MODULE_SELECTED_EVENT,checkSelectEvent);
			return [selectElm];
		}
		function checkSelectEvent(e:ModuleEvent):void{
			if(e.moduleId != this.id){
				this.selected = false;
			}
			else{
				this.selected = true;
			}
			this.invalidateSkinState();
		}
		override protected function getCurrentSkinState():String
		{
			if (selected)
			{
				return "selected";
			}
			
			return "idle";
		}
	}
}