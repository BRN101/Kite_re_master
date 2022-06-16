package;

import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxEase;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	static function weekData():Array<Dynamic>
	{
		return [
			['Calm', 'Dominating', 'Skills', 'Envy']
		];
	}
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [];

	var weekCharacters:Array<Dynamic> = [
		['kite', 'bf', 'gf']
	];

	var weekNames:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekNames'));

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var charInputs:String;
	var cheatCode1:String = "ITEPRO"; //IT'S REALLY "KITEPRO" BUT FOR SOME REASON IT DOESN'T CATCH THE K

	function unlockWeeks():Array<Bool>
	{
		var weeks:Array<Bool> = [];
		#if debug
		for(i in 0...weekNames.length)
			weeks.push(true);
		return weeks;
		#end
		
		weeks.push(true);

		for(i in 0...FlxG.save.data.weekUnlocked)
			{
				weeks.push(true);
			}
		return weeks;
	}

	override function create()
	{
		weekUnlocked = unlockWeeks();

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
			}
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);
		var kite:FlxSprite = new FlxSprite(0, -100);
		kite.frames = Paths.getSparrowAtlas('characters/kittte', 'shared');
		kite.animation.addByPrefix('idle', 'idle kite', 24);
		kite.setGraphicSize(Std.int(kite.width * 0.6));
		kite.screenCenter(X);
		if(Highscore.getWeekScore(curWeek, 2) < 1)
			kite.color = FlxColor.BLACK;
		kite.animation.play('idle');		

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		//add(blackBarThingie);

		var yeah = new FlxBackdrop(Paths.image('fondostory'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah.setPosition(0, 0);
		yeah.antialiasing = true;
		yeah.scrollFactor.set();
		add(yeah);
		yeah.velocity.set(0, 0);

		var yeah2 = new FlxBackdrop(Paths.image('cuadrakite'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah2.setPosition(0, 0);
		yeah2.antialiasing = true;
		yeah2.scrollFactor.set();
		add(yeah2);
		yeah2.velocity.set(40, 0);

		add(kite);
		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);
		trace("Line 70");

		for (i in 0...weekData().length)
		{
			var weekThing:MenuItem = new MenuItem(0, 56 + 400 + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = FlxG.save.data.antialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				trace('locking week ' + i);
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = FlxG.save.data.antialiasing;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");
#if android
addVirtualPad(FULL, A_B);
#end

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		//grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		//grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 30, grpWeekText.members[0].y + 80);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y - 50);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		//add(yellowBG);
		
		//add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFFFFFFF;
		txtTracklist.borderColor = FlxColor.BLACK; //doesn't work lmao
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();


		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
	{
		checkCodeInput();
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						changeWeek(-1);
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						changeWeek(1);
					}

					if (gamepad.pressed.DPAD_RIGHT)
						rightArrow.animation.play('press')
					else
						rightArrow.animation.play('idle');
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				if (FlxG.keys.justPressed.UP)
				{
					changeWeek(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				//grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData()[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;


			PlayState.storyDifficulty = curDifficulty;

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
			switch (songFormat) {
				case 'Dad-Battle': songFormat = 'Dadbattle';
				case 'Philly-Nice': songFormat = 'Philly';
			}

			var poop:String = Highscore.formatSong(songFormat, curDifficulty);
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.conversionChecks(Song.loadFromJson(poop, PlayState.storyPlaylist[0]));
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 2)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 2;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData().length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData().length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();

		for (i in 0...grpWeekText.members.length)
			{
				if(i > curWeek) {
					FlxTween.tween(grpWeekText.members[i], {alpha: 0}, 0.1, {ease: FlxEase.expoOut});
				}
				else if(i == curWeek) {
					FlxTween.tween(grpWeekText.members[i], {alpha: 1}, 0.1, {ease: FlxEase.expoOut});
				}
				else if(i < curWeek) {
					FlxTween.tween(grpWeekText.members[i], {alpha: 0}, 0.1, {ease: FlxEase.expoOut});
				}
			}
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		//grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		//grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData()[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	public static function unlockNextWeek(week:Int):Void
	{
		if(week <= weekData().length - 1 && FlxG.save.data.weekUnlocked == week)
		{
			weekUnlocked.push(true);
			trace('Week ' + week + ' beat (Week ' + (week + 1) + ' unlocked)');
		}

		FlxG.save.data.weekUnlocked = weekUnlocked.length - 1;
		FlxG.save.flush();
	}

	function checkCodeInput()
	{
		if (FlxG.keys.justPressed.ANY)
		{
			if (FlxG.keys.justPressed.A)
			{
				charInputs += 'A';
			}
			else if (FlxG.keys.justPressed.B)
			{
				charInputs += 'B';
			}
			else if (FlxG.keys.justPressed.C)
			{
				charInputs += 'C';
			}
			else if (FlxG.keys.justPressed.D)
			{
				charInputs += 'D';
			}
			else if (FlxG.keys.justPressed.E)
			{
				charInputs += 'E';
			}
			else if (FlxG.keys.justPressed.F)
			{
				charInputs += 'F';
			}
			else if (FlxG.keys.justPressed.G)
			{
				charInputs += 'G';
			}
			else if (FlxG.keys.justPressed.H)
			{
				charInputs += 'H';
			}
			else if (FlxG.keys.justPressed.I)
			{
				charInputs += 'I';
			}
			else if (FlxG.keys.justPressed.J)
			{
				charInputs += 'J';
			}
			else if (FlxG.keys.justPressed.K)
			{
				charInputs += 'K';
			}
			else if (FlxG.keys.justPressed.L)
			{
				charInputs += 'L';
			}
			else if (FlxG.keys.justPressed.M)
			{
				charInputs += 'M';
			}
			else if (FlxG.keys.justPressed.N)
			{
				charInputs += 'N';
			}
			else if (FlxG.keys.justPressed.O)
			{
				charInputs += 'O';
			}
			else if (FlxG.keys.justPressed.P)
			{
				charInputs += 'P';
			}
			else if (FlxG.keys.justPressed.Q)
			{
				charInputs += 'Q';
			}
			else if (FlxG.keys.justPressed.R)
			{
				charInputs += 'R';
			}
			else if (FlxG.keys.justPressed.S)
			{
				charInputs += 'S';
			}
			else if (FlxG.keys.justPressed.T)
			{
				charInputs += 'T';
			}
			else if (FlxG.keys.justPressed.U)
			{
				charInputs += 'U';
			}
			else if (FlxG.keys.justPressed.V)
			{
				charInputs += 'V';
			}
			else if (FlxG.keys.justPressed.W)
			{
				charInputs += 'W';
			}
			else if (FlxG.keys.justPressed.X)
			{
				charInputs += 'X';
			}
			else if (FlxG.keys.justPressed.Y)
			{
				charInputs += 'Y';
			}
			else if (FlxG.keys.justPressed.Z)
			{
				charInputs += 'Z';
			}
			else if (FlxG.keys.justPressed.ZERO)
			{
				charInputs += '0';
			}
			else if (FlxG.keys.justPressed.ONE)
			{
				charInputs += '1';
			}
			else if (FlxG.keys.justPressed.TWO)
			{
				charInputs += '2';
			}
			else if (FlxG.keys.justPressed.THREE)
			{
				charInputs += '3';
			}
			else if (FlxG.keys.justPressed.FOUR)
			{
				charInputs += '4';
			}
			else if (FlxG.keys.justPressed.FIVE)
			{
				charInputs += '5';
			}
			else if (FlxG.keys.justPressed.SIX)
			{
				charInputs += '6';
			}
			else if (FlxG.keys.justPressed.SEVEN)
			{
				charInputs += '7';
			}
			else if (FlxG.keys.justPressed.EIGHT)
			{
				charInputs += '8';
			}
			else if (FlxG.keys.justPressed.NINE)
			{
				charInputs += '9';
			}

			FlxG.watch.addQuick("charInputs", charInputs);

			// (Tech) Hacky way to check if current week is Saku while also handling old cheats
			//if (cheatCode1.startsWith(charInputs))
			if (charInputs == cheatCode1)
			{
				FlxG.switchState(new StoryMenuStateOLD());
			}		
			else
			{
				if (charInputs.length >= 6)
					//FlxG.sound.play(Paths.sound('RON', 'shared'));

				charInputs = '';
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		grpWeekCharacters.members[0].bopHead();
		//grpWeekCharacters.members[1].bopHead();
		//grpWeekCharacters.members[2].bopHead();
	}
}
