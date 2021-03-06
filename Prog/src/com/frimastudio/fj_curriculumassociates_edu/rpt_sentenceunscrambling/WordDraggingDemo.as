package com.frimastudio.fj_curriculumassociates_edu.rpt_sentenceunscrambling
{
	import com.frimastudio.fj_curriculumassociates_edu.Asset;
	import com.frimastudio.fj_curriculumassociates_edu.ui.piecetray.Piece;
	import com.frimastudio.fj_curriculumassociates_edu.ui.piecetray.PieceTray;
	import com.frimastudio.fj_curriculumassociates_edu.ui.piecetray.PieceTrayEvent;
	import com.frimastudio.fj_curriculumassociates_edu.ui.piecetray.SentenceTray;
	import com.frimastudio.fj_curriculumassociates_edu.ui.UIButton;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.globalization.StringTools;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class WordDraggingDemo extends Sprite
	{
		private static const FORMAT:TextFormat = new TextFormat(null, 24);
		private static const OFFSET:Number = 10;
		
		private var mState:WordDraggingDemoState;
		private var mLayout:Sprite;
		private var mChallengePicture:Sprite;
		private var mSentenceTray:SentenceTray;
		private var mPieceTray:PieceTray;
		private var mDraggedPiece:Piece;
		private var mPreviousPosition:Piece;
		private var mSubmit:UIButton;
		private var mBlocker:Sprite;
		private var mSubmitedSentence:UIButton;
		private var mSuccessFeedback:Sprite;
		private var mReset:Boolean;
		private var mProgressFeedbackTimer:Timer;
		
		private function get SentenceIsCorrect():Boolean
		{
			switch (mSentenceTray.AssembleSentence())
			{
				case "The field is on a hill.":
				case "A field is on the hill.":
				case "On a hill is the field.":
				case "On the hill is a field.":
					return true;
				default:
					return false;
			}
		}
		
		private function get SentenceIsValid():Boolean
		{
			switch (mSentenceTray.AssembleSentence())
			{
				case "The field is on a hill.":
				case "A field is on the hill.":
				case "On a hill is the field.":
				case "On the hill is a field.":
				case "The hill is on a field.":
				case "A hill is on the field.":
				case "The sun is on a hill.":
				case "A sun is on the hill.":
				case "The sun is on a field.":
				case "A sun is on the field.":
				case "The field is on a sun.":
				case "A field is on the sun.":
				case "The hill is on a sun.":
				case "A hill is on the sun.":
				case "On the field is a hill.":
				case "On a field is the hill.":
				case "On the sun is a hill.":
				case "On a sun is the hill.":
				case "On the sun is a field.":
				case "On a sun is the field.":
				case "On the field is a sun.":
				case "On a field is the sun.":
				case "On the hill is a sun.":
				case "On a hill is the sun.":
				case "The hill is a field.":
				case "A hill is the field.":
				case "The sun is a hill.":
				case "A sun is the hill.":
				case "The sun is a field.":
				case "A sun is the field.":
				case "The field is a hill.":
				case "A field is the hill.":
				case "The field is a sun.":
				case "A field is the sun.":
				case "The hill is a sun.":
				case "A hill is the sun.":
				case "The field is on.":
				case "A field is on.":
				case "The hill is on.":
				case "A hill is on.":
				case "The sun is on.":
				case "A sun is on.":
					return true;
				default:
					return false;
			}
		}
		
		public function WordDraggingDemo()
		{
			super();
			
			mLayout = new Sprite();
			mLayout.graphics.lineStyle(1, 0xCCCCCC);
			mLayout.graphics.drawRect(200, 100, 400, 220);
			mLayout.graphics.drawRect(118.5, 377.5, 563, 55);
			mLayout.graphics.drawRect(118.5, 440, 496, 55);
			addChild(mLayout);
			
			mChallengePicture = new Sprite();
			mChallengePicture.x = 205;
			mChallengePicture.y = 105;
			mChallengePicture.addChild(new Asset.TheFieldIsOnAHillBitmap() as Bitmap);
			addChild(mChallengePicture);
			
			mSentenceTray = new SentenceTray(false);
			mSentenceTray.x = 113.5;
			mSentenceTray.y = 405;
			mSentenceTray.addEventListener(PieceTrayEvent.PIECE_FREED, OnPieceFreedSentenceTray);
			addChild(mSentenceTray);
			
			mPieceTray = new PieceTray(false, new <String>["field", "hill", "on", "sun", "is", "the", "a"]);
			mPieceTray.x = 113.5;
			mPieceTray.y = 467.5;
			mPieceTray.addEventListener(PieceTrayEvent.PIECE_FREED, OnPieceFreedPieceTray);
			addChild(mPieceTray);
			
			mSubmit = new UIButton("√", 0xCCCCCC);
			mSubmit.x = 648.5;
			mSubmit.y = 405;
			mSubmit.addEventListener(MouseEvent.CLICK, OnClickSubmit);
			addChild(mSubmit);
			
			mBlocker = new Sprite();
			mBlocker.addEventListener(MouseEvent.CLICK, OnClickBlocker);
			mBlocker.graphics.beginFill(0x000000, 0);
			mBlocker.graphics.drawRect(0, 0, 800, 600);
			mBlocker.graphics.endFill();
			
			mProgressFeedbackTimer = new Timer(4000, 1);
			mProgressFeedbackTimer.addEventListener(TimerEvent.TIMER_COMPLETE, OnProgressFeedbackTimerComplete);
			
			ProgressState();
		}
		
		private function ProgressState(aState:WordDraggingDemoState = null):void
		{
			if (aState)
			{
				mState = aState;
			}
			else if (mState)
			{
				mState = mState.NextState;
			}
			else
			{
				mState = WordDraggingDemoState.WORD_SELECTING;
			}
			
			mProgressFeedbackTimer.reset();
			mProgressFeedbackTimer.start();
		}
		
		private function OnProgressFeedbackTimerComplete(aEvent:TimerEvent):void
		{
			switch (mState)
			{
				case WordDraggingDemoState.WORD_SELECTING:
					mPieceTray.CallAttention();
					break;
				case WordDraggingDemoState.WORD_SORTING:
					mSentenceTray.CallAttention();
					if (SentenceIsValid)
					{
						ProgressState(WordDraggingDemoState.SENTENCE_SUBMITTING);
					}
					break;
				case WordDraggingDemoState.SENTENCE_SUBMITTING:
					mSubmit.CallAttention(true);
					break;
				case null:
					throw new Error("State is null!");
					return;
				default:
					throw new Error("State " + mState.Description + " is not handled.");
					return;
			}
		}
		
		private function OnPieceFreedSentenceTray(aEvent:PieceTrayEvent):void
		{
			if (aEvent.Dragged)
			{
				mPreviousPosition = aEvent.EventPiece.NextPiece;
				
				mDraggedPiece = new Piece(null, null, aEvent.EventPiece.Content, new Point(mouseX, mouseY));
				mDraggedPiece.y = mSentenceTray.y;
				addChild(mDraggedPiece);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMoveStage);
				stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUpStage);
				
				(new Asset.WordSound["_" + mDraggedPiece.Content]() as Sound).play();
			}
			else
			{
				mPieceTray.InsertLast(aEvent.EventPiece.Content, new Point(mouseX - mPieceTray.x, mouseY - mPieceTray.y));
				
				(new Asset.WordSound["_" + aEvent.EventPiece.Content]() as Sound).play();
			}
			
			mSentenceTray.Remove(aEvent.EventPiece);
			
			mSubmit.Color = (mSentenceTray.AssembleSentence().length > 0 ? 0xAAFF99 : 0xCCCCCC);
			
			if (!mSentenceTray.MoreThanOne)
			{
				ProgressState(WordDraggingDemoState.WORD_SELECTING);
			}
		}
		
		private function OnPieceFreedPieceTray(aEvent:PieceTrayEvent):void
		{
			if (aEvent.Dragged)
			{
				mPreviousPosition = aEvent.EventPiece.NextPiece;
				
				mDraggedPiece = new Piece(null, null, aEvent.EventPiece.Content, new Point(mouseX, mouseY));
				mDraggedPiece.y = mPieceTray.y;
				addChild(mDraggedPiece);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMoveStage);
				stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUpStage);
				
				(new Asset.WordSound["_" + mDraggedPiece.Content]() as Sound).play();
			}
			else
			{
				mSentenceTray.InsertLast(aEvent.EventPiece.Content, new Point(mouseX - mSentenceTray.x, mouseY - mSentenceTray.y));
				
				(new Asset.WordSound["_" + aEvent.EventPiece.Content]() as Sound).play();
				
				mSubmit.Color = 0xAAFF99;
				
				if (mSentenceTray.MoreThanOne)
				{
					ProgressState(WordDraggingDemoState.WORD_SORTING);
				}
			}
			
			mPieceTray.Remove(aEvent.EventPiece);
		}
		
		private function OnMouseMoveStage(aEvent:MouseEvent):void
		{
			mDraggedPiece.Position = new Point(mouseX, mouseY);
			
			if (Math.abs(mDraggedPiece.y - mSentenceTray.y) <= Math.abs(mDraggedPiece.y - mPieceTray.y))
			{
				mSentenceTray.MakePlace(mDraggedPiece);
				mPieceTray.FreePlace();
			}
			else
			{
				mSentenceTray.FreePlace();
				mPieceTray.MakePlace(mDraggedPiece);
			}
		}
		
		private function OnMouseUpStage(aEvent:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMoveStage);
			stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUpStage);
			
			if (Math.abs(mDraggedPiece.y - mSentenceTray.y) <= Math.abs(mDraggedPiece.y - mPieceTray.y))
			{
				mSentenceTray.addEventListener(PieceTrayEvent.PIECE_CAPTURED, OnPieceCapturedSentenceTray);
				mSentenceTray.Insert(mDraggedPiece, mPreviousPosition);
				
				mSubmit.Color = 0xAAFF99;
				
				if (mSentenceTray.MoreThanOne)
				{
					ProgressState(WordDraggingDemoState.WORD_SORTING);
				}
			}
			else
			{
				mPieceTray.addEventListener(PieceTrayEvent.PIECE_CAPTURED, OnPieceCapturedPieceTray);
				mPieceTray.Insert(mDraggedPiece, mPreviousPosition);
				
				if (SentenceIsValid)
				{
					ProgressState(WordDraggingDemoState.SENTENCE_SUBMITTING);
				}
			}
		}
		
		private function OnPieceCapturedSentenceTray(aEvent:PieceTrayEvent):void
		{
			mSentenceTray.removeEventListener(PieceTrayEvent.PIECE_CAPTURED, OnPieceCapturedSentenceTray);
			
			removeChild(aEvent.EventPiece);
			if (aEvent.EventPiece == mDraggedPiece)
			{
				mDraggedPiece = null;
			}
			
			ProgressState(WordDraggingDemoState.WORD_SORTING);
		}
		
		private function OnPieceCapturedPieceTray(aEvent:PieceTrayEvent):void
		{
			mPieceTray.removeEventListener(PieceTrayEvent.PIECE_CAPTURED, OnPieceCapturedPieceTray);
			
			removeChild(aEvent.EventPiece);
			if (aEvent.EventPiece == mDraggedPiece)
			{
				mDraggedPiece = null;
			}
		}
		
		private function OnClickSubmit(aEvent:MouseEvent):void
		{
			var sentence:String = mSentenceTray.AssembleSentence();
			if (!sentence.length)
			{
				return;
			}
			
			mSubmitedSentence = new UIButton(sentence, 0x99EEFF);
			mSubmitedSentence.x = mSentenceTray.Center;
			mSubmitedSentence.y = mSentenceTray.y;
			mSubmitedSentence.width = mSentenceTray.width;
			addChild(mSubmitedSentence);
			TweenLite.to(mSubmitedSentence, 0.5, { ease:Strong.easeIn, onComplete:OnTweenSquashSubmitedSentence, scaleX:1 });
			
			mSentenceTray.visible = false;
			
			addChild(mBlocker);
		}
		
		private function OnClickBlocker(aEvent:MouseEvent):void
		{
		}
		
		private function OnTweenSquashSubmitedSentence():void
		{
			(new Asset.SnappingSound() as Sound).play();
			
			TweenLite.to(mSubmitedSentence, 0.5, { ease:Elastic.easeOut, onComplete:OnTweenCenterSubmitedSentence, x:400, y:189 });
		}
		
		private function OnTweenCenterSubmitedSentence():void
		{
			if (SentenceIsCorrect)
			{
				var sentence:String = mSentenceTray.AssembleSentence();
				sentence = sentence.substr(0, sentence.length - 1);
				sentence = sentence.toLowerCase();
				sentence = sentence.split(" ").join("_");
				
				(new Asset.SentenceSound["_" + sentence]() as Sound).play();
			}
			
			TweenLite.to(mSubmitedSentence, 1, { ease:Elastic.easeOut, onComplete:OnTweenStretchSubmitedSentence, scaleX:2, scaleY:2 });
		}
		
		private function OnTweenStretchSubmitedSentence():void
		{
			mSuccessFeedback = new Sprite();
			mSuccessFeedback.addEventListener(MouseEvent.CLICK, OnClickSuccessFeedback);
			mSuccessFeedback.graphics.beginFill(0x000000, 0);
			mSuccessFeedback.graphics.drawRect(0, 0, 800, 600);
			mSuccessFeedback.graphics.endFill();
			mSuccessFeedback.alpha = 0;
			addChild(mSuccessFeedback);
			
			var successLabel:TextField = new TextField();
			successLabel.autoSize = TextFieldAutoSize.CENTER;
			successLabel.selectable = false;
			successLabel.filters = [new DropShadowFilter(1.5, 45, 0x000000, 1, 2, 2, 3, BitmapFilterQuality.HIGH)];
			
			if (SentenceIsCorrect)
			{
				mReset = true;
				
				successLabel.text = "\"" + mSubmitedSentence.Content + "\"\n\nYOU WIN!\n\nCLICK TO\nSTART OVER";
				successLabel.setTextFormat(new TextFormat(null, 40, 0x99EEFF, true, null, null, null, null, "center"));
				
				(new Asset.CrescendoSound() as Sound).play();
				
				mSubmitedSentence.Color = 0xAAFF99;
			}
			else if (SentenceIsValid)
			{
				successLabel.text = "\"" + mSubmitedSentence.Content + "\"\n\nGREAT SENTENCE!\nTRY AGAIN!\n\nCLICK TO\nCONTINUE";
				successLabel.setTextFormat(new TextFormat(null, 40, 0xFFEE99, true, null, null, null, null, "center"));
				
				(new Asset.ValidationSound() as Sound).play();
				
				mSubmitedSentence.Color = 0xFFEE99;
			}
			else
			{
				mReset = true;
				
				successLabel.text = "\"" + mSubmitedSentence.Content + "\"\n\nTRY AGAIN!\n\nCLICK TO\nCONTINUE";
				successLabel.setTextFormat(new TextFormat(null, 40, 0xFF99AA, true, null, null, null, null, "center"));
				
				(new Asset.ErrorSound() as Sound).play();
				
				mSubmitedSentence.Color = 0xFF99AA;
			}
			
			successLabel.x = 400 - (successLabel.width / 2);
			successLabel.y = 300 - (successLabel.height / 2);
			mSuccessFeedback.addChild(successLabel);
			
			TweenLite.to(mSuccessFeedback, 0.5, { ease:Strong.easeOut, alpha:1 } );
			TweenLite.to(mSubmitedSentence, 0.5, { ease:Strong.easeOut, onComplete:OnTweenDisappearSubmitedSentence, alpha:0 });
		}
		
		private function OnTweenDisappearSubmitedSentence():void
		{
			mSubmitedSentence.Dispose();
			removeChild(mSubmitedSentence);
			mSubmitedSentence = null;
			
			removeChild(mBlocker);
		}
		
		private function OnClickSuccessFeedback(aEvent:MouseEvent):void
		{
			mSuccessFeedback.removeEventListener(MouseEvent.CLICK, OnClickSuccessFeedback);
			
			TweenLite.to(mSuccessFeedback, 0.5, { ease:Strong.easeOut, onComplete:OnTweenHideSuccessFeedback, alpha:0 } );
			
			if (mReset)
			{
				mSentenceTray.Clear();
				mPieceTray.Clear(new <String>["field", "hill", "on", "sun", "is", "the", "a"]);
				
				mSubmit.Color = 0xCCCCCC;
				
				mReset = false;
				
				ProgressState(WordDraggingDemoState.WORD_SELECTING);
			}
			else
			{
				ProgressState(WordDraggingDemoState.WORD_SORTING);
			}
			
			mSentenceTray.visible = true;
		}
		
		private function OnTweenHideSuccessFeedback():void
		{
			removeChild(mSuccessFeedback);
			mSuccessFeedback = null;
		}
	}
}