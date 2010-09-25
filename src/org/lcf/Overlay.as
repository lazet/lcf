/*
* Copyright (c) 2010 lizhnatao(lizhantao@gmail.com)
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/
package org.lcf
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.*;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.controls.Alert;
	import mx.core.IFlexModuleFactory;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	import mx.utils.ArrayUtil;
	
	import org.lcf.IContainer;
	import org.lcf.IModule;
	import org.lcf.util.EventTransfer;
	import org.lcf.util.ModuleEvent;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.components.List;
	import spark.components.VGroup;
	import spark.components.supportClasses.SkinnableComponent;
	
	/**
	 * 页面覆盖方式的导航
	 */ 
	public class Overlay extends SkinnableComponent implements IModuleManager,IEventPrefer,IModule
	{	
		protected var pointer:int = -1;
		
		protected var hiddenTabs:Array = new Array();
		
		protected var c:IContainer;
		
		[SkinPart(required="true")]
		public var content:VGroup;
		
		public function Overlay()
		{
			super();
			c = new Container();
			this.setStyle("skinClass",OverlaySkin);
			c.put(Constants.OVERLAY,this);
		}
		
		public function open(moduleId:String, moduleName:String, moduleInfo:Object, icon:String=null, reload:Boolean=false, closable:Boolean=true):Boolean
		{
			//检查现有组件，是否存在Id相同的，如果存在，则根据reload加以处理
			if(this.c.get(moduleId) != null){
				if(reload == false){
					this.switchTo(moduleId);
					return true;
					
				}else{
					this.close(moduleId);
				}
			}
			//判断ModuleInfo，如果是字符串，并且是以.swf结尾的，则调用模块加载器进行加载
			if(moduleInfo is String){
				var info:String = moduleInfo as String;
				if(info.toLowerCase().lastIndexOf(".swf") + 4 == info.length){//这是一swf文件路径，需要加载
					this.loadModule(moduleId,moduleName,info,icon,closable);
				}
				else{//这是一个类名，需要实例化
					var ins:IVisualElement = newInstance(info) as IVisualElement;
					if(ins == null){
						return false;
					}
					else{
						this.add(moduleId,moduleName,ins,icon,closable);
					}
				}
			}
				//如果不是字符串，则判断是否是个显示对象，如果是则显示之
			else{
				this.add(moduleId,moduleName,moduleInfo as IVisualElement,icon,closable);
			}
			return true;
		}
		/**
		 * 参数m不能是字符
		 */ 
		public function openModule(m:org.lcf.IModule,icon:String=null, reload:Boolean=false, closable:Boolean=true):Boolean
		{
			if(reload == false){
				if(this.c.get(m.id) != null){
					if(reload == false){
						this.switchTo(m.id);
						return true;
					}else{
						this.close(m.id);
					}
				}
			}
			this.add(m.id,m.name,m as IVisualElement,icon,closable);
			return true;
		}
		
		public function close(moduleId:String):Boolean
		{
			if(this.c.get(moduleId) == null)
				return false;
			var currentModule:ModuleInfo;
			if(pointer >= 0){
				currentModule = this.hiddenTabs[this.pointer] as ModuleInfo;
			}
			var tab:ModuleInfo = c.get(moduleId) as ModuleInfo;
			var oldDisplaySite:int = tab.position;
			//判断相对位置,如果大于0则在当前位置后面，如果小于0则在当前位置前面，等于0代表是当前的
			var compareSite:int = ( oldDisplaySite - this.pointer );

			this.hiddenTabs.splice(oldDisplaySite,1);
			this.refreshSite();
			
			//判断关闭的页签是否是当前页签之前的
			if(compareSite < 0 && currentModule != null){
				this.pointer --;
			}
			
			c.remove(moduleId);
			//判断是否是真正的模块（继承于IModule)，如果是，则关闭之
			var mo:Object = tab.moduleObject;
			if( mo is IModule){
				var m:IModule = mo as IModule;
				m.unload();
				c.remove(Constants.TAB_NAVIGATOR + ".outEventTransfer.to." + moduleId);
				c.remove("to." + moduleId + ".inEventTransfer");
			}	
			
			

			//如果是当前的
			if(compareSite == 0){
				//删除内容
				this.content.removeAllElements();
				//切换页签
				if(this.hiddenTabs.length > 0){
					if(this.hiddenTabs.length > oldDisplaySite && oldDisplaySite >= 0){
						var t:ModuleInfo = this.hiddenTabs[oldDisplaySite] as ModuleInfo;
						currentModule = t;
						this.content.addElement(t.moduleObject);
					}
					else{
						var k:ModuleInfo = this.hiddenTabs[this.hiddenTabs.length -1] as ModuleInfo;
						currentModule = k;
						this.content.addElement(k.moduleObject);
						this.pointer = this.hiddenTabs.length -1;
					}
					this.content.setFocus();
					this.c.dispatch(new org.lcf.util.ModuleEvent(Constants.MODULE_SELECTED_EVENT,currentModule.moduleId));
				}
				else{
					this.pointer = -1;
				}
				this.content.invalidateDisplayList();

			}

			this.invalidateDisplayList();
			this.c.dispatch(new org.lcf.util.ModuleEvent(Constants.MODULE_ClOSED_EVENT,moduleId));

			return true;
		}
		
		public function closeOther(moduleId:String):Boolean
		{
			var closing:Array = new Array();
			//循环关闭其他所有链接（不可以关闭的，不关）
			for(var j:int = 0; j < this.hiddenTabs.length;j++){
				var o:ModuleInfo = this.hiddenTabs[j] as ModuleInfo;
				if(o.moduleId != moduleId && o.closable == true){
					closing.push(o.moduleId);
				}
			}
			for(var i:int = 0; i< closing.length;i++){
				this.close(closing[i] as String);
			}
			return true;
		}
		
		public function closeAll():Boolean
		{
			//循环关闭所有链接（不可以关闭的，不关）

			var closing:Array = new Array();
			for(var j:int = 0; j < this.hiddenTabs.length;j++){
				var o:ModuleInfo = this.hiddenTabs[j] as ModuleInfo;
				if(o.closable == true){
					closing.push(o.moduleId);
				}
			}
			for(var i:int = 0; i< closing.length;i++){
				this.close(closing[i] as String);
			}
			return true;
		}
		
		public function list():XML
		{
			//按顺序列出所有对象
			var result:String = new String();
			result += '<result>';
			
			for(var j:int = 0; j < this.hiddenTabs.length;j++){
				var o:ModuleInfo = this.hiddenTabs[j] as ModuleInfo;
				result += ('<module id="' + o.moduleId + '" label="' + o.moduleName  + '" position="'+ j + '"/>');
			}
			result += '</result>';
			return new XML(result);
			
		}
		
		public function switchTo(moduleId:String):Boolean
		{
			var tab:ModuleInfo = c.get(moduleId) as ModuleInfo;
			if(tab != null){
				var site:int = tab.position;

				if(this.pointer == site)
					return true;			
				
				this.pointer = site;
				//发送事件，选中此组件
				this.c.dispatch(new org.lcf.util.ModuleEvent(Constants.MODULE_SELECTED_EVENT,moduleId));
				
				this.content.removeAllElements();
				this.content.addElement(tab.moduleObject);
				this.content.invalidateDisplayList();
				this.content.setFocus();
				this.invalidateDisplayList();
				
				return true;
			}
			else{
				return false;
			}
		}
		protected function refreshSite():void{
			for(var j:int = 0; j < this.hiddenTabs.length;j++){
				var k:ModuleInfo = this.hiddenTabs[j] as ModuleInfo;
				k.position = j;
			}

		}
		public function get currentModuleInfo():ModuleInfo
		{
			if( this.pointer == -1){
				return null;
			}
			else{
				var t:ModuleInfo = hiddenTabs[this.pointer] as ModuleInfo;
				t.position = this.pointer;
				return t;
			}
		}
		public function get currentPosition():int
		{
			return this.pointer;
		}
		
		
		public function back():Boolean
		{
			if ( this.pointer > 0 && this.hiddenTabs.length > 0) {
				return this.switchTo((this.hiddenTabs[this.pointer - 1] as ModuleInfo).moduleId);
			}
			else{	
				return false;
			}
		}
		public function moduleInfo(moduleId:String):ModuleInfo{
			var t:ModuleInfo = this.c.get(moduleId) as ModuleInfo;
			if( t!= null){
				return t;
			}
			else{
				return null;
			}
		}
		public function forward():Boolean
		{
			if ( this.pointer >= 0 && this.pointer < this.hiddenTabs.length -1) {
				return this.switchTo((this.hiddenTabs[this.pointer + 1] as ModuleInfo).moduleId);
			}
			else{	
				return false;
			}
		}
		public function unloadAll():Boolean{
			this.closeAll();
			this.c.close();
			this.hiddenTabs = null;
			return true;
		}
		
		/******inner function *****/
		protected function loadModule(moduleId:String,moduleName:String, url:String,icon:String,closable:Boolean):void {
			var info:IModuleInfo = ModuleManager.getModule(url);

			if(info.ready){
				add(moduleId, moduleName,info.factory.create() as IVisualElement,icon, closable );
			}
			else{
				var f:Function = function(e:mx.events.ModuleEvent):void{
					info.removeEventListener(mx.events.ModuleEvent.READY,f);
					add(moduleId,moduleName,e.module.factory.create() as IVisualElement,icon, closable);
				};
				info.addEventListener(mx.events.ModuleEvent.READY, f);
				info.load(flash.system.ApplicationDomain.currentDomain);
				

			}
		}

		protected function newInstance(url:String):Object{
			try{
				var clazz:Class =Class(getDefinitionByName(url));
				var ins:Object = new clazz();
				return ins;	
			}catch(error:Error){
				return null;
				
			}
			return null;
		}
		protected function add(moduleId:String,moduleName:String, mo:IVisualElement,icon:String,closable:Boolean):void {
			var o:ModuleInfo = new ModuleInfo(moduleId,moduleName,mo,icon,closable);
			
			if(mo is IModule){
				var module:IModule = mo as IModule;
				try{
					module.id = moduleId;
					module.name = moduleName;
				}
				catch(e:Error){}
				module.container.parentContainer = c;
				//处理容器的事件交换
				var cInEventTransfer:EventTransfer = new EventTransfer("to."  + Constants.TAB_NAVIGATOR + ".inEventTransfer" ,this.transferInEvents, module.container, this.c);
				module.container.put("to." + Constants.TAB_NAVIGATOR + ".inEventTransfer", cInEventTransfer);
				var cOutEventTransfer:EventTransfer = new EventTransfer(Constants.TAB_NAVIGATOR + ".outEventTransfer.to."+ moduleId ,this.transferOutEvents, this.c, module.container);
				c.put(Constants.TAB_NAVIGATOR + ".outEventTransfer.to." + moduleId, cOutEventTransfer);
				
				//处理模块的事件交换
				var inEventTransfer:EventTransfer = new EventTransfer("to." + moduleId + ".inEventTransfer" ,module.transferInEvents, this.c, module.container);
				c.put("to." + moduleId + ".inEventTransfer", inEventTransfer);
				var outEventTransfer:EventTransfer = new EventTransfer("to."  + Constants.TAB_NAVIGATOR + ".outEventTransfer" ,module.transferOutEvents, module.container, this.c);
				module.container.put("to."  + Constants.TAB_NAVIGATOR + ".outEventTransfer", outEventTransfer);
			}
			
			o.position = this.hiddenTabs.length;
			this.hiddenTabs.push(o);
			this.c.put(moduleId,o);
					
			this.switchTo(moduleId);
		}
		/*******************************/
		/**
		 *	获得容器
		 */        
		public function get container():IContainer{
			return this.c;
		}
		/**
		 * 定义可以接收从外部容器传入的事件集合;这个方法要由子类覆盖
		 * 返回集合是事件类型，事件class的集合['checkAccount']
		 */
		public function get transferInEvents():Array{
			return [Constants.SELECT_MODULE_EVENT,Constants.CLOSE_MODULE_EVENT,Constants.OPEN_MODULE_EVENT,KeyboardEvent.KEY_UP];
		}
		
		/**
		 * 定义可以传出给外部容器的事件集合；这个方法要由子类覆盖
		 * 返回集合是事件类型，事件class的集合['checkAccount','addProductItem']
		 */
		public function get transferOutEvents():Array{
			return [Constants.MODULE_SELECTED_EVENT,Constants.MODULE_ClOSED_EVENT];
		}
		public function unload():void{
			this.unloadAll();
		}

		
		/**
		 * 注册事件监听程序定义
		 * 返回结果:
		 * 事件class的集合[new EventListenerModel(),new EventListenerModel()]
		 */ 
		public function get preferEventListeners():Array{
			var selectElm:EventListenerModel = new EventListenerModel(Constants.SELECT_MODULE_EVENT,checkSelectEvent);
			var closeElm:EventListenerModel = new EventListenerModel(Constants.CLOSE_MODULE_EVENT,closeEvent);
			var openElm:EventListenerModel = new EventListenerModel(Constants.OPEN_MODULE_EVENT,openEvent);
			var keyElm:EventListenerModel = new EventListenerModel(KeyboardEvent.KEY_UP,onKeyBoardEvent);
			return [selectElm,closeElm,openElm,keyElm];
		}
		public function checkSelectEvent(e:org.lcf.util.ModuleEvent):void{
			this.switchTo(e.moduleId); 
		}
		public function closeEvent(e:org.lcf.util.ModuleEvent):void{
			this.close(e.moduleId); 
		}
		public function openEvent(e:ModuleEvent):void{
			if(e.moduleId==null && e.moduleInfo is IModule){
				this.openModule(e.moduleInfo as IModule	,e.icon,e.reloadable,e.closable);
			}
			else{
				this.open(e.moduleId,e.moduleName,e.moduleInfo,e.icon,e.reloadable,e.closable);
			}
		}
		/***************************************/
		override protected function partAdded(partName:String, instance:Object):void{
			if(instance == this.content){
				this.content.focusEnabled;
				this.content.addEventListener(KeyboardEvent.KEY_UP,this.onKeyBoardEvent);

			}
		}
		override protected function partRemoved(partName:String, instance:Object):void{
			if(instance == this.content){
				this.content.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyBoardEvent);
			}
		}

		public function onKeyBoardEvent(e:KeyboardEvent):void{
			if(e.target != this.content){
				return;
			}
			switch(e.keyCode){
				case 39:
					this.forward();
					break;
				case 37:
					this.back();
					break;
			}
		}

	}
}