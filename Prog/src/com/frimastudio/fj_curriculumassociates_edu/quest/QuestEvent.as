package com.frimastudio.fj_curriculumassociates_edu.quest
{
	import flash.events.Event;
	
	public class QuestEvent extends Event
	{
		public static const COMPLETE:String = "com.frimastudio.fj_curriculumassociates_edu.quest.QuestEvent::COMPLETE";
		
		public function QuestEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new QuestEvent(type, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("QuestEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}