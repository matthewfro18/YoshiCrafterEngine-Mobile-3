package;

import openfl.media.Sound;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	
	public static var char = "Friday Night Funkin':bf-dead";
	public static var firstDeathSFX = "Friday Night Funkin':fnf_loss_sfx";
	public static var gameOverMusic = "Friday Night Funkin':gameOver";
	public static var gameOverMusicBPM = 100;
	public static var retrySFX = "Friday Night Funkin':gameOverEnd";

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, CoolUtil.getCharacterFullString(char, PlayState.songMod));
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		var sfx = firstDeathSFX.split(":");
		if (firstDeathSFX.length == 0) sfx = ["Friday Night Funkin'", "fnf_loss_sfx"];
		if (sfx.length == 1) sfx.insert(0, PlayState.songMod);
		var mod = sfx[0];
		var file = sfx[1];
		var mFolder = Paths.getModsFolder();

		FlxG.sound.play(Sound.fromFile('$mFolder\\$mod\\sounds\\$file' + #if web '.mp3' #else '.ogg' #end));
		Conductor.changeBPM(gameOverMusicBPM);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			var sfx = gameOverMusic.split(":");
			if (firstDeathSFX.length == 0) sfx = ["Friday Night Funkin'", "gameOver"];
			if (sfx.length == 1) sfx.insert(0, PlayState.songMod);
			var mod = sfx[0];
			var file = sfx[1];
			var mFolder = Paths.getModsFolder();
			FlxG.sound.playMusic(Sound.fromFile('$mFolder\\$mod\\music\\$file' + #if web '.mp3' #else '.ogg' #end));
			bf.playAnim('deathLoop');
		}

		if (FlxG.sound.music != null)
			if (FlxG.sound.music.playing)
				Conductor.songPosition = FlxG.sound.music.time;
	}

	var danced = false;
	override function beatHit()
	{
		super.beatHit();

		if (bf != null) {
			if (bf.animation.curAnim != null) {
				if ((bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished) || bf.animation.curAnim.name == 'deathLoop')
				{
					danced = !danced;
					if (danced) bf.playAnim('deathLoop', true);
				}
			}
		}
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();

			
			var sfx = retrySFX.split(":");
			if (firstDeathSFX.length == 0) sfx = ["Friday Night Funkin'", "gameOverEnd"];
			if (sfx.length == 1) sfx.insert(0, PlayState.songMod);
			var mod = sfx[0];
			var file = sfx[1];
			var mFolder = Paths.getModsFolder();
			FlxG.sound.playMusic(Sound.fromFile('$mFolder\\$mod\\sounds\\$file' + #if web '.mp3' #else '.ogg' #end));

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
