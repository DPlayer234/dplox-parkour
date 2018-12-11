Add custom player files here. Begin filenames of files which are not players with '#'.
Format:
	tag1
	value1
	tag2
	value2
	...
Tags and corresponding values (case-sensitive, brackets mean fully optional):
	name: The name of the character, string (e.g. Super Long Character Name Plus)
	[shortname]: Self-explanatory, string (e.g. Name Plus; default: name)
	[gender]: Either 'male', 'female', 'neutral' or 'none' (default: 'none')
	texture: Either the path to the image for the character from the parent directory of '/player' or base64-encoded data of the image, string (e.g. player/example.png)
	[jumpsound]: Path to a sound file or base64-encoded data which should be used when jumping (same criteria as texture), string (default: default-jump-sound)
	[jumpsoundvolume]: Volume of the jump sound from 0.00-1.00, ignored if 'jumpsound' does not exist, number (default: 0.60)
	[attacksound]: Same as jumpsound but for the attack, string (default: swing-sound)
	[attacksoundvolume]: Volume of the attack sound from 0.00-1.00, ignored if 'attacksound' does not exist, number (default: 0.40)
	tilewidth: Defines the width of each individual frame in the character texture in pixels, number
	tileheight: Same for height, number
	[scale]: Multiplier for the scale of the character, number (default: 1)
	[color]: A list of three values in the range of 0-255 divided by comma or a single value in the same range defining the RBG-value of the attack animation (default: 255,255,255)
	[customtiles]: Defines custom animation frames whose size may differ from tilewidth and tileheight, a list in the format of '{id1,id2,x,y,w,h}, ...' where 'x' and 'y' define the top-left corner of the frame and 'w' and 'h' define the width and height of it, the 'id1' and 'id2' values are what you would enter in the animation definition as X and Y coordinates (e.g. {18,1,187,0,22,19})
	[values]: MUST be at the end of the file. The only allowed values for custom players here is the name of another default player-file (only the name, not 'player/' or '.char'); the character will behave the same way the specified character would, string (uses default values if unspecified or invalid)
Additional values for the character animations:
	idle, walk, jump, jumpf, jumpb, jumpu, djump, wall, wallrun, duck, slide, die, gdie, attack
	(jumpf: Forward jumping, jumpb: Backwards jumping, jumpu: Jumping up, gdie: Death on ground)
	Only idle, walk, jump, wall, wallrun and die are required.
	Format:
		{f1,x1,y1}, {f2,x2,y2}, ...
		f: Point in time (in 1/60th of a second; 'frames') after the start of the animation at which that frame is activated, natural number
		x, y: X and Y coordinate of the frame
		Instead of x and y, you may also enter '"loop"' which is going to reset the animation or also just one number to go to that frame. '"end"' is also valid but is only active on certain animations (e.g. djump, attack) which can be canceled manually. Each is only valid once per animation.

Notes:
	The 'values' tag may cause unexpected results if the specified character bases its actions based on animation frames and your animation lengths don't match. (e.g. z-glassth)
	The character will always be centered based on 'tilewidth' and 'tileheight'.
	Sounds should always be '.ogg' or another SINGLE channel sound-format.
