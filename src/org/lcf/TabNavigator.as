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
	import org.lcf.IOuterModule;
	import org.lcf.util.EventTransfer;
	import org.lcf.util.ModuleEvent;
	import org.lcf.util.Tab;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.HGroup;
	import spark.components.List;
	import spark.components.VGroup;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.DropDownEvent;
	import spark.events.IndexChangeEvent;
	
	[SkinState("open")]
	[SkinState("normal")]
	/**
	 * 页签导航
	 */ 
	public class TabNavigator extends SkinnableComponent implements IModuleManager,IEventPrefer,IOuterModule
	{	
		protected var pointer:int = -1;
		
		protected var hiddenTabs:Array = new Array();

		protected var tabIndexMap:Dictionary = new Dictionary();
		
		protected var c:IContainer;
		
		
		/*****图形元素****/
		[SkinPart(required="true")]
		public var tabs:HGroup;
		[SkinPart(required="true")]
		public var switchButton:Button;
		[SkinPart(required="true")]
		public var content:VGroup;
		[SkinPart(required="true")]
		public var selectableList:List;
		public var switching:Boolean;
		[SkinPart(required="true")]
		public var addButton:Button;
		public var addEnable:Boolean=false;
		public var addFunction:Function;
		//display tab navagetor bar
		public var tabBarVisible:Boolean=true;
		[SkinPart(required="true")]
		public var tabBar:HGroup;
		
		private var tabNumber:int = 6;
		public function TabNavigator()
		{
			super();
			c = new Container();
			this.setStyle("skinClass",TabNavigatorSkin);
			c.put(Constants.TAB_NAVIGATOR,this);
			this.addEventListener(FlexEvent.CREATION_COMPLETE ,onResize);
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
			if(this.c.get(m.id) != null){
				if(reload == false){
					this.switchTo(m.id);
					return true;
				}else{
					this.close(m.id);
					this.add(m.id,m.name,m as IVisualElement,icon,closable);
					return true;
				}
			}
			else{
				this.add(m.id,m.name,m as IVisualElement,icon,closable);
				return true;
			}
		}
		
		public function close(moduleId:String):Boolean
		{
			if(this.c.get(moduleId) == null)
				return false;
			var currentModule:Tab;
			if(pointer >= 0){
				currentModule = this.tabs.getElementAt(this.pointer) as Tab;
			}
			var oldDisplaySite:int = this.tabIndexMap[moduleId];
			//判断相对位置,如果大于0则在当前位置后面，如果小于0则在当前位置前面，等于0代表是当前的
			var compareSite:int = ( oldDisplaySite - this.pointer );
			//删除并平移，先判断在当前图元上是否存在,如果存在，则取出并删除
			var tab:Tab = c.get(moduleId) as Tab;
			if(oldDisplaySite < this.tabNumber){
				this.tabs.removeElementAt(oldDisplaySite);
			}
			else{
				this.hiddenTabs.splice(oldDisplaySite - this.tabNumber,1);
			}
		
			//如果当前的Tab容器元素个数不足this.tabNumber个，则补充1个Tab
			if(this.tabs.numElements < this.tabNumber && this.hiddenTabs.length > 0){
				//补充第一个没放进去的
				this.tabs.addElement(this.hiddenTabs[0]);
				this.hiddenTabs.splice(0,1);

			}
			delete this.tabIndexMap[moduleId];
			this.refreshSite();
			
			//判断关闭的页签是否是当前页签之前的
			if(compareSite < 0 && currentModule != null){
				this.pointer --;
			}
			
			//从Tab容器中删除图形对象
			c.remove(moduleId);
			//判断是否是真正的模块（继承于IModule)，如果是，则关闭之
			var mo:Object = tab.moduleObject;
			if( mo is IInnerModule){
				c.remove(moduleId + ".object");
			}
			else if( mo is IOuterModule){
				var m:IOuterModule = mo as IOuterModule;
				m.unload();
				c.remove(Constants.TAB_NAVIGATOR + ".outEventTransfer.to." + moduleId);
				c.remove("to." + moduleId + ".inEventTransfer");
			}	
			
			

			//如果是当前的
			if(compareSite == 0){
				//删除内容
				this.content.removeAllElements();
				//切换页签
				if(this.tabs.numElements > 0){
					if(this.tabs.numElements > oldDisplaySite && oldDisplaySite >= 0){
						var t:Tab = this.tabs.getElementAt(oldDisplaySite) as Tab;
						currentModule = t;
						currentModule.selected = true;
						currentModule.invalidateSkinState();
						this.content.addElement(t.moduleObject);
					}
					else{
						var k:Tab = this.tabs.getElementAt(this.tabs.numElements -1) as Tab;
						currentModule = k;
						currentModule.selected = true;
						currentModule.invalidateSkinState();
						this.content.addElement(k.moduleObject);
						this.pointer = this.tabs.numElements -1;
					}
					this.content.setFocus();
					this.c.dispatch(new org.lcf.util.ModuleEvent(Constants.MODULE_SELECTED_EVENT,currentModule.id));
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
			for(var key:String in this.tabIndexMap){
				var o:Tab = this.c.get(key) as Tab;
				if(o.id != moduleId && o.closable == true){
					closing.push(o.id);
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
			for(var key:String in this.tabIndexMap){
				var o:Tab = this.c.get(key) as Tab;
				if(o.closable == true){
					closing.push(o.id);
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
			
			for(var key:String in this.tabIndexMap){
				var o:Tab = this.c.get(key) as Tab;
				result += ('<module id="' + o.id + '" label="' + o.name  + '" position="'+ this.tabIndexMap[key] + '"/>');
			}
			result += '</result>';
			return new XML(result);
			
		}
		
		public function switchTo(moduleId:String):Boolean
		{
			var tab:Tab = c.get(moduleId) as Tab;
			if(tab != null){
				var site:int = this.tabIndexMap[moduleId];

				if(this.pointer == site)
					return true;
				
				if(site >= this.tabNumber){
					
					if(this.tabs.numElements  == this.tabNumber){
						var secondTab:Tab = this.tabs.getElementAt(1) as Tab;
						secondTab.selected = false;
						this.hiddenTabs.push(secondTab);
						this.tabs.removeElementAt(1);
					}
					this.tabs.addElement(tab);
					if(site != 99){
						this.hiddenTabs.splice(site - this.tabNumber,1);
					}
					
					site = this.tabs.numElements -1;
					this.tabs.invalidateDisplayList();
					
				}
				
				this.refreshSite();
				this.pointer = site;
				//发送事件，选中此组件
				this.c.dispatch(new org.lcf.util.ModuleEvent(Constants.MODULE_SELECTED_EVENT,moduleId));
				
				this.content.removeAllElements();
				this.content.addElement(tab.moduleObject);
				this.content.invalidateDisplayList();
				this.content.setFocus();
				this.invalidateDisplayList();
				
				//如果状态不是normal则关闭
				closeSwitchList();
				return true;
			}
			else{
				return false;
			}
		}
		protected function refreshSite():void{
			
			//this.tabIndexMap = new Dictionary();
			for(var i:int = 0;i < this.tabs.numElements;i++){
				var t:Tab = this.tabs.getElementAt(i) as Tab;
				this.tabIndexMap[t.id] = i;
			}
			for(var j:int = 0; j < this.hiddenTabs.length;j++){
				var k:Tab = this.hiddenTabs[j] as Tab;
				this.tabIndexMap[k.id] = j + this.tabNumber;
			}

		}
		public function get currentModuleInfo():ModuleInfo
		{
			if( this.pointer == -1){
				return null;
			}
			else{
				var t:Tab = this.tabs.getElementAt(this.pointer) as Tab;
				var mi:ModuleInfo = new ModuleInfo(t.id,t.name,t.moduleObject,t.iconSource,t.closable,this.pointer);
				return mi;
			}
		}
		public function get currentPosition():int
		{
			return this.pointer;
		}
		
		
		public function back():Boolean
		{
			if ( this.pointer > 0 && this.tabs.numElements > 0) {
				return this.switchTo((this.tabs.getElementAt(this.pointer - 1) as Tab).id);
			}
			else{	
				return false;
			}
		}
		public function moduleInfo(moduleId:String):ModuleInfo{
			var t:Tab = this.c.get(moduleId) as Tab;
			if( t!= null){
				var mi:ModuleInfo = new ModuleInfo(t.id,t.name,t.moduleObject,t.iconSource,t.closable,this.tabIndexMap[moduleId]);
				return mi;
			}
			else{
				return null;
			}
		}
		public function forward():Boolean
		{
			if ( this.pointer >= 0 && this.pointer < this.tabs.numElements -1) {
				return this.switchTo((this.tabs.getElementAt(this.pointer + 1) as Tab).id);
			}
			else if ( this.pointer == this.tabs.numElements -1 && this.hiddenTabs.length > 0){
				return this.switchTo((this.hiddenTabs[0] as Tab).id);
			}
			else{	
				return false;
			}
		}
		public function unloadAll():Boolean{
			this.closeAll();
			this.c.close();
			this.tabIndexMap = null;
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
			var o:Tab = new Tab(moduleId,moduleName,mo,icon,closable);
			
			if(mo is IModule){
				var module:IModule = mo as IModule;
				try{
					module.id = moduleId;
					module.name = moduleName;
				}
				catch(e:Error){}
			}
			if(mo is IInnerModule){
				var innerModule:IInnerModule = mo as IInnerModule;
				innerModule.container = c;
				c.put(moduleId + ".object",innerModule)
			}
			else if(mo is IOuterModule){
				var outerModule:IOuterModule = mo as IOuterModule;
				if(outerModule.container != null && outerModule.container != c){
					outerModule.container.parentContainer = c;
					//处理容器的事件交换
					var cInEventTransfer:EventTransfer = new EventTransfer("to."  + Constants.TAB_NAVIGATOR + ".inEventTransfer" ,this.transferInEvents, outerModule.container, this.c);
					outerModule.container.put("to." + Constants.TAB_NAVIGATOR + ".inEventTransfer", cInEventTransfer);
					var cOutEventTransfer:EventTransfer = new EventTransfer(Constants.TAB_NAVIGATOR + ".outEventTransfer.to."+ moduleId ,this.transferOutEvents, this.c, outerModule.container);
					c.put(Constants.TAB_NAVIGATOR + ".outEventTransfer.to." + moduleId, cOutEventTransfer);
					
					//处理模块的事件交换
					var inEventTransfer:EventTransfer = new EventTransfer("to." + moduleId + ".inEventTransfer" ,outerModule.transferInEvents, this.c, outerModule.container);
					c.put("to." + moduleId + ".inEventTransfer", inEventTransfer);
					var outEventTransfer:EventTransfer = new EventTransfer("to."  + Constants.TAB_NAVIGATOR + ".outEventTransfer" ,outerModule.transferOutEvents, outerModule.container, this.c);
					outerModule.container.put("to."  + Constants.TAB_NAVIGATOR + ".outEventTransfer", outEventTransfer);
				}
			}
			this.c.put(moduleId,o);
			this.tabIndexMap[moduleId] = 99;
					
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
			if(instance == this.switchButton){
				
				this.switchButton.addEventListener(MouseEvent.CLICK, onSwitch);				
			}
			else if(instance == this.selectableList){
				this.selectableList.dataProvider = new XMLListCollection(this.list().children());
				this.selectableList.selectedIndex = -1;
				this.selectableList.addEventListener(spark.events.IndexChangeEvent.CHANGE,onSelectTab);
			}
			else if(instance == this.tabs){
				this.tabs.addEventListener(MouseEvent.CLICK, closeSwitchList);
			}
			else if(instance == this.content){
				this.content.addEventListener(MouseEvent.CLICK, closeSwitchList);
				this.content.focusEnabled;
				this.content.addEventListener(KeyboardEvent.KEY_UP,this.onKeyBoardEvent);

			}
			else if(instance == this.addButton){
				if(this.addEnable == false){
					this.addButton.visible= false;
				}
				if(this.addFunction != null){
					this.addButton.addEventListener(MouseEvent.CLICK, onAdd);
				}
			}
		}
		override protected function partRemoved(partName:String, instance:Object):void{
			if(instance == this.switchButton){
				this.switchButton.removeEventListener(MouseEvent.CLICK, onSwitch);				
			}
			else if(instance == this.selectableList){
				this.selectableList.removeEventListener(spark.events.IndexChangeEvent.CHANGE,onSelectTab);
			}
			else if(instance == this.tabs){
				this.tabs.removeEventListener(MouseEvent.CLICK, closeSwitchList);
			}
			else if(instance == this.content){
				this.content.removeEventListener(MouseEvent.CLICK, closeSwitchList);
				this.content.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyBoardEvent);
			}
			else if(instance == this.addButton){
				if(this.addFunction != null){
					this.addButton.removeEventListener(MouseEvent.CLICK, onAdd);
				}
			}
		}
		override protected function getCurrentSkinState():String{
			if(this.switching){
				return "open";
			}
			return "normal";
		}
		public function onSwitch(e:MouseEvent):void{
			this.switching = !this.switching;
			this.invalidateSkinState();
		}
		public function onAdd(e:MouseEvent):void{
			this.addFunction();
		}
		public function closeSwitchList(e:Event = null):void{
			if(this.switching){
				this.switching = false;
				this.invalidateSkinState();
			}
		}
		public function onSelectTab(e:IndexChangeEvent):void{
			var currentDataItem:Object = e.currentTarget.selectedItem;
			var moduleId:String = currentDataItem.@id;
			this.switchTo(moduleId);	
		}
		public function onResize(e:FlexEvent):void{
			if(this.width > 0)
				this.tabNumber = Math.floor((this.width-80)/80);
			
			if(this.tabNumber < 2)
				this.tabNumber = 2;
			else if (this.tabNumber > 20){
				this.tabNumber = 20
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