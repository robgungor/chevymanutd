package custom
{
	
	/**
	 * ...
	 * @author Jonathan Achai
	 */
		
	import com.adobe.images.PNGEncoder;
	import com.oddcast.event.AutophotoEvent;
	import com.oddcast.graphics.CurveDrawer;
	import com.oddcast.graphics.CurveDrawerWithAnchors;
	import com.oddcast.graphics.ICurveDrawer;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.ui.Mouse;
	import flash.utils.*;
	
	 
	public class FaceMasker extends MovieClip 
	{
		
		private var _objPointIconClass:Class;
		private var _arrPoints:Array;		
		private var _arrDots:Array;
		private var _mcSelectedDot:MovieClip;
		private var cdraw:ICurveDrawer;//WithAnchors;
		private var _grapchis:Object;
		private var _graphicsOutline:Object;
		private var _sprtAnchorsHolder:Sprite;
		private var _sprtMask:Sprite;
		private var _sprtLine:Sprite;
		private var _sprtClickingArea:Sprite;
		private var _bUseEarPoints:Boolean;
		private var _pCenter:Point; //nose bridge
		private var _pContainerSize:Point;	
		private var _pPhotoSize:Point;
		private var _pPhotoToContainerAdjustment:Point;
		private var _pAdjustedContainerSize:Point;
		private var _timerDragging:Timer;	
		private var _iDragcounter:int = 0;		
		private var _bMakeBottomLineFlat:Boolean;
		
		private const EAR_POINTS:Array = [2, 3, 9, 10];
		private const EAR_POINTS_10:Array = [1, 2, 6, 7];
		private const EAR_POINTS_JJ:Array = [1,6];
		private const EAR_SIMPLE_SIZE_MULTI:Number = 0.25; //the size of year is this multiplier * the distance between the first 2 points
		private const FACE_FILL_COLOR:int = 0x0000ff;
		private const MASK_BG_COLOR:int = 0x000000;
		private const DRAG_INTERVAL:int = 50;
		private const REDRAW_EVERY_N_DRAG:int = 6;
		private var MASK_GLOW_ALPHA:Number = 0.8;
		private var MASK_GLOW_BLUR_RADIUS:Number = 5;
		
		private var _bDynamicPoints:Boolean;	
		private var _bCtrlPressed:Boolean;	
		private var _bShiftPressed:Boolean;		
		private var _bShowOutline:Boolean;
		private var _iOutlineColor:int;
		private var _arrOrigPoints:Array;
		
		private var _bHideCursorWhenDragging:Boolean;
		private var _nPointsScale:Number = 1;
		private var _sMaskingMode:String;
		private var _iMacFixDoOnceNextFrame:int = -1;
		private var _mcMacFixLastSelectedDot:MovieClip;
		
		function FaceMasker() {
			_arrPoints = new Array();
			_arrDots = new Array();
			_sprtAnchorsHolder = new Sprite();
			_sprtMask = new Sprite();
			_sprtLine = new Sprite();
			_sprtClickingArea = new Sprite();
			_timerDragging = new Timer(DRAG_INTERVAL);
			_timerDragging.addEventListener(TimerEvent.TIMER,onDragTimer);
			this.addChild(_sprtClickingArea);
			this.addChild(_sprtLine);
			this.addChild(_sprtAnchorsHolder);
			this.addChild(_sprtMask);
		}
		
		public function destroy():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN, pointPressed);
			this.removeEventListener(MouseEvent.MOUSE_UP,pointReleased);
			if (_timerDragging!=null)
			{
				_timerDragging.stop();
				_timerDragging.removeEventListener(TimerEvent.TIMER,onDragTimer);
			}
			pointReleased(null);
			_arrDots = null;
			_arrPoints = null;
			_objPointIconClass = null
			cdraw = null;
			if (_sprtAnchorsHolder != null)
			{
				if (this.contains(_sprtAnchorsHolder))
				{
					this.removeChild(_sprtAnchorsHolder);
				}
			}
			if (_sprtMask != null) {
				if (this.contains(_sprtMask)) {
					this.removeChild(_sprtMask);
				}
			}
			
			if (_sprtClickingArea != null) {
				if (this.contains(_sprtClickingArea)) {
					this.removeChild(_sprtClickingArea);
				}
			}
			
			if (_sprtLine != null) {
				if (this.contains(_sprtLine)) {
					this.removeChild(_sprtLine);
				}
			}
			this.removeEventListener(Event.ENTER_FRAME, dragOnEnter);
			if (_bHideCursorWhenDragging)
			{
				flash.ui.Mouse.show();
			}
			initKeyListeners(false);
		}
		
		public function setMaskingMode(mode:String):void{
			if (mode!=null)
			{
				_sMaskingMode = mode.toUpperCase();
			}
		}
		
		public function scalePoints(scale:Number):void
		{
			_nPointsScale = 1/scale;
			for (var i:int=0; i<_arrDots.length; ++i)
			{
				var pointMC:MovieClip = _arrDots[i];
				pointMC.scaleX = pointMC.scaleY = _nPointsScale
			}
		}
		
		private function onKeyUp(evt:KeyboardEvent):void{
			_bCtrlPressed = evt.ctrlKey;
			_bShiftPressed = evt.shiftKey;
		}
		
		private function onFocusOut(evt:FocusEvent):void
		{
			_bCtrlPressed = false;
			_bShiftPressed = false;
		}
		
		private function onKeyDown(evt:KeyboardEvent):void
		{
			//trace("FaceMasker:onKeyDown");
			_bCtrlPressed = evt.ctrlKey;
			_bShiftPressed = evt.shiftKey;			
		}
		
		private function tracePoints(title:String, arr:Array):void
		{
			for (var i:int=0; i<arr.length;++i)
			{
				//trace("FaceMasker::"+title+" " + i +"->"+arr[i].toString()); 
			}
		}
		
		public function init():void
		{
			this.visible = true;
			if (_objPointIconClass == null)
			{
				return;
			}
			
			_arrOrigPoints = new Array();
			//tracePoints("init",_arrOrigPoints);
			initGraphics();						
			for (var i:int = 0; i < _arrPoints.length;++i)
			{
				var pointMC:MovieClip = new _objPointIconClass() as MovieClip;
				pointMC.x = _arrPoints[i].x;
				pointMC.y = _arrPoints[i].y;				
				pointMC.buttonMode = true;
				pointMC.useHandCursor = true;
				pointMC.scaleX = pointMC.scaleY = _nPointsScale
				pointMC.name = String(i);
				_arrDots.push(pointMC)
				_sprtAnchorsHolder.addChild(pointMC);	
				_arrOrigPoints.push(new Point(_arrPoints[i].x,_arrPoints[i].y));
			}
			if (_sMaskingMode!=null && _sMaskingMode=="JJ")
			{
				cdraw = new CurveDrawerWithAnchors();	
			}
			else
			{
				cdraw = new CurveDrawer();
			}
			cdraw.setSprite(_sprtMask);
			if (_bShowOutline)
			{
				cdraw.setOutlineSprite(_sprtLine);
			}
			cdraw.setBottomLineFlat(_bMakeBottomLineFlat);
			cdraw.setPoints(_arrPoints);			
			cdraw.drawCurvedShape(true);
			
			
			
			
			_sprtClickingArea.graphics.beginFill(0xff0000,0);
			_sprtClickingArea.graphics.drawRect(_pPhotoToContainerAdjustment.x,_pPhotoToContainerAdjustment.y,_pAdjustedContainerSize.x-_pPhotoToContainerAdjustment.x, _pAdjustedContainerSize.y-_pPhotoToContainerAdjustment.y);
			//_sprtClickingArea.graphics.drawRect(0,0,_pContainerSize.x, _pContainerSize.y);//_pPhotoToContainerAdjustment.x,_pAdjustedContainerSize.y,_pAdjustedContainerSize.x-_pPhotoToContainerAdjustment.x, _pAdjustedContainerSize.y-_pPhotoToContainerAdjustment.y);
			_sprtClickingArea.graphics.endFill();
			
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,pointPressed);
			this.addEventListener(MouseEvent.MOUSE_UP,pointReleased);			
			_sprtClickingArea.addEventListener(MouseEvent.CLICK,mouseClicked);		
			_timerDragging.start();	
			
			
		}
		
		public function resetMask():void
		{
			//tracePoints("reset",_arrOrigPoints);
			removePoints();
			_arrPoints = new Array();
			_mcMacFixLastSelectedDot = null;
			_mcSelectedDot = null;
			_arrDots = new Array();
			for (var i:int = 0; i < _arrOrigPoints.length;++i)
			{
				var pointMC:MovieClip = new _objPointIconClass() as MovieClip;
				pointMC.x = _arrOrigPoints[i].x;
				pointMC.y = _arrOrigPoints[i].y;				
				pointMC.buttonMode = true;
				pointMC.useHandCursor = true;
				pointMC.scaleX = pointMC.scaleY = _nPointsScale
				pointMC.name = String(i);
				_arrDots.push(pointMC)
				_sprtAnchorsHolder.addChild(pointMC);	
				_arrPoints.push(new Point(_arrOrigPoints[i].x,_arrOrigPoints[i].y));
			}
			cdraw.setPoints(_arrPoints);
			
			if (cdraw!=null)
			{
				initGraphics(true);
				cdraw.drawCurvedShape(true);
			}
		}
		
		public function initKeyListeners(b:Boolean = true):void
		{
			if (this.stage!=null)
			{
				if (b)
				{
					//_sprtClickingArea.stage.focus = _sprtClickingArea;
					this.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					this.stage.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				}
				else
				{
					this.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
					this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					this.stage.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);	
				}		
				var o:Object = this.stage.focus;
			}
			//trace("focus = "+o);
				
		}
		
		private function sortDist(a:Object, b:Object):Number
		{
			if (a.dist>b.dist)
				return 1;
			else if (a.dist<b.dist)
				return -1;
			else
				return 0;
		}
		
		private function removePoint(mc:MovieClip):void
		{
			if (_arrPoints.length<4)
			{
				return;
			}
			if (_sMaskingMode!=null && _sMaskingMode=="JJ" && _arrPoints.length<5)
			{
				return;
			}
			
			var pointToRemove:Point = new Point(mc.x,mc.y);
			//trace("FaceMasker::removePoint "+pointToRemove.toString())
			var newPointsArr:Array = new Array();
			var i:int;
			
			var pointIndexToRemove:int;
			var nextPointIndexToRemove:int = -1;
			for (i=0; i<_arrPoints.length; ++i)
			{
				//trace("FaceMasker::removePoint "+_arrPoints[i].toString())
				if (int(Point(_arrPoints[i]).x) == int(pointToRemove.x) && int(Point(_arrPoints[i]).y) == int(pointToRemove.y))
				{
					pointIndexToRemove = i;	
					if (_sMaskingMode!=null && _sMaskingMode=="JJ")
					{
						if ((i+1)<_arrPoints.length)
						{
							nextPointIndexToRemove = i+1;
						}
						else
						{								
							nextPointIndexToRemove = 0;
							
						}
					}
				}							
			}
			
			for (i=0; i<_arrPoints.length; ++i)
			{
				if (i!=pointIndexToRemove && i!=nextPointIndexToRemove)
				{					
					newPointsArr.push(_arrPoints[i]);		
				}
			}
			
			
			
			
			removePoints();
			_arrPoints = newPointsArr.slice();
			cdraw.setPoints(_arrPoints);
			_arrDots = new Array();
			for (i = 0; i < _arrPoints.length;++i)
			{
				var pointMC:MovieClip = new _objPointIconClass() as MovieClip;
				pointMC.x = _arrPoints[i].x;
				pointMC.y = _arrPoints[i].y;				
				pointMC.buttonMode = true;
				pointMC.useHandCursor = true;
				pointMC.scaleX = pointMC.scaleY = _nPointsScale
				pointMC.name = String(i);
				_arrDots.push(pointMC)
				_sprtAnchorsHolder.addChild(pointMC);	
			}
			
			if (cdraw!=null)
			{
				initGraphics(true);
				cdraw.drawCurvedShape(true);
			}
		}
		/*
			New algorithm
			1. find closest point
			2. check one point before and one point after if the newly created point x lies between the points and if newly cerated point y lies between the points
			3. the point after or point before which meets more of the criterion of being in between wins and becomes the point it is added between
		*/
		private function addPoint(p:Point):void
		{
			//find closest point
			var tempPointArr:Array = new Array();
			var i:int;
			for (i=0; i<_arrPoints.length; ++i)
			{
				tempPointArr.push({index:i, dist:Point.distance(p,_arrPoints[i])});
				//trace("FaceMasker::addPoint "+p.toString()+" --> ["+i+"]"+_arrPoints[i].toString()+" dist="+Point.distance(p,_arrPoints[i]));				
			}
			tempPointArr.sort(sortDist);
			var minIndex:int = tempPointArr[0].index;
			var closestPoint:Point = _arrPoints[minIndex];
			var insertIndex:int;
			//check one point before
			if (minIndex>0)
			{
				var beforeMatch:int=0;
				var beforePoint:Point = _arrPoints[minIndex-1];
				if ((p.x > beforePoint.x && p.x < closestPoint.x) || (p.x < beforePoint.x && p.x > closestPoint.x))
				{
					beforeMatch++;
				}
				if ((p.y > beforePoint.y && p.y < closestPoint.y) || (p.y < beforePoint.y && p.y > closestPoint.y))
				{
					beforeMatch++;
				}
				if (minIndex<(_arrPoints.length-1))
				{
					var afterMatch:int=0;
					var afterPoint:Point = _arrPoints[minIndex+1];
					if ((p.x > afterPoint.x && p.x < closestPoint.x) || (p.x < afterPoint.x && p.x > closestPoint.x))
					{
						afterMatch++;
					}
					if ((p.y > afterPoint.y && p.y < closestPoint.y) || (p.y < afterPoint.y && p.y > closestPoint.y))
					{
						afterMatch++;
					}
					
					if (afterMatch == beforeMatch)
					{
						if (Point.distance(p,beforePoint) < Point.distance(p,afterPoint))
						{
							insertIndex = minIndex;
						}
						else
						{
							insertIndex = minIndex+1;
						}
					}
					else
					{
						
						if (afterMatch > beforeMatch)
						{
							insertIndex = minIndex+1;
						}
						else 
						{
							insertIndex = minIndex;
						}						
					}
				}
				else
				{
					insertIndex = minIndex;
				}				
			}
			else
			{
				insertIndex = minIndex+1;
			}									
												
			//trace("FaceMasker::addPoint bet"+minIndex1+" and "+minIndex2);	
			removePoints();
			var newPointsArr:Array = new Array();			
			for (i=0; i<_arrPoints.length; ++i)
			{				
				if (i==insertIndex)
				{
					
					//if (!(_bMakeBottomLineFlat && i==(_arrPoints.length-1)))
					//{
						newPointsArr.push(p);
						if (_sMaskingMode!=null && _sMaskingMode=="JJ")
						{
							//instead of one point inserting two points. one in the middle of the next point and the one after that
							var oneAfterPoint:Point;							
							var middleAfterPoint:Point;
							if ((i+1)<_arrPoints.length)
							{
								oneAfterPoint = _arrPoints[i+1];
							}
							else
							{								
								oneAfterPoint = _arrPoints[0];
								
							}
							
							middleAfterPoint = Point.interpolate(oneAfterPoint,_arrPoints[i], 0.5);
							newPointsArr.push(_arrPoints[i]);
							newPointsArr.push(middleAfterPoint);	
							continue;
							
						}
					//}
				}
				newPointsArr.push(_arrPoints[i]);
			}
				
			_arrPoints = newPointsArr.slice();
			cdraw.setPoints(_arrPoints);
			_arrDots = new Array();
			for (i = 0; i < _arrPoints.length;++i)
			{
				var pointMC:MovieClip = new _objPointIconClass() as MovieClip;
				pointMC.x = _arrPoints[i].x;
				pointMC.y = _arrPoints[i].y;				
				pointMC.buttonMode = true;
				pointMC.useHandCursor = true;
				pointMC.scaleX = pointMC.scaleY = _nPointsScale
				pointMC.name = String(i);
				_arrDots.push(pointMC)
				_sprtAnchorsHolder.addChild(pointMC);	
			}
			
			if (cdraw!=null)
			{
				initGraphics(true);
				cdraw.drawCurvedShape(true);
			}
			 
		}
		
		public function setOutline(b:Boolean, col:int):void
		{
			_bShowOutline = b;
			_iOutlineColor = col;
		}
		
		public function setDynamicPoints(b:Boolean):void
		{
			_bDynamicPoints = b;
		}
		
		public function setMaskBlurRadius(n:Number):void
		{
			MASK_GLOW_BLUR_RADIUS = n;
		}
		
		public function getPNGByteArray(mc:MovieClip,p:Point):ByteArray
		{
			initGraphics(true, true);
			cdraw.drawCurvedShape(true);
			hidePoints();
			
		
			if (MASK_GLOW_BLUR_RADIUS>0)
			{
				var filter:BitmapFilter = getBitmapFilter();
				var myFilters:Array = new Array();
				myFilters.push(filter);
				_sprtMask.filters = myFilters;
				//topMaskSprite.filters = myFilters;
			}
			
			
			
			var bmpData:BitmapData = new BitmapData(mc.width, mc.height, false, MASK_BG_COLOR);// , true, 0x00000000);
			var clipRect:Rectangle = new Rectangle(p.x, p.y, mc.width - (2 * p.x), mc.height - (2 * p.y));
			
			
			//this.graphics.drawRect(clipRect.x, clipRect.y, clipRect.width, clipRect.height);
			//trace("mc.width=" + mc.width + ", mc.height=" + mc.height);
			var mat:Matrix = new Matrix();
			mat.translate( -p.x, -p.y);								
												
			bmpData.draw(_sprtMask, mat);// , new ColorTransform(), "normal" , clipRect);// , clipRect);
		
			return PNGEncoder.encode(bmpData);
			
		}				
		
		public function setDimensions(apcWin:Point, imageSize:Point):void
		{
			_pContainerSize = apcWin;
			_pPhotoSize = imageSize;
			_pPhotoToContainerAdjustment = new Point(0,0);
			_pAdjustedContainerSize = _pContainerSize.clone();
			//trace("APC:setDimensions _pContainerSize.equals(_pPhotoSize) = "+(_pContainerSize.equals(_pPhotoSize)));
			if (!_pContainerSize.equals(_pPhotoSize))
			{
				//_pPhotoToContainerAdjustment
				_pPhotoToContainerAdjustment.x = (_pContainerSize.x-_pPhotoSize.x)/2;
				_pPhotoToContainerAdjustment.y = (_pContainerSize.y-_pPhotoSize.y)/2;
				_pAdjustedContainerSize.y -= _pPhotoToContainerAdjustment.y;
				_pAdjustedContainerSize.x -= _pPhotoToContainerAdjustment.x;
				//trace("APC:setDimensions _pContainerSize.x = "+_pContainerSize.x+", _pContainerSize.y="+_pContainerSize.y);
				//trace("APC:setDimensions _pPhotoSize.x = "+_pPhotoSize.x+", _pPhotoSize.y="+_pPhotoSize.y);
				//trace("APC:setDimensions _pPhotoToContainerAdjustment.x = "+_pPhotoToContainerAdjustment.x+", _pPhotoToContainerAdjustment.y="+_pPhotoToContainerAdjustment.y);
				//trace("APC:setDimensions _pAdjustedContainerSize.x = "+_pAdjustedContainerSize.x+", _pAdjustedContainerSize.y="+_pAdjustedContainerSize.y);
			}			
			//trace("FaceMasker::setDimensions apcWin="+_pContainerSize.toString()+", photo="+_pPhotoSize.toString());
		}
		
		public function setCenterPoint(p:Point):void
		{
			_pCenter = p;
		}
		
		public function expandPointsFromCenter(pointsIndex:Array,expandMulti:Number):void
		{
			var deltaX:Number;
			var deltaY:Number;
			var deltaPoint:Point;
			
			for (var i:int = 0; i <= _arrPoints.length ;++i)
			{
				//if point doesn't need expanding then skip
				if (pointsIndex.indexOf(i) == -1)
				{
					continue;
				}
				deltaPoint = Point(_arrPoints[i]).subtract(_pCenter);
				Point(_arrPoints[i]).x += expandMulti * deltaPoint.x;
				Point(_arrPoints[i]).y += expandMulti * deltaPoint.y;	
				if (Point(_arrPoints[i]).y < _pPhotoToContainerAdjustment.y)
				{
					Point(_arrPoints[i]).y = _pPhotoToContainerAdjustment.y;
				}
				else if (Point(_arrPoints[i]).y>_pAdjustedContainerSize.y)
				{
					Point(_arrPoints[i]).y = _pAdjustedContainerSize.y;
				}
				if (Point(_arrPoints[i]).x < _pPhotoToContainerAdjustment.x)
				{
					Point(_arrPoints[i]).x = _pPhotoToContainerAdjustment.x;
				}
				else if (Point(_arrPoints[i]).x>_pAdjustedContainerSize.x)
				{
					Point(_arrPoints[i]).x = _pAdjustedContainerSize.x;
				}
				
							
			}			
		}				
		
		public function setPoints(p:Array, postProcessing:Boolean = false):void
		{			
			_arrPoints = p.slice();
			if (cdraw!=null)
			{
				cdraw.setPoints(_arrPoints);
			}
			if (!postProcessing)
			{
				adjustEarBottom();
			}			
		}
		
		public function getPoints():Array
		{
			return _arrPoints.slice();
		}
		
		private function adjustEarBottom():void
		{
			if (_arrPoints[2]!=null && _arrPoints[1]!=null && _arrPoints[10]!=null && _arrPoints[11]!=null)
			{
				_arrPoints[2] = Point.interpolate(_arrPoints[2], _arrPoints[1], 0.5);
				_arrPoints[10] = Point.interpolate(_arrPoints[10], _arrPoints[11], 0.5);
			}
			//else don't do anything
			
		}
		
		public function addBody():void
		{
			//_pAdjustedContainerSize
			//_pPhotoToContainerAdjustment
			var tempArr:Array = new Array();
			var dist:Number;
			var hasBodyBotLeft:Boolean;
			var hasBodyBotRight:Boolean;
			
			dist = Point.distance(_arrPoints[0],_arrPoints[1]);
			var pointBotNeckLeft:Point = new Point(_arrPoints[0].x, _arrPoints[0].y + dist);
			var leftShoulderX:Number = _arrPoints[0].x-(2*dist);
			var leftShoulderY:Number = _arrPoints[0].y + (2*dist);
			var pointShoulderLeft:Point = new Point(leftShoulderX>_pPhotoToContainerAdjustment.x?leftShoulderX:_pPhotoToContainerAdjustment.x,leftShoulderY<_pAdjustedContainerSize.y?leftShoulderY:_pAdjustedContainerSize.y);
			var leftBodyBotX:Number = leftShoulderX - dist;
			if (leftShoulderY<_pAdjustedContainerSize.y)
			//no need to add another point if we reached the bottom of window
			{
				var pointBodyBotLeft:Point = new Point(leftBodyBotX>_pPhotoToContainerAdjustment.x?leftBodyBotX:_pPhotoToContainerAdjustment.x,_pAdjustedContainerSize.y);
				hasBodyBotLeft = true;
			} 
			
			var arrLength:int = _arrPoints.length;
			dist = Point.distance(_arrPoints[arrLength-1],_arrPoints[arrLength-2]); //distance of last two points (11-12)
			var pointBotNeckRight:Point = new Point(_arrPoints[arrLength-1].x, _arrPoints[arrLength-1].y + dist);
			var rightShoulderX:Number = _arrPoints[arrLength-1].x+(2*dist);
			var rightShoulderY:Number = _arrPoints[arrLength-1].y + (2*dist);
			var pointShoulderRight:Point = new Point(rightShoulderX<_pAdjustedContainerSize.x?rightShoulderX:_pAdjustedContainerSize.x,rightShoulderY<_pAdjustedContainerSize.y?rightShoulderY:_pAdjustedContainerSize.y);
			var rightBodyBotX:Number = rightShoulderX + dist;
			if (rightShoulderY<_pAdjustedContainerSize.y)
			//no need to add another point if we reached the bottom of window
			{
				var pointBodyBotRight:Point = new Point(rightBodyBotX<_pAdjustedContainerSize.x?rightBodyBotX:_pAdjustedContainerSize.x,_pAdjustedContainerSize.y);
				hasBodyBotRight = true
			} 
			if (hasBodyBotLeft)
				tempArr.push(pointBodyBotLeft);
			tempArr.push(pointShoulderLeft);
			tempArr.push(pointBotNeckLeft);
			for (var i:int=0; i <_arrPoints.length;++i)
			{
				tempArr.push(_arrPoints[i]);
			}
			tempArr.push(pointBotNeckRight);
			tempArr.push(pointShoulderRight);
			if (hasBodyBotRight)
			{
				tempArr.push(pointBodyBotRight);
			}
			_arrPoints = tempArr.slice();
			if (cdraw!=null)
			{
				cdraw.setPoints(_arrPoints);
			}
			_bMakeBottomLineFlat = true;						
		}
		
		public function addEars():void
		{
			var tempArr:Array = new Array();
			var dist:Number;
			var i:int;
			var x:int;
			var newX:Number
			var newY:Number
			if (_sMaskingMode!=null && _sMaskingMode=="JJ")
			{
				
				for (i = 0; i < _arrPoints.length;++i)
				{
					if (this.EAR_POINTS_JJ[0]==i)
					{
						tempArr.push(_arrPoints[i]);
						dist = flash.geom.Point.distance(_arrPoints[i + 1], _arrPoints[i]);
						newX = _arrPoints[i].x-(EAR_SIMPLE_SIZE_MULTI*dist);
						newY = _arrPoints[i].y-(0.5*dist);
						tempArr.push(new Point(newX, newY));									
					}
					else if (this.EAR_POINTS_JJ[1]==i)
					{
						tempArr.push(_arrPoints[i]);
						dist = flash.geom.Point.distance(_arrPoints[i + 1], _arrPoints[i]);
						newX = _arrPoints[i].x+(EAR_SIMPLE_SIZE_MULTI*dist);
						newY = _arrPoints[i].y+(0.5*dist);												
						tempArr.push(new Point(newX, newY));								
					}
					else
					{
						tempArr.push(_arrPoints[i]);
					}					
				}				
			}
			else
			{
				var earPointArr:Array
				if (_sMaskingMode!=null && _sMaskingMode=="10")
				{
					earPointArr = this.EAR_POINTS_10;
				}
				else
				{
					earPointArr = this.EAR_POINTS;
				}
				
				//add points until first ear (clockwise from bottom left)
				for (i = 0; i <= earPointArr[0];++i)
				{
					tempArr.push(_arrPoints[i]);
				}
				//add points next to the ear points
				dist = flash.geom.Point.distance(_arrPoints[i - 1], _arrPoints[i]);
				
				x = Math.round((_arrPoints[i - 1].x < _arrPoints[i].x ? _arrPoints[i - 1].x : _arrPoints[i].x) - (dist * 0.25));
				tempArr.push(new Point(x, Math.round(_arrPoints[i-1].y- (dist * 0.25))))
				tempArr.push(new Point(x, _arrPoints[i].y))
				//add points after the first ear 
				for (i = earPointArr[1]; i <= earPointArr[2];++i)
				{
					tempArr.push(_arrPoints[i]);
				}
				//trace(_arrPoints[i - 1]);
				//trace( _arrPoints[i]);
				dist = flash.geom.Point.distance(_arrPoints[i - 1], _arrPoints[i]);
				x = Math.round((_arrPoints[i - 1].x > _arrPoints[i].x ? _arrPoints[i - 1].x : _arrPoints[i].x) + (dist * 0.25));
				tempArr.push(new Point(x, _arrPoints[i-1].y))
				tempArr.push(new Point(x, Math.round( _arrPoints[i].y - (dist * 0.25))))
				//add the rest of the points
				for (i = earPointArr[3]; i <_arrPoints.length;++i)
				{
					tempArr.push(_arrPoints[i]);
				}
			}
			_arrPoints = tempArr.slice();			
			if (cdraw!=null)
			{
				cdraw.setPoints(_arrPoints);
			}			
		}
		
		public function hideCursorWhenDragging(b:Boolean):void
		{
			_bHideCursorWhenDragging = b;
		}
		
		public function setPointIcon(c:Class):void
		{
			_objPointIconClass = c;
		}
		
		private function pointPressed(evt:MouseEvent):void
		{
			var o:Object = this.stage.focus;			
			//trace("APC::pointPressed111 "+evt.target+" is _objPointIconClass?"+(evt.target is _objPointIconClass));
			//trace("APC::pointPressed is _objPointIconClass? "+(evt.target is _objPointIconClass)+", "+evt.target.name+", "+evt.target.x+","+evt.target.y);
			if (evt.target is _objPointIconClass)
			{
				//trace("APC::pointPressed  _bCtrlPressed="+_bCtrlPressed+", _bShiftPressed="+_bShiftPressed);
				if (evt.ctrlKey && evt.shiftKey && _bDynamicPoints)//_bShiftPressed)
				{
					removePoint(MovieClip(evt.target));
					_bCtrlPressed = false;//evt.ctrlKey;;
					_bShiftPressed = false;//evt.shiftKey;
					return;
				}
				
				_mcSelectedDot = MovieClip(evt.target);
				_mcSelectedDot.startDrag(true,new Rectangle(_pPhotoToContainerAdjustment.x,_pPhotoToContainerAdjustment.y,_pAdjustedContainerSize.x-_pPhotoToContainerAdjustment.x, _pAdjustedContainerSize.y-_pPhotoToContainerAdjustment.y));
				//trace("pointPressed dragging: "+_mcSelectedDot.name);
				
				this.stage.focus = this.stage;
				//this.addEventListener(Event.ENTER_FRAME, dragOnEnter);
				if (_bHideCursorWhenDragging)
				{
					flash.ui.Mouse.hide();
				}
				MovieClip(evt.target).addEventListener(MouseEvent.MOUSE_MOVE,pointMoved);
				this.stage.addEventListener(MouseEvent.MOUSE_UP,pointMouseRelease);
				
				
			}			
		}
		
		public function isMaskPointPressed():Boolean
		{
			return _mcSelectedDot!=null;
		}
		
		private function mouseClicked(evt:MouseEvent):void
		{
			dispatchEvent(new AutophotoEvent(AutophotoEvent.ON_ACTIVITY, evt));
			//trace("FaceMasker::mouseClicked _bCtrlPressed="+_bCtrlPressed);
			if (evt.ctrlKey && _bDynamicPoints)
			{
				_bCtrlPressed = false;//evt.ctrlKey;;
				_bShiftPressed = false;//evt.shiftKey;
				addPoint(new Point(evt.localX, evt.localY));
				/*
				if (cdraw!=null)
				{
					initGraphics(true);
					cdraw.drawCurvedShape(true);
				}
				*/
			}
		}

		private function pointReleased(evt:MouseEvent):void
		{				
			dispatchEvent(new AutophotoEvent(AutophotoEvent.ON_ACTIVITY, evt));
			//trace("APC::pointReleased "+evt.target)
			if (evt!=null && evt.ctrlKey && _bDynamicPoints) return;
			//trace("APC::pointReleased");
			/*
			if (_timerDragging!=null)
			{
				_timerDragging.stop();
				
			}
			*/
			_iMacFixDoOnceNextFrame = 2;
			//this.removeEventListener(Event.ENTER_FRAME, dragOnEnter);
			if (_bHideCursorWhenDragging)
			{
				flash.ui.Mouse.show();
			}
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE,pointMoved);
			if (evt!=null)
			{
				if (evt.target!=null && (evt.target is MovieClip))
				{
					//trace("pointReleased stopDragging: "+MovieClip(evt.target).name);
					MovieClip(evt.target).stopDrag();//startDrag(false);
					MovieClip(evt.target).removeEventListener(MouseEvent.MOUSE_MOVE,pointMoved);
				}				
			}
			if (this.stage!=null)
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_UP,pointMouseRelease);
			}
			if (_mcSelectedDot!=null)
			{
				_mcMacFixLastSelectedDot = _mcSelectedDot;
			}
			_mcSelectedDot = null;
			if (cdraw!=null)
			{
				initGraphics(true);
				cdraw.drawCurvedShape(true);
			}
			
		}
		
		private function pointMouseRelease(evt:MouseEvent):void
		{
			dispatchEvent(new AutophotoEvent(AutophotoEvent.ON_ACTIVITY, evt));
			//trace("APC::stopDragging _mcSelectedDot="+_mcSelectedDot.name);			
			_iMacFixDoOnceNextFrame = 2;
			_mcSelectedDot.stopDrag();
			_mcMacFixLastSelectedDot = _mcSelectedDot;
			
			_mcSelectedDot.removeEventListener(MouseEvent.MOUSE_MOVE,pointMoved);
			/*
			if (_timerDragging!=null)
			{
				_timerDragging.stop();
				
			}
			*/
			//this.removeEventListener(Event.ENTER_FRAME, dragOnEnter);
			if (_bHideCursorWhenDragging)
			{
				flash.ui.Mouse.show();
			}
			if (cdraw!=null)
			{
				initGraphics(true);
				cdraw.drawCurvedShape(true);
			}
			
		}

		private function dragOnEnter(evt:Event):void
		{
			trace("dragOnEnter _mcSelectedDot="+_mcSelectedDot +" _iMacFixDoOnceNextFrame="+_iMacFixDoOnceNextFrame+" _mcMacFixLastSelectedDot="+_mcMacFixLastSelectedDot);
			if (_iMacFixDoOnceNextFrame>0 && _mcSelectedDot==null)
			{
				_mcSelectedDot = _mcMacFixLastSelectedDot;
				
			}
			if (_mcSelectedDot!=null)
			{
				this.stage.invalidate();
				var p:Point = new Point(_mcSelectedDot.x, _mcSelectedDot.y);
				var ind:int = int(_mcSelectedDot.name);
				trace("p="+p+"ind="+ind+", _arrPoints[ind]="+_arrPoints[ind]);
				if (p!=_arrPoints[ind])
				{
					_arrPoints[ind].x = _mcSelectedDot.x;
					_arrPoints[ind].y = _mcSelectedDot.y					
					if (cdraw!=null)
					{
						//trace("drawCurvedShape");
						initGraphics(true);
						cdraw.drawCurvedShape(true);
					}
				}
			}
			if (_iMacFixDoOnceNextFrame>0)
			{
				_iMacFixDoOnceNextFrame--;				
			}
			else if (_iMacFixDoOnceNextFrame==0)
			{
				this.removeEventListener(Event.ENTER_FRAME, dragOnEnter);
				_mcMacFixLastSelectedDot = null;
				_iMacFixDoOnceNextFrame = -1				
			}
		}
		
		private function onDragTimer(evt:TimerEvent):void
		{
			var changed:Boolean = false;
			for (var j:int=0; j<_arrDots.length; ++j)
			{
				var pointMC:DisplayObject = DisplayObject(_arrDots[j]);
				var ind:int = int(pointMC.name);
				var pos:Point = new Point(pointMC.x, pointMC.y);
				if (_arrPoints[ind]!=pos)
				{
					changed = true;
					_arrPoints[ind] = pos;
				}				
			}
			
			if (cdraw!=null && changed)
			{
				//trace("drawCurvedShape");
				
				initGraphics(true);
				cdraw.setPoints(_arrPoints);
				cdraw.drawCurvedShape(true);
			}
			
		}
	
		private function pointMoved(evt:MouseEvent):void
		{			
		
		}
		
		/**
		 * 
		 */
		public function hidePoints():void
		{
			for (var i:int = 0; i < _sprtAnchorsHolder.numChildren;++i){
				_sprtAnchorsHolder.getChildAt(i).visible = false;
			}
		}
		
		/**
		 * 
		 */
		public function showPoints():void
		{
			for (var i:int = 0; i < _sprtAnchorsHolder.numChildren;++i)
			{
				_sprtAnchorsHolder.getChildAt(i).visible = true;
			}
		}
		
		public function removePoints():void
		{
			for (var j:int=0; j<_arrDots.length; ++j)
			{
				_sprtAnchorsHolder.removeChild(_arrDots[j] as DisplayObject);
			}
			for (var i:int = 0; i < _sprtAnchorsHolder.numChildren;++i)
			{
				_sprtAnchorsHolder.removeChildAt(i);
			}
		}
		
		public function getMask():Sprite
		{
			return _sprtMask;
		}
		
		public function setMaskGraphics(gr:Object):void
		{
			_grapchis = gr;
		}
		
		private function initGraphics(clr:Boolean = false, pngMode:Boolean = false, outlineMode:Boolean = false):void
		{
			if (clr)
			{
				_sprtMask.graphics.clear();
				_sprtLine.graphics.clear();
				
			}
			if (!pngMode)
			{
				if (_grapchis == null)
				{
					//default Colors
					_grapchis = new Object();
					_grapchis.lineThickness = 1;
					_grapchis.lineColor = 0x000000;
					_grapchis.lineAlpha = 1;
					_grapchis.fillType = "solid";
					_grapchis.fillColor = 0xcccccc;
					_grapchis.fillAlpha = 0.3;			
					
				}
				_sprtLine.graphics.lineStyle(1,_iOutlineColor,0.2);
				_sprtMask.graphics.lineStyle(_grapchis.lineThickness, _grapchis.lineColor, _grapchis.lineAlpha);
				switch(_grapchis.fillType)
				{
					case "solid":
						_sprtMask.graphics.beginFill(_grapchis.fillColor, _grapchis.fillAlpha);
						break;
					case "gradient":
						break;
					case "bitmap":
						break;
				}
			}
			else						
			{
				//creating the mask fill
				
				_sprtMask.graphics.lineStyle(0,0x000000,0);
				var fillType:String = GradientType.LINEAR;
				var colors:Array = [FACE_FILL_COLOR, FACE_FILL_COLOR];
				var alphas:Array = [1, 1];
				var ratios:Array =[0x00, 0xFF];
				var matr:Matrix = new Matrix();
				var boundBox:Rectangle = getPointsBoundingBox(_arrPoints);
				//graphics.drawRect(boundBox.x,boundBox.y,boundBox.width, boundBox.height);
				//trace("boundBox "+boundBox.toString());
				matr.createGradientBox(boundBox.width, boundBox.height, 0, 0, 0);
				var spreadMethod:String = SpreadMethod.PAD;
				_sprtMask.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
				//trace("initGraphics for png "+boundBox.width)
			}
		}
		
		private function getUpperPoints():Array
		{
			var tempArr:Array = new Array();
			for (var i:int = 0; i < _arrPoints.length;++i)
			{
				if (_arrPoints[i].y < _pCenter.y)
				{
					tempArr.push(_arrPoints[i]);
				}
			}
			return tempArr;
		}
		
		private function getLowerPoints():Array
		{
			var tempArr:Array = new Array();
			var retArr:Array = new Array();			
			var i:int;
			//upper points
			for (i = 0; i < _arrPoints.length;++i)
			{
				if (_arrPoints[i].y < _pCenter.y)
				{
					tempArr.push(_arrPoints[i]);					
				}
			}
			
			var sortedTempArr:Array = tempArr.slice();
			sortedTempArr.sortOn("y",Array.NUMERIC | Array.DESCENDING);
			var bot1:Point;
			var bot2:Point;
			for (i=0; i<sortedTempArr.length; ++i)
			{
				if (sortedTempArr[i].x<_pCenter.x)
				{
					bot1 = sortedTempArr[i];
				}
				else if (sortedTempArr[i].x>=_pCenter.x)
				{
					bot2 = sortedTempArr[i];
				}
				if (bot1!=null && bot2!=null)
				{
					break;
				}
				
			}
			
			//bottom points
			for (i= 0; i < _arrPoints.length; ++i)
			{
				if (_arrPoints[i].y >= _pCenter.y)
				{								
					retArr.push(_arrPoints[i]);										
				}
			}
			
			var sortedRetArr:Array = retArr.slice();
			sortedRetArr.sortOn("y",Array.NUMERIC);
			var top1:Point;
			var top2:Point;
			for (i=0; i<sortedRetArr.length; ++i)
			{
				if (sortedRetArr[i].x<_pCenter.x)
				{
					top1 = sortedRetArr[i];
				}
				else if (sortedRetArr[i].x>=_pCenter.x)
				{
					top2 = sortedRetArr[i];
				}
				if (top1!=null && top2!=null)
				{
					break;
				}
				
			}			
						
			//insert lowest upper points to the bottom points array
			var finalRetArr:Array = new Array();
			for (i=0; i<retArr.length; ++i)
			{
				if (retArr[i]==top2)
				{
					finalRetArr.push(bot1);
					finalRetArr.push(bot2);
				}
				finalRetArr.push(retArr[i]);
				
			}
			
			return finalRetArr;
		}
		
		private function getBitmapFilter():BitmapFilter {            
            var color:Number = MASK_BG_COLOR;
            var alpha:Number = MASK_GLOW_ALPHA;
            var blurX:Number = MASK_GLOW_BLUR_RADIUS;
            var blurY:Number = MASK_GLOW_BLUR_RADIUS;
            var strength:Number = 2;
            var inner:Boolean = true;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

            return new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
        }
		
		public function getPointsBoundingBox(p:Array):Rectangle
		{
			var xMin:Number;
			var xMax:Number;
			var yMin:Number;
			var yMax:Number;
			
			for (var i:int;i<p.length;++i)
			{
				xMin = isNaN(xMin)||p[i].x<xMin? p[i].x : xMin;
				xMax = isNaN(xMax)||p[i].x>xMax? p[i].x : xMax;
				yMin = isNaN(yMin)||p[i].y<yMin? p[i].y : yMin;
				yMax = isNaN(yMax)||p[i].y>yMax? p[i].y : yMax;		
			}		
			return new Rectangle(xMin,yMin,xMax-xMin,yMax-yMin);
		}
	
	}
}