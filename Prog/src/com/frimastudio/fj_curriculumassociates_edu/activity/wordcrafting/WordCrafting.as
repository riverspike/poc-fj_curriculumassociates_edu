package com.frimastudio.fj_curriculumassociates_edu.activity.wordcrafting
{
	import com.frimastudio.fj_curriculumassociates_edu.activity.Activity;
	import com.frimastudio.fj_curriculumassociates_edu.activity.Result;
	import com.frimastudio.fj_curriculumassociates_edu.Asset;
	import com.frimastudio.fj_curriculumassociates_edu.dictionary.WordDictionary;
	import com.frimastudio.fj_curriculumassociates_edu.FontList;
	import com.frimastudio.fj_curriculumassociates_edu.quest.QuestStepEvent;
	import com.frimastudio.fj_curriculumassociates_edu.ui.box.Box;
	import com.frimastudio.fj_curriculumassociates_edu.ui.box.BoxIcon;
	import com.frimastudio.fj_curriculumassociates_edu.ui.box.BoxLabel;
	import com.frimastudio.fj_curriculumassociates_edu.ui.box.CurvedBox;
	import com.frimastudio.fj_curriculumassociates_edu.ui.Palette;
	import com.frimastudio.fj_curriculumassociates_edu.ui.piecetray.Piece;
	import com.frimastudio.fj_curriculumassociates_edu.ui.piecetray.PieceEvent;
	import com.frimastudio.fj_curriculumassociates_edu.ui.piecetray.PieceTray;
	import com.frimastudio.fj_curriculumassociates_edu.ui.piecetray.PieceTrayEvent;
	import com.frimastudio.fj_curriculumassociates_edu.ui.UIButton;
	import com.frimastudio.fj_curriculumassociates_edu.util.Axis;
	import com.frimastudio.fj_curriculumassociates_edu.util.Direction;
	import com.frimastudio.fj_curriculumassociates_edu.util.DisplayObjectUtil;
	import com.frimastudio.fj_curriculumassociates_edu.util.Geometry;
	import com.frimastudio.fj_curriculumassociates_edu.util.MouseUtil;
	import com.frimastudio.fj_curriculumassociates_edu.util.Random;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class WordCrafting extends Activity
	{
		private var mTemplate:WordCraftingTemplate;
		private var mNPC:Bitmap;
		private var mProp:Bitmap;
		private var mMini:Sprite;
		private var mToolTray:PieceTray;
		private var mCraftingTray:PieceTray;
		private var mSubmitBtn:CurvedBox;
		private var mDialogBox:Box;
		private var mAnswerField:CurvedBox;
		private var mPreviousPosition:Piece;
		private var mDraggedPiece:Piece;
		private var mLearnedWordList:Object;
		private var mSubmitedWord:UIButton;
		private var mSubmissionHighlight:Sprite;
		private var mAnswer:String;
		private var mResult:Result;
		private var mBlocker:Sprite;
		private var mSuccessFeedback:Sprite;
		private var mMiniSelected:Boolean;
		private var mFloatPieceList:Vector.<Piece>;
		private var mCraftingTrayField:CurvedBox;
		
		public function WordCrafting(aTemplate:WordCraftingTemplate)
		{
			super(aTemplate);
			
			mTemplate = aTemplate;
			
			mNPC = new mTemplate.NPCAsset();
			mNPC.x = 30;
			mNPC.y = 40;
			addChild(mNPC);
			
			mProp = new mTemplate.PropAsset();
			mProp.x = 275;
			mProp.y = 408;
			addChild(mProp);
			
			mMini = new Sprite();
			mMini.x = 685;
			mMini.y = 518;
			var miniBitmap:Bitmap = new Asset.MiniBitmap();
			miniBitmap.x = -miniBitmap.width / 2;
			miniBitmap.y = -miniBitmap.height / 2;
			mMini.addChild(miniBitmap);
			mMini.addEventListener(MouseEvent.CLICK, OnClickMini);
			addChild(mMini);
			
			mMiniSelected = true;
			mMini.filters = [new GlowFilter(Palette.GREAT_BTN, 1, 4, 4, 2, BitmapFilterQuality.HIGH)];
			TweenLite.to(mMini, 0.2, { ease:Quad.easeOut, onComplete:OnTweenSquashMini, overwrite:true,
				scaleX:1.2, scaleY:0.8, y:518 + (mMini.height / (8 * mMini.scaleY)) });
			
			var toolTrayBox:Box = new Box(new Point(1024, 90), Palette.TOOL_BOX);
			toolTrayBox.x = 512;
			toolTrayBox.y = 723;
			addChild(toolTrayBox);
			
			var craftingTrayBox:Box = new Box(new Point(1024, 90), Palette.CRAFTING_BOX);
			craftingTrayBox.x = 512;
			craftingTrayBox.y = 633;
			addChild(craftingTrayBox);
			
			mCraftingTrayField = new CurvedBox(new Point(910, 76), Palette.CRAFTING_FIELD);
			mCraftingTrayField.x = 482;
			mCraftingTrayField.y = 633;
			addChild(mCraftingTrayField);
			
			var craftingIcon:Bitmap = new Asset.IconWriteBitmap();
			craftingIcon.x = 40;
			craftingIcon.y = 633 - (craftingIcon.height / 2);
			addChild(craftingIcon);
			
			mToolTray = new PieceTray(false, mTemplate.WordList);
			mToolTray.x = 90;
			mToolTray.y = 723;
			mToolTray.addEventListener(PieceTrayEvent.PIECE_FREED, OnPieceFreedToolTray);
			addChild(mToolTray);
			
			mCraftingTray = new PieceTray(false);
			mCraftingTray.x = 90;
			mCraftingTray.y = 633;
			mCraftingTray.addEventListener(PieceTrayEvent.PIECE_FREED, OnPieceFreedCraftingTray);
			addChild(mCraftingTray);
			
			mSubmitBtn = new CurvedBox(new Point(64, 64), Palette.GREAT_BTN,
				new BoxIcon(Asset.IconOKBitmap, Palette.BTN_CONTENT), 12);
			mSubmitBtn.x = 982;
			mSubmitBtn.y = 633;
			mSubmitBtn.addEventListener(MouseEvent.CLICK, OnClickSubmitBtn);
			addChild(mSubmitBtn);
			
			var answerFieldString:String = "___";
			for (var i:int = 0, endi:int = mTemplate.Answer.length; i < endi; ++i)
			{
				answerFieldString += "_";
			}
			var request:String = mTemplate.Request.split("_").join(answerFieldString);
			
			mDialogBox = new Box(new Point(584, 160), Palette.DIALOG_BOX, new BoxLabel(request, 60,
				Palette.DIALOG_CONTENT), 12, Direction.LEFT, Axis.VERTICAL);
			mDialogBox.HideLabelSubString(answerFieldString);
			mDialogBox.x = 640;
			mDialogBox.y = 50 + (mDialogBox.height / 2);
			addChild(mDialogBox);
			
			var answerFieldBoundary:Rectangle = mDialogBox.BoundaryOfLabelSubString(answerFieldString);
			mAnswerField = new CurvedBox(answerFieldBoundary.size, Palette.ANSWER_FIELD, null, 12);
			DisplayObjectUtil.SetPosition(mAnswerField,
				Geometry.RectangleCenter(answerFieldBoundary).add(DisplayObjectUtil.GetPosition(mDialogBox)));
			addChild(mAnswerField);
			
			mLearnedWordList = { };
			
			mResult = Result.WRONG;
			
			mBlocker = new Sprite();
			mBlocker.addEventListener(MouseEvent.CLICK, OnClickBlocker);
			mBlocker.graphics.beginFill(0x000000, 0);
			mBlocker.graphics.drawRect(0, 0, 1024, 768);
			mBlocker.graphics.endFill();
			
			mFloatPieceList = new Vector.<Piece>();
			
			UpdateAnswer();
		}
		
		override public function Dispose():void
		{
			var i:int, endi:int;
			
			mMini.removeEventListener(MouseEvent.CLICK, OnClickMini);
			mToolTray.removeEventListener(PieceTrayEvent.PIECE_FREED, OnPieceFreedToolTray);
			mCraftingTray.removeEventListener(PieceTrayEvent.PIECE_FREED, OnPieceFreedCraftingTray);
			mSubmitBtn.removeEventListener(MouseEvent.CLICK, OnClickSubmitBtn);
			mBlocker.removeEventListener(MouseEvent.CLICK, OnClickBlocker);
			
			mToolTray.Dispose();
			mCraftingTray.Dispose();
			
			for (i = 0, endi = mFloatPieceList.length; i < endi; ++i)
			{
				mFloatPieceList[i].Dispose();
			}
			mFloatPieceList.splice(0, mFloatPieceList.length);
		}
		
		private function UpdateAnswer():void
		{
			var answer:String = mCraftingTray.AssembleWord();
			if (answer.length)
			{
				mAnswerField.Content = new BoxLabel(answer, 72, Palette.ANSWER_CONTENT);
			}
			else
			{
				mAnswerField.Content = null;
			}
			
			mSubmitBtn.BoxColor = Palette.GREAT_BTN;
		}
		
		private function ShowSuccessFeedback():void
		{
			mSuccessFeedback = new Sprite();
			mSuccessFeedback.addEventListener(MouseEvent.CLICK, OnClickSuccessFeedback);
			mSuccessFeedback.graphics.beginFill(0x000000, 0);
			mSuccessFeedback.graphics.drawRect(0, 0, 1024, 768);
			mSuccessFeedback.graphics.endFill();
			mSuccessFeedback.alpha = 0;
			addChild(mSuccessFeedback);
			
			addChild(mBlocker);
			
			mSubmitBtn.BoxColor = mResult.Color;
			
			var successLabel:TextField = new TextField();
			successLabel.autoSize = TextFieldAutoSize.CENTER;
			successLabel.selectable = false;
			successLabel.filters = [new DropShadowFilter(1.5, 45, 0x000000, 1, 2, 2, 3, BitmapFilterQuality.HIGH)];
			
			switch (mResult)
			{
				case Result.GREAT:
					successLabel.text = "Click to continue.";
					(new Asset.CrescendoSound() as Sound).play();
					break;
				case Result.VALID:
					successLabel.text = "Great word!\nClick to try again";
					(new Asset.ValidationSound() as Sound).play();
					break;
				case Result.WRONG:
					successLabel.text = "Click to try again";
					(new Asset.ErrorSound() as Sound).play();
					break;
				default:
					throw new Error(mResult ? "Result " + mResult.Description + " is not handled" : "No result to handle.");
					return;
			}
			
			successLabel.embedFonts = true;
			successLabel.setTextFormat(new TextFormat(Asset.SweaterSchoolSemiBoldFont.fontName, 72, mResult.Color,
				null, null, null, null, null, "center"));
			successLabel.x = 512 - (successLabel.width / 2);
			successLabel.y = 384 - (successLabel.height / 2);
			var successBox:CurvedBox = new CurvedBox(new Point(successLabel.width + 24, successLabel.height), Palette.DIALOG_BOX);
			successBox.alpha = 0.7;
			successBox.x = 512;
			successBox.y = 384;
			mSuccessFeedback.addChild(successBox);
			mSuccessFeedback.addChild(successLabel);
			
			TweenLite.to(mSuccessFeedback, 0.5, { ease:Strong.easeOut, onComplete:OnTweenShowSuccessFeedback, alpha:1 });
			if (mResult == Result.GREAT)
			{
				if (mSubmitedWord)
				{
					TweenLite.to(mSubmitedWord, 0.5, { ease:Strong.easeOut, onComplete:OnTweenHideSubmitedWord, alpha:0 });
				}
			}
			if (mSubmissionHighlight)
			{
				TweenLite.to(mSubmissionHighlight, 0.5, { ease:Strong.easeOut, onComplete:OnTweenHideSubmissionHighlight, alpha:0 });
			}
		}
		
		private function OnClickMini(aEvent:MouseEvent):void
		{
			mMiniSelected = !mMiniSelected;
			mMini.filters = (mMiniSelected ? [new GlowFilter(Palette.GREAT_BTN, 1, 4, 4, 2, BitmapFilterQuality.HIGH)] : []);
			TweenLite.to(mMini, 0.2, { ease:Quad.easeOut, onComplete:OnTweenSquashMini, overwrite:true,
				scaleX:1.2, scaleY:0.8, y:518 + (mMini.height / (8 * mMini.scaleY)) });
		}
		
		private function OnTweenSquashMini():void
		{
			TweenLite.to(mMini, 0.5, { ease:Elastic.easeOut, scaleX:1, scaleY:1, y:518, overwrite:true });
		}
		
		private function OnPieceFreedToolTray(aEvent:PieceTrayEvent):void
		{
			if (aEvent.Dragged)
			{
				mPreviousPosition = aEvent.EventPiece.NextPiece;
				
				mDraggedPiece = new Piece(null, null, aEvent.EventPiece.Label, MouseUtil.PositionRelativeTo(this));
				mDraggedPiece.y = mToolTray.y;
				mDraggedPiece.filters = [new GlowFilter(Palette.GREAT_BTN, 0.5, 16, 16, 2, BitmapFilterQuality.HIGH)];
				addChild(mDraggedPiece);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMoveStage);
				stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUpStage);
			}
			else
			{
				if (mMiniSelected)
				{
					var piece:Piece = new Piece(null, null, aEvent.EventPiece.Label, MouseUtil.PositionRelativeTo(this));
					piece.y = mToolTray.y;
					addChild(piece);
					
					mFloatPieceList.push(piece);
					
					TweenLite.to(piece, 0.5, { ease:Strong.easeOut, onComplete:OnTweenSendFedWord,
						onCompleteParams:[piece], x:685, y:518 });
				}
				else
				{
					mCraftingTray.InsertLast(aEvent.EventPiece.Label, MouseUtil.PositionRelativeTo(mCraftingTray));
					
					UpdateAnswer();
				}
			}
			
			if (Asset.WordSound["_" + aEvent.EventPiece.Label])
			{
				(new Asset.WordSound["_" + aEvent.EventPiece.Label]() as Sound).play();
			}
			
			mToolTray.InsertLast(aEvent.EventPiece.Label, new Point(mToolTray.width + (aEvent.EventPiece.width / 2)));
			mToolTray.Remove(aEvent.EventPiece);
		}
		
		private function OnTweenSendFedWord(aPiece:Piece):void
		{
			var pieceLabelList:Vector.<String> = new <String>[aPiece.Label];
			switch (aPiece.Label)
			{
				case "hill":
					switch (Random.RangeInt(0, 2))
					{
						case 0:
							pieceLabelList = new <String>["h", "i", "l", "l"];
							break;
						case 1:
							pieceLabelList = new <String>["h", "i", "ll"];
							break;
						case 2:
							pieceLabelList = new <String>["h", "ill"];
							break;
						default:
							break;
					}
					break;
				case "felt":
					//switch (Random.RangeInt(0, 2))
					//{
						//case 0:
							pieceLabelList = new <String>["f", "e", "l", "t"];
							//break;
						//case 1:
							//pieceLabelList = new <String>["f", "e", "lt"];
							//break;
						//case 2:
							//pieceLabelList = new <String>["f", "elt"];
							//break;
						//default:
							//break;
					//}
					break;
				case "hall":
					//switch (Random.RangeInt(0, 2))
					switch (Random.RangeInt(0, 1))
					{
						case 0:
							pieceLabelList = new <String>["h", "a", "l", "l"];
							break;
						case 1:
							pieceLabelList = new <String>["h", "a", "ll"];
							break;
						//case 2:
							//pieceLabelList = new <String>["h", "all"];
							//break;
						default:
							break;
					}
					break;
				case "fair":
					//switch (Random.RangeInt(0, 1))
					//{
						//case 0:
							pieceLabelList = new <String>["f", "a", "i", "r"];
							//break;
						//case 1:
							//pieceLabelList = new <String>["f", "a", "ir"];
							//break;
						//default:
							//break;
					//}
					break;
				default:
					break;
			}
			
			TweenLite.to(aPiece, 0.2, { ease:Elastic.easeOut, onComplete:OnTweenStretchFedWord,
				onCompleteParams:[aPiece, pieceLabelList], width:aPiece.width + ((pieceLabelList.length - 1) * (5 + 12 + 12)) });
		}
		
		private function OnTweenStretchFedWord(aPiece:Piece, aPieceLabelList:Vector.<String>):void
		{
			var piece:Piece;
			var position:Point = new Point(aPiece.x - (aPiece.width / 2), aPiece.y);
			for (var i:int = 0, endi:int = aPieceLabelList.length; i < endi; ++i)
			{
				piece = new Piece(null, null, aPieceLabelList[i], position);
				position.x += piece.width / 2;
				piece.x = position.x;
				piece.Position = new Point(piece.x, piece.y);
				position.x += piece.width / 2;
				position.x += 5;
				piece.addEventListener(MouseEvent.CLICK, OnClickFloatPiece);
				piece.addEventListener(PieceEvent.REMOVE, OnRemoveFloatPiece);
				piece.StartDecay();
				var bubble:Bitmap = new Asset.BubbleBitmap();
				bubble.smoothing = true;
				bubble.width = Math.max(bubble.width, piece.width + 30);
				bubble.scaleY = bubble.scaleX;
				bubble.x = -bubble.width / 2;
				bubble.y = -bubble.height / 2;
				piece.addChild(bubble);
				addChild(piece);
				mFloatPieceList.push(piece);
				TweenLite.to(piece, 2, { ease:Quad.easeOut, x:Random.Range(455, 950), y:Random.Range(260, 415) });
			}
			
			mFloatPieceList.splice(mFloatPieceList.indexOf(aPiece), 1);
			aPiece.Dispose();
			removeChild(aPiece);
		}
		
		private function OnPieceFreedCraftingTray(aEvent:PieceTrayEvent):void
		{
			if (aEvent.Dragged)
			{
				mPreviousPosition = aEvent.EventPiece.NextPiece;
				
				mDraggedPiece = new Piece(null, null, aEvent.EventPiece.Label, MouseUtil.PositionRelativeTo(this));
				mDraggedPiece.y = mCraftingTray.y;
				mDraggedPiece.filters = [new GlowFilter(Palette.GREAT_BTN, 0.5, 16, 16, 2, BitmapFilterQuality.HIGH)];
				addChild(mDraggedPiece);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMoveStage);
				stage.addEventListener(MouseEvent.MOUSE_UP, OnMouseUpStage);
			}
			else
			{
				var piece:Piece = new Piece(null, null, aEvent.EventPiece.Label, MouseUtil.PositionRelativeTo(this));
				piece.y = mCraftingTray.y;
				piece.addEventListener(MouseEvent.CLICK, OnClickFloatPiece);
				piece.addEventListener(PieceEvent.REMOVE, OnRemoveFloatPiece);
				piece.StartDecay();
				var bubble:Bitmap = new Asset.BubbleBitmap();
				bubble.smoothing = true;
				bubble.width = Math.max(bubble.width, piece.width + 30);
				bubble.scaleY = bubble.scaleX;
				bubble.x = -bubble.width / 2;
				bubble.y = -bubble.height / 2;
				piece.addChild(bubble);
				addChild(piece);
				mFloatPieceList.push(piece);
				TweenLite.to(piece, 2, { ease:Quad.easeOut, x:Random.Range(455, 950), y:Random.Range(260, 415) });
			}
			
			if (Asset.LetterSound["_" + aEvent.EventPiece.Label])
			{
				(new Asset.LetterSound["_" + aEvent.EventPiece.Label]() as Sound).play();
			}
			else if (Asset.ChunkSound["_" + aEvent.EventPiece.Label])
			{
				(new Asset.ChunkSound["_" + aEvent.EventPiece.Label]() as Sound).play();
			}
			else if (Asset.WordSound["_" + aEvent.EventPiece.Label])
			{
				(new Asset.WordSound["_" + aEvent.EventPiece.Label]() as Sound).play();
			}
			
			mCraftingTray.Remove(aEvent.EventPiece);
			
			UpdateAnswer();
		}
		
		private function OnMouseMoveStage(aEvent:MouseEvent):void
		{
			mDraggedPiece.Position = MouseUtil.PositionRelativeTo(this);
			
			if (mDraggedPiece.getBounds(this).intersects(mMini.getBounds(this)))
			{
				mCraftingTray.FreePlace();
			}
			else if (mDraggedPiece.getBounds(this).intersects(mCraftingTrayField.getBounds(this)))
			{
				mCraftingTray.MakePlace(mDraggedPiece);
			}
			else
			{
				mCraftingTray.FreePlace();
			}
		}
		
		private function OnMouseUpStage(aEvent:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, OnMouseMoveStage);
			stage.removeEventListener(MouseEvent.MOUSE_UP, OnMouseUpStage);
			
			var piece:Piece;
			if (mDraggedPiece.getBounds(this).intersects(mMini.getBounds(this)))
			{
				piece = new Piece(null, null, mDraggedPiece.Label, MouseUtil.PositionRelativeTo(this));
				addChild(piece);
				
				mFloatPieceList.push(piece);
				
				TweenLite.to(piece, 0.1, { ease:Strong.easeOut, onComplete:OnTweenSendFedWord,
					onCompleteParams:[piece], x:685, y:518 } );
				
				mDraggedPiece.Dispose();
				removeChild(mDraggedPiece);
				mDraggedPiece = null;
			}
			else if (mDraggedPiece.getBounds(this).intersects(mCraftingTrayField.getBounds(this)))
			{
				mCraftingTray.addEventListener(PieceTrayEvent.PIECE_CAPTURED, OnPieceCapturedCraftingTray);
				mCraftingTray.Insert(mDraggedPiece, mPreviousPosition);
				
				UpdateAnswer();
			}
			else
			{
				piece = new Piece(null, null, mDraggedPiece.Label, MouseUtil.PositionRelativeTo(this));
				piece.addEventListener(MouseEvent.CLICK, OnClickFloatPiece);
				piece.addEventListener(PieceEvent.REMOVE, OnRemoveFloatPiece);
				piece.StartDecay();
				var bubble:Bitmap = new Asset.BubbleBitmap();
				bubble.smoothing = true;
				bubble.width = Math.max(bubble.width, piece.width + 30);
				bubble.scaleY = bubble.scaleX;
				bubble.x = -bubble.width / 2;
				bubble.y = -bubble.height / 2;
				piece.addChild(bubble);
				addChild(piece);
				mFloatPieceList.push(piece);
				TweenLite.to(piece, 2, { ease:Quad.easeOut, x:Random.Range(455, 950), y:Random.Range(260, 415) });
				
				mDraggedPiece.Dispose();
				removeChild(mDraggedPiece);
				mDraggedPiece = null;
			}
		}
		
		private function OnClickFloatPiece(aEvent:MouseEvent):void
		{
			var piece:Piece = aEvent.currentTarget as Piece;
			piece.removeEventListener(MouseEvent.CLICK, OnClickFloatPiece);
			piece.removeEventListener(PieceEvent.REMOVE, OnRemoveFloatPiece);
			
			if (Asset.LetterSound["_" + piece.Label])
			{
				(new Asset.LetterSound["_" + piece.Label]() as Sound).play();
			}
			else if (Asset.ChunkSound["_" + piece.Label])
			{
				(new Asset.ChunkSound["_" + piece.Label]() as Sound).play();
			}
			else if (Asset.WordSound["_" + piece.Label])
			{
				(new Asset.WordSound["_" + piece.Label]() as Sound).play();
			}
			
			mCraftingTray.InsertLast(piece.Label, MouseUtil.PositionRelativeTo(mCraftingTray));
			
			UpdateAnswer();
			
			var bubbleSplash:Bitmap = new Asset.BubbleSplashBitmap();
			bubbleSplash.x = piece.x - (bubbleSplash.width / 2);
			bubbleSplash.y = piece.y - (bubbleSplash.height / 2);
			addChild(bubbleSplash);
			TweenLite.to(bubbleSplash, 1, { ease:Strong.easeOut, onComplete:OnTweenHideBubbleSplash,
				onCompleteParams:[bubbleSplash], alpha:0 });
			
			mFloatPieceList.splice(mFloatPieceList.indexOf(piece), 1);
			piece.Dispose();
			removeChild(piece);
		}
		
		private function OnTweenHideBubbleSplash(aBubbleSplash:Bitmap):void
		{
			removeChild(aBubbleSplash);
		}
		
		private function OnRemoveFloatPiece(aEvent:PieceEvent):void
		{
			var piece:Piece = aEvent.currentTarget as Piece;
			piece.removeEventListener(MouseEvent.CLICK, OnClickFloatPiece);
			piece.removeEventListener(PieceEvent.REMOVE, OnRemoveFloatPiece);
			
			mFloatPieceList.splice(mFloatPieceList.indexOf(piece), 1);
			piece.Dispose();
			
			TweenLite.to(piece, 1, { ease:Strong.easeOut, onComplete:OnTweenHideFloatPiece, onCompleteParams:[piece], alpha:0 } );
		}
		
		private function OnTweenHideFloatPiece(aPiece:Piece):void
		{
			removeChild(aPiece);
		}
		
		private function OnPieceCapturedCraftingTray(aEvent:PieceTrayEvent):void
		{
			mCraftingTray.removeEventListener(PieceTrayEvent.PIECE_CAPTURED, OnPieceCapturedCraftingTray);
			
			aEvent.EventPiece.Dispose();
			removeChild(aEvent.EventPiece);
			if (aEvent.EventPiece == mDraggedPiece)
			{
				mDraggedPiece = null;
			}
			
			UpdateAnswer();
		}
		
		private function OnClickSubmitBtn(aEvent:MouseEvent):void
		{
			var answer:String = mCraftingTray.AssembleWord();
			if (answer.length)
			{
				mAnswer = answer;
				if (mAnswer == mTemplate.Answer)
				{
					mResult = Result.GREAT;
					mLearnedWordList[mAnswer] = mAnswer;
				}
				else if (WordDictionary.Validate(mAnswer, 1))
				{
					mResult = Result.VALID;
					mLearnedWordList[mAnswer] = mAnswer;
				}
				else
				{
					mResult = Result.WRONG;
				}
				
				addChild(mBlocker);
				
				mCraftingTray.Color = mResult.Color;
				mCraftingTray.ContentColor = Palette.BTN_CONTENT;
				
				if (mResult == Result.WRONG)
				{
					var explodeDuration:Number = mCraftingTray.FizzleAndExplode();
					var explodeWordTimer:Timer = new Timer(explodeDuration * 1000, 1);
					explodeWordTimer.addEventListener(TimerEvent.TIMER_COMPLETE, OnExplodeWordTimerComplete);
					explodeWordTimer.start();
				}
				else
				{
					var bounceDuration:Number = mCraftingTray.BounceInSequence();
					var submitWordTimer:Timer = new Timer(bounceDuration * 1000, 1);
					submitWordTimer.addEventListener(TimerEvent.TIMER_COMPLETE, OnSumbitWordTimerComplete);
					submitWordTimer.start();
				}
				
				(new Asset.SnappingSound() as Sound).play();
			}
			else
			{
				mResult = Result.WRONG;
				mSubmitBtn.BoxColor = mResult.Color;
			}
		}
		
		private function OnClickBlocker(aEvent:MouseEvent):void
		{
		}
		
		private function OnExplodeWordTimerComplete(aEvent:TimerEvent):void
		{
			(aEvent.currentTarget as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, OnExplodeWordTimerComplete);
			
			mCraftingTray.visible = false;
			
			ShowSuccessFeedback();
		}
		
		private function OnSumbitWordTimerComplete(aEvent:TimerEvent):void
		{
			(aEvent.currentTarget as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, OnSumbitWordTimerComplete);
			
			mSubmitedWord = new UIButton(mAnswer, mResult.Color);
			mSubmitedWord.x = mCraftingTray.Center;
			mSubmitedWord.y = mCraftingTray.y;
			mSubmitedWord.width = mCraftingTray.width;
			if (mResult == Result.GREAT)
			{
				mSubmissionHighlight = new Sprite();
				mSubmissionHighlight.x = mSubmitedWord.x;
				mSubmissionHighlight.y = mSubmitedWord.y;
				mSubmissionHighlight.addEventListener(Event.ENTER_FRAME, OnEnterFrameSubmissionHighlight);
				var highlightBitmap:Bitmap = new Asset.SubmissionHighlightBitmap() as Bitmap;
				highlightBitmap.smoothing = true;
				highlightBitmap.x = -highlightBitmap.width / 2;
				highlightBitmap.y = -highlightBitmap.height / 2;
				mSubmissionHighlight.addChild(highlightBitmap);
				addChild(mSubmissionHighlight);
				
				TweenLite.to(mSubmissionHighlight, 0.5, { ease:Strong.easeOut, x:mAnswerField.x, y:mAnswerField.y,
					scaleX:1, scaleY:1 });
			}
			addChild(mSubmitedWord);
			
			mCraftingTray.visible = false;
			
			var target:Point = DisplayObjectUtil.GetPosition(mAnswerField);
			var scale:Number = 1;
			if (mResult == Result.VALID)
			{
				target = new Point(512, 230);
				scale = 1.5;
			}
			TweenLite.to(mSubmitedWord, 0.5, { ease:Strong.easeOut, onComplete:OnTweenSendSubmitedWord,
				x:target.x, y:target.y, scaleX:scale, scaleY:scale });
		}
		
		private function OnEnterFrameSubmissionHighlight(aEvent:Event):void
		{
			mSubmissionHighlight.rotation += 3;
		}
		
		private function OnTweenSendSubmitedWord():void
		{
			if (mResult == Result.GREAT)
			{
				mAnswerField.Content = new BoxLabel(mCraftingTray.AssembleWord(), 72, mResult.Color, true);
			}
			
			ShowSuccessFeedback();
		}
		
		private function OnTweenShowSuccessFeedback():void
		{
			removeChild(mBlocker);
		}
		
		private function OnTweenHideSubmitedWord():void
		{
			mSubmitedWord.Dispose();
			removeChild(mSubmitedWord);
			mSubmitedWord = null;
			
			if (mResult == Result.GREAT)
			{
				(new Asset.SentenceSound["_i_need_to_fill_up_this_cup"]() as Sound).play();
			}
		}
		
		private function OnTweenHideSubmissionHighlight():void
		{
			removeChild(mSubmissionHighlight);
			mSubmissionHighlight.removeEventListener(Event.ENTER_FRAME, OnEnterFrameSubmissionHighlight);
			mSubmissionHighlight = null;
		}
		
		private function OnClickSuccessFeedback(aEvent:MouseEvent):void
		{
			if (mResult == Result.VALID)
			{
				if (mSubmitedWord)
				{
					TweenLite.to(mSubmitedWord, 0.5, { ease:Strong.easeOut, onComplete:OnTweenHideSubmitedWord, alpha:0 });
				}
			}
			
			mSuccessFeedback.removeEventListener(MouseEvent.CLICK, OnClickSuccessFeedback);
			TweenLite.to(mSuccessFeedback, 0.5, { ease:Strong.easeOut, onComplete:OnTweenHideSuccessFeedback, alpha:0 } );
			
			if (mResult != Result.GREAT)
			{
				mCraftingTray.Clear();
				mCraftingTray.visible = true;
				
				UpdateAnswer();
			}
		}
		
		private function OnTweenHideSuccessFeedback():void
		{
			removeChild(mSuccessFeedback);
			mSuccessFeedback = null;
			
			if (mResult == Result.GREAT)
			{
				dispatchEvent(new QuestStepEvent(QuestStepEvent.COMPLETE));
			}
		}
	}
}