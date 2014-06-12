/**
* ...
* @author Jonathan Achai
* @version 0.1
*/

package com.oddcast.autophoto{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	public interface IAPCAPI extends IEventDispatcher
	{
		//function loadPhoto(s:String):void;
		function browseFileSystem():void;
		function uploadFile():Boolean;
		function zoom(inc:int,remember:Boolean = true):void;
		function startZooming(inc:int):void;
		function stopZooming():void;
		function rotate(inc:int,tween:Boolean = true):void;
		function reset():void
		function pan(inc:int,yAxis:Boolean = false,remember:Boolean = true):void;
		function startPanning(inc:int,yAxis:Boolean = false):void;
		function stopPanning():void;
		function setGender(gender:String):void;
		function setPointPlacementIcon(appDomain:ApplicationDomain,className:String):void;
		function submit(autocrop:Boolean = false):void;			
		function submitWithPoints():void;
		function submitMask():void;
		function restart():void;
		function setBgColor(hex:int):void;
		function getSessionId():String;
		function setPointPlacementColor(pointName:String, color:int):void;
		function uploadByteArray(stream:ByteArray, contentType:String = "image/jpeg"):void;
		function uploadImageUrl(imageUrl:String):void;
		function setUploadLimits(min:Number = 0, max:Number = 0):void;
		function setToolTipText(part:String, val:String):void;
		function setToolTipColor(textColor:int,  bgColor:int, borderColor:int):void;		
		/**
		 * Sets whether the APC will force face detection before submitting to conversion. If b is true an error will be dispatched if a face (or multiple faces) are recognized upon submit.
		 * The fill parameter can be set to determine how much of the frame should the face box take in percentage.
		 * @param	b - true mean active false inactive		 
		 * @param	fill - 0-100 (-1 uses default)
		 */
		function setForceFaceFill(b:Boolean, fill:int = -1):void
		/**
		 * Sets whether the auto cropping step using ComputerVision will be available. This option can't be used if the apc wasn't originally loaded with this option
		 * @param	b - true mean active false inactive		 
		 */
		function setAutoCroppingActive(b:Boolean):void
		/**
		 * Sets whether the photo will be submitted to luxand and photoface processing. Can be used for 2D characters
		 * @param	b - true mean skip		 
		 */
		function setSkipLuxand(b:Boolean):void
		/**
		 * Sets whether the masking step will be available
		 * @param	b - true mean active false inactive		 
		 */
		function setMaskingStepActive(b:Boolean):void
		/**
		 * Skips the mask step (after it is already displayed)		 		
		 */
		function skipMask():void
		/**
		 * Hides the mask
		 * @param	b - true means hide the mask, false means show it
		 */ 
		function hideMask(b:Boolean):void
		/**
		 * Hides the mouse cursor when dragging placement or masking points
		 * @param	b - true means hide, false means show
		 */ 
		function hideCursorForDragging(b:Boolean):void
		/**
		 * If set to true, the image will be zoomed to the face in the point placement step
		 * @param	b - true means hide, false means show
		 */ 
		function zoomToFaceForPointsPlacement(b:Boolean):void
		/**
		 * Disposes of the objects used by the APC
		 * @param	evt - optional if to be triggered by an event listener		 
		 */
		function destroy(evt:Event = null):void
		/**
		 * Initializes the webcam for capturing an image
		 * @param	doc - A DisplayObjectContainer to display the webcam image into
		 * @param	w - the width of the webcam window
		 * @param	h - the height of the webcam window 		 
		 */
		function webcamInit(doc:DisplayObjectContainer,w:Number,h:Number):void
		/**
		 * Captures the current frame displayed in the webcam window		 		
		 */
		function webcamCapture():void
		/**
		 * Disposes of the previous webcam captured image		 		 
		 */
		function webcamClear():void
		/**
		 * Deactivates the webcam interface		 		 
		 */
		function webcamClose():void	
		/**
		 * Upload the webcam captured image to the server		 		 
		 */
		function webcamUpload():void
		/**
		 * Sets the maximum upload dimension limits for user uploaded images selected using the browseFileSystem method
		 * @param	w - the image's maximum width		
		 * @param	h - the image's maximum height
		 */
		function setMaxUploadDimensionsLimit(w:int = 0, h:int =0 ):void
		/**
		 * Sets the minimum upload dimension limits for user uploaded images selected using the browseFileSystem method
		 * @param	w - the image's minimum width		
		 * @param	h - the image's minimum height
		 */
		function setMinUploadDimensionsLimit(w:int = 0, h:int =0 ):void
		/**
		 * Sets the radius of the glow around the mask's upper points (nose and up). By default the value is 5. Set to 0 for no effect at all.
		 * @param	n - The radius of the glow filter applied to the top part of the mask				 
		 */
		function setMaskBlurRadius(n:Number):void
		/**
		 * Turns on/off the ability to add more points to the masking step dynamically. The function must be called before the masking step
		 * @param	b - true for on, false for off				 
		 */
		function setMaskDynamicPoints(b:Boolean):void	
		/**
		 * Turns on/off and sets the color of an outline for the mask
		 * @param	b - true for on, false for off		
		 * @param	col - the outline color. By default it is red
		 */
		function setMaskOutline(b:Boolean, col:int = 0xff0000):void
		/**
		 * Re-enters the masking step with the previous points for post processing adjustments
		 */
		function enterPostProcessingMaskStep():void
		/**
		 * Returns the masking step points to their original position		 
		 */
		function resetMask():void
		/**
		 * This function should be called after a succsful autophoto process has completed to retrieve the files generated by the process
		 * @param	contFn - This function will be called back with the xml containing the files. 
		 * The files are organized in an xml of this stucture: <fgchar><url id="photoface" url="http://autophoto.dev.oddcast.com/ccs1/AF/tmp/ba/49/ba4957ebff2553959eedef068ce76f21-cropped.jpg"/>	<url id="fgfile" url="http://autophoto.dev.oddcast.com/ccs1/tmp/APS/42/bf/42bff07fcc07e5566c74ae034a76c8e0/42bff07fcc07e5566c74ae034a76c8e0.fg"/>	<url id="lux" url="http://autophoto.dev.oddcast.com/ccs1/tmp/APS/61/1e/611eb9f6bea0a2f8387042c98e87bcad/611eb9f6bea0a2f8387042c98e87bcad-luxand.lux"/><url id="thumb" url="http://autophoto.dev.oddcast.com/ccs1/AF/tmp/ba/49/ba4957ebff2553959eedef068ce76f21-thumb.jpg"/></fgchar>
		 * If an error occurs the returned xml will be an error xml in this format: <APIERROR CODE="errorCode" ERRORSTR="errorDescription"/>
		 * If the server can't be reached the xml will be null	
		 */		
		function getCharXML(contFn:Function):void
		/**
		 * This function should be called after a ON_APC_AUTO_CROPPED event has been dispatched in order to retrieve bitmap data of the faces found for selection
		 * @return	array of bitmapData objects	  
		 * The files are organized in an xml of this stucture: <fgchar><url id="photoface" url="http://autophoto.dev.oddcast.com/ccs1/AF/tmp/ba/49/ba4957ebff2553959eedef068ce76f21-cropped.jpg"/>	<url id="fgfile" url="http://autophoto.dev.oddcast.com/ccs1/tmp/APS/42/bf/42bff07fcc07e5566c74ae034a76c8e0/42bff07fcc07e5566c74ae034a76c8e0.fg"/>	<url id="lux" url="http://autophoto.dev.oddcast.com/ccs1/tmp/APS/61/1e/611eb9f6bea0a2f8387042c98e87bcad/611eb9f6bea0a2f8387042c98e87bcad-luxand.lux"/><url id="thumb" url="http://autophoto.dev.oddcast.com/ccs1/AF/tmp/ba/49/ba4957ebff2553959eedef068ce76f21-thumb.jpg"/></fgchar>
		 * If an error occurs the returned xml will be an error xml in this format: <APIERROR CODE="errorCode" ERRORSTR="errorDescription"/>
		 * If the server can't be reached the xml will be null	
		 */		
		function getFaces():Array	
		/**
		 * This function should be called using the getFaces array to select a face found by facefinder
		 * @param index	which face to autoPosition by	  		 	
		 */		
		function autoPositionByFaceFinder(index:int):void
		/**
		 * Determines whether or not auto positioning should occur.
		 * @param value Boolean which when true will auto position. when false, will skip auto positioning
		 */
		function shouldAutoPositionByFaceFinder(value:Boolean):void;
		/**
		 * Starts rotating continuously in the image adjustment step
		 * @param	inc - how much to rotate at each increment (degrees)				 
		 */
		function startRotating(inc:int):void	
		/**
		 * Stops continuous rotation started by the startZRotating method		 				
		 */
		function stopRotating():void
		/**
		 * Sets the graphic (DisplayObject) to be used for the masking step point icons.
		 * @param	appDomain - The ApplicationDomain where the object is registered		
		 * @param	className - The linkage/class name of the object to be used
		 */
		function setMaskPointIcon(appDomain:ApplicationDomain, className:String):void
		/**
		 * Sets the graphics object the masking step should use for drawing its shape.
		 * @param	gr - Object with the following properties: lineThickness = 1, lineColor = 0x000000, lineAlpha = 1, fillType = "solid", fillColor = 0xcccccc, fillAlpha = 0.3						 
		 */
		function setMaskGraphics(gr:Object):void		
		/**
		 * Sets the multiplier used by the masking step to encampus the hair around the head
		 * @param	n - the multiplier. By default 0.15				 
		 */
		function setMaskHairExpandMulti(n:Number)
		/**
		 * Sets the bg color to be used when the server crops the image
		 * @param	col - the bg color		 				 
		 */
		function setCroppedBgColor(col:int):void	
		/**
		 * Displays the default points in the point placement step						 
		 */
		function displayDefaultPoints():void
		/**
		 * Get the point placement step points array
		 * @return	Array of Point objects		 				 
		 */
		function getPointsArray():Array	
		/**
		 * Get a specific point of the point placement step points.
		 * @param	pointName - the point's SKU name taken from APC_Contants.LUXAND_POINTS_IN_USE or APC_Contants.LUXAND_FACE_MASK_POINTS
		 * @return	Point		 				 
		 */
		function getPoint(pointName:String):Point
		/**
		 * Gets the rotation of the image in the image adjustment step		 
		 * @return	Number		 				 
		 */
		function getRotation():Number
		/**
		 * Sets the Timer's delay used for continuous zooming/panning/rotation
		 * @param	i - number of miliseconds to set the timer		 		 				
		 */
		function setTimerDelay(i:int):void
		/**
		 * Gets the scale of the image in the image adjustment step		 
		 * @return	Number		 				 
		 */
		function getPhotoScale():Number
		/**
		 * Gets the luxand threshold		 
		 * @return	String		 				 
		 */
		function getLuxandThreshold():String
		/**
		 * Gets the APC image contaner movieclip		 
		 * @return	MovieClip		 				 
		 */
		function getPhotoContainer():MovieClip
		/**
		 * Gets the maximum number of pixels the image can be		 
		 * @return	Number		 				 
		 */
		function getPhotoMax():Number
		/**
		 * Gets the minimum number of pixels the image can be		 
		 * @return	Number		 				 
		 */
		function getPhotoMin():Number
		/**
		 * Manually switch to point placement face zoom		 		
		 */
		function zoomInFace():void
		/**
		 * Restores original zoom for point placement step autozoom		 		
		 */
		function zoomOutFace():void
	}

}