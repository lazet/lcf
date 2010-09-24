/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf.util
{
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.Image;
	import mx.controls.Spacer;
	import mx.core.IVisualElement;
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
		public var moduleObject:IVisualElement;
		
		[Inject(name="container")]
		public function set container(c:IContainer):void{
			this.c = c;
		}
		private var c:IContainer;
		[SkinPart(required="false")]
		public var closeButton:Button;
		[SkinPart(required="true")]
		public var title:Label;
		[SkinPart(required="true")]
		public var blank:Label;
		public var iconSource:String;
		[SkinPart(required="true")]
		public var iconImage:Image;
		
		public var selected:Boolean = false;
		
		public function Tab(id:String, name:String,moduleObject:IVisualElement,iconSoucre:String,closable:Boolean)
		{
			super();
			this.id = id;
			this.name = name;
			this.moduleObject = moduleObject;
			this.iconSource= iconSoucre;
			this.closable = closable;
			this.setStyle("skinClass",TabSkin);

			this.addEventListener(KeyboardEvent.KEY_UP,onKeyBoardEvent);
		}
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == closeButton)
			{
				if(this.closable == false){
					this.closeButton.width = 0;
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
			if( instance == blank)
			{
				blank.addEventListener(MouseEvent.CLICK, onClose);
			}
			if (instance == iconImage)
			{
				iconImage.addEventListener(MouseEvent.CLICK,onClick);
				if( iconSource != null){
					this.iconImage.source  = this.iconSource;	
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
			if( instance == blank)
			{
				blank.removeEventListener(MouseEvent.CLICK, onClose);
			}
			if (instance == iconImage)
			{
				iconImage.removeEventListener(MouseEvent.CLICK,onClick);
			}	
		}
		
		public function onClick(e:MouseEvent):void{
			this.c.dispatch(new ModuleEvent(Constants.SELECT_MODULE_EVENT,this.id));
		}
		public function onClose(e:MouseEvent):void{
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
		protected function checkSelectEvent(e:ModuleEvent):void{
			
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
		public function onKeyBoardEvent(e:KeyboardEvent):void{
			this.c.dispatch(e);
		}
	}
}