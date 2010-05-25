package {
    import flash.display.Sprite;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.system.Security;
    import flash.system.SecurityPanel;
    import flash.events.*;
    import flash.media.Camera;
    import flash.media.Video;
    import fl.controls.Button;
	import fl.controls.Label;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.net.*;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.geom.Matrix;
 	import flash.utils.Timer;
	import flash.external.ExternalInterface	
	import com.adobe.images.JPGEncoder;
	import com.dynamicflash.util.Base64;
	import com.rgbeffects.UUID;

    public class cozybitCamera extends Sprite {
        
        private var camera: Camera;
        private var video: Video;
		private var gBitmapData: BitmapData;
//		private var gBitmapDataResized: BitmapData;	
		private var stillImage: Bitmap;	
		private var gBitmapToSend: Bitmap;			
		private var urlLoader: URLLoader;
        private var urlRequest: URLRequest;
        private var responseData: String;
		private var strUUID: String;
		private var textFmt: TextFormat;
		
		private var cameraSettingsBtn: Button;
        
        public function cozybitCamera() {
			init();
        }
        
        private function checkNotNull( val, msg ){
            if (val==null){
                throw new Error( msg );
             }
        }
		
		private function init() {
            if (width < 215 || height < 138){
                trace('Stage should be at least 215,138 to fit the Camera privacy dialog. size=',width,height);
            }
		    
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP;
			
			// Widgets defined in the .FLA file
			checkNotNull( spinny,   'spinny should be defined in .FLA');
			checkNotNull( infoText, 'infoText should be defined in .FLA');
			checkNotNull( box,      'box should be defined in .FLA');   // Frame for video / still iamges
			checkNotNull( btnTake,  'btnTake should be defined in .FLA');
			checkNotNull( btnNext,  'btnNext should be defined in .FLA');
			
			spinny.visible = false; // spinning wait graphic on stage
			infoText.text = "";

			textFmt = new TextFormat();
			textFmt.color = 0x444444;
			textFmt.font = "Arial";
			textFmt.size = "12";
			
			btnTake.setStyle("textFormat", textFmt);
			btnTake.label = "Take Picture";	
			btnTake.addEventListener(MouseEvent.CLICK, btnTakeClickHandler);

			btnNext.setStyle("textFormat", textFmt);
			btnNext.label = "Next >>";
			btnNext.visible = false;
			btnNext.addEventListener(MouseEvent.CLICK, btnNextClickHandler);			
			
			infoText.setStyle("textFormat", textFmt);
			infoText.text = "";

            startCamera();
			
			loadExternalData();
		}

        private function checkCameraBtn( visible: Boolean ){
            // Make a "camera settings" button
            if (visible && cameraSettingsBtn==null){
                // Create first time.
                cameraSettingsBtn = new Button();
    			cameraSettingsBtn.setStyle("textFormat", textFmt);
                cameraSettingsBtn.label = "Check Camera";
                cameraSettingsBtn.x = btnTake.x;
                cameraSettingsBtn.y = btnTake.y;
                cameraSettingsBtn.width = btnTake.width;
                cameraSettingsBtn.height = btnTake.height;
                cameraSettingsBtn.addEventListener( MouseEvent.CLICK, on_cameraSettingsBtn_click );
                cameraSettingsBtn.visible = true;
                addChild( cameraSettingsBtn );
            }
            if (cameraSettingsBtn){
                // If visible, it would have been created. If not visible, maybe we don't need it.
                cameraSettingsBtn.visible = visible;
            }
            btnTake.visible = ! visible;
        }
        
        /**
            Start the camera, or if there is a problem, show a "Check Camera" button.
        */
		private function startCamera(){
            camera = Camera.getCamera();
            
            if (camera == null) {
				infoText.text = "You need a camera. Connect one and click <b>Check Camera</b>";
				checkCameraBtn( true );

            } else if (camera.muted) {
                // User has blocked the camera.
                infoText.htmlText = "Click <b>Allow</b>, then <b>Close</b>, and finally <b>Check Camera</b>";
                Security.showSettings(SecurityPanel.PRIVACY)
				checkCameraBtn( true );

            } else {
				checkCameraBtn( false );
                infoWelcome();

				camera.setMode( box.width, box.height, 24);
				camera.setQuality(0, 100);
				camera.setMotionLevel(100);

                video = new Video(camera.width, camera.height);
				video.smoothing = true;
				video.attachCamera(camera);

                video.x = box.x+(box.width-camera.width)/2
                video.y = box.y+(box.height-camera.height)/2
                addChild( video );
            }
		}

        private function on_cameraSettingsBtn_click( evt: MouseEvent ){
            startCamera();
        }
        
        private function infoWelcome(){
            var firstName: String = getFirstName()
            if (firstName == null){
                firstName = '';
            } else {
                firstName = ' '+firstName;
            }
            infoText.text = "Welcome" + firstName + ", please take your picture.";
        }
        
       
		private function loadExternalData() {
			if (ExternalInterface.available) {
                try {
                    if (checkJavaScriptReady()) {
                        infoWelcome();
                    } else {
                        // javascript not ready, keep trying
                        var readyTimer:Timer = new Timer(100, 0);
                        readyTimer.addEventListener(TimerEvent.TIMER, timerHandler);
                        readyTimer.start();
                    }
                } catch (error:Error) {
					infoText.text = "Email unavailable: " + error.message;
                }
            } else {
                infoText.text = "External interface unavailable.";
            }
		}

        private function timerHandler(event:TimerEvent):void {
            var isReady:Boolean = checkJavaScriptReady();
            if (isReady) {
                infoWelcome();
//               	infoText.text = "Welcome " + getFirstName() + ", please take your picture.";;
            	Timer(event.target).stop();
            }
        }

		private function checkJavaScriptReady():Boolean {
            var isReady:Boolean = ExternalInterface.call("isReady");
            return isReady;
        }
	
        private function getFirstName():String {
            var firstName:String = ExternalInterface.call("firstName");
            return firstName;
        }

        private function getLastName():String {
            var lastName:String = ExternalInterface.call("lastName");
            return lastName;
        }

        private function getEmail():String {
            var email:String = ExternalInterface.call("email");
            return email;
        }

		private function btnTakeClickHandler(event:MouseEvent):void {
			if (btnTake.label == "Take Picture") {
				var gSound:CameraSound = new CameraSound();
				var soundChannel:SoundChannel = gSound.play();
				btnNext.visible = true;
				btnTake.label = "Retake Picture";
				infoText.htmlText = 'Click <b>Retake Picture</b> to retake or <b>Next</b> to finish.';
				
				// Get raw camera data
                gBitmapData = new BitmapData(camera.width, camera.height);
	    		gBitmapData.draw(video);
    
				// Show on the screen
                stillImage = new Bitmap(gBitmapData);
                stillImage.x = box.x+(box.width-camera.width)/2;
                stillImage.y = box.y+(box.height-camera.height)/2;
                addChild(stillImage);
                video.visible = false;
				
				// here we are grabbing the video screen, getting the bitMapData and creating
				// a new Bitmap off screen, this is being scaled by 1/2
// 				var matrix:Matrix = new Matrix(0.5,0,0,0.5,0,0); // scaling by 1/2
// 				gBitmapDataResized = new BitmapData(CAM_W * 0.5, CAM_H * 0.5);			
// 				gBitmapDataResized.draw(video, matrix);
// 				gBitmapToSend = new Bitmap(gBitmapDataResized);
 				gBitmapToSend = new Bitmap(gBitmapData);
			} else {  // Retake
			    // Remove our still photo
				if (contains(stillImage)){
					removeChild(stillImage);
					stillImage = null;
					gBitmapData.dispose();
				    gBitmapData = null;	
				    
				    video.visible=true;
		
					gBitmapToSend = null;
// 					gBitmapDataResized.dispose();
// 					gBitmapDataResized = null;	
	           	}
				btnTake.label = "Take Picture";		
				infoText.htmlText = 'Click <b>Take Picture</b>.';
				btnNext.visible = false;			
			}
		}

		private function btnNextClickHandler(event:MouseEvent):void {
			btnNext.enabled = false;
			btnTake.visible = false;
			spinny.visible = true;			
			infoText.text = 'Sending picture...';
			strUUID = UUID.create();
			this.upload();
		}

		private function upload() : void {

		    const UPLOAD_PHOTO_URL: String = 'userservice';
		    trace('Uploading picture to:', UPLOAD_PHOTO_URL )

            // UUEncode photo data
			var jpgEncoder:JPGEncoder = new JPGEncoder(100);
			var encodedImage:ByteArray = jpgEncoder.encode(gBitmapToSend.bitmapData);
			var base64String:String = Base64.encodeByteArray(encodedImage);

            // Send to the proper URL via HTTP Post
 			var header:URLRequestHeader = new URLRequestHeader("Content-Type", 
 			    "application/x-www-form-urlencoded");
			var request:URLRequest = new URLRequest( UPLOAD_PHOTO_URL );
			request.method = URLRequestMethod.POST;
	    	request.requestHeaders.push(header);

			var variables:URLVariables = new URLVariables();	
			variables.urlType = "add";
			variables.fileData = base64String;
			variables.fileName = strUUID;
			variables.email = getEmail();
			variables.lastName = getLastName();
			variables.firstName = getFirstName();			
			request.data = variables;

//			testing
//			var urlLoader:URLLoader = new URLLoader();
//			urlLoader.addEventListener(Event.COMPLETE, uploadCompleteHandler);
//			urlLoader.load(saveJPG)				
				
            try {
				navigateToURL(request, "_self");
            }
            catch (error:Error)  {
                infoText.text = "Problem uploading: " + error.message;
            }
		}

		private function uploadCompleteHandler(event:Event) : void{
        	navigateToURL(new URLRequest("./images/" + strUUID + ".jpg" ), "_self");
			spinny.visible = false;
			infoText.text = 'Picture sent.';
        }
    }
}