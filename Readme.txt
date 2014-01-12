mkbeat.pl is a Perl script to take a beat description file
and generate a corresponding beat meter using ASS subtitles.

Summary of Usage
================

1. Generate rudimentary .ass file for the video
2. Copy/rename this file to VIDEONAME.header
3. Write beat description file, name it VIDEONAME.txt
4. Run "perl mkbeat.pl VIDEONAME.txt"

Details
=======

1. Generate rudimentary ASS file for the video

For this you can just open the video in Aegisub for instance.
Any subtitles you add here will remain in the generated .ass
file, so if you want to add actual subtitles in addition to
the beat bar, it is better to do it here than in the generated
file.

You can also add styles for different beat duration. The beat
bar will use style "beat1" for full beats (quarter notes), "beat2"
for double beats (eighth notes), "beat4" for quad beats (sixteenth
notes) etc.

2. Copy/rename this file to VIDEONAME.header

The header file will be used as stub for the generated .ass file,
with the beat bar subtitles added directly at the end. You can also
open the header file in Aegisub and add more subtitles, and run
mkbeat to generate the combined subtitles/beat bar .ass file.

On Windows, make sure file extensions are not hidden for this
renaming to be successful.

3. Write beat description file, name it VIDEONAME.txt

See below for details.

4. Run "perl mkbeat.pl VIDEONAME.txt"

This takes the beat description from the .txt file, and adds the
beat bar subtitles to the .header file described above.

NOTE!  If any VIDEONAME.ass file exists, it will be OVERWRITTEN with
no further questions.

Beat Description File
====================

The beat description file is a plain text file. It contains two sections,
first the configuration and then the beat data.

The configuration is used to set up the tempo, and location of the beat bar.

1. Tempo

The first beat is defined by the "FIRST" setting in seconds, e.g.
	FIRST=0.12
sets the first beat 0.12 seconds into the video.

To define the tempo, you can either set "BPM" to define the beats
per minute directly, or count full beats until a given point in the
video and set it with "MID" (time in seconds) and "MIDNUM" (number of
full beats until then).

For tempo changes, enter "BREAK" on a line of its own. After this, set up
the first beat and tempo as above.

2. Beat bar

The beat bar is defined by the "SOURCE" location (in ASS coordinates),
where the beat markers start appearing, the "TARGET" location, where the
target marker is placed, and optionally the "FINISH" location, where the
beat markers disappear. For instance, "SOURCE" could be the top right corner,
"TARGET" could be the right side center, and "FINISH" the bottom right corner.

Additionally, you can specify how fast the beat markers move with the
"TIMETARGET" setting, which says how many seconds pass between appearing
and moving into the target marker. If the beat bar doesn't end at the
target marker (i.e. you have a "FINISH" coordinate above), you also need
to set the "TIMEFINISH" time appropriately.

3. Markers

The "MARK" setting defines the default character(s) used for the beat markers.
Note that any particular beat can have a custom marker too. The "TARGETMARK"
setting does the same for the target marker.

4. Beat Data

The beats are specified in the form "NUMBER@SPEED", where number is the number
of beats, and speed is how fast the beat goes. A SPEED of 1 is a full beat
(i.e. quarter note), SPEED 2 is a double beat (eighth note), etc. The SPEED
may be an arbitrary fraction as well.

Optionally, after the SPEED may follow a space and any character or text you
wish to use for this NUMBER of beats.

To enter a repeating pattern, enter several SPEED values separated by commas,
e.g. "8@1,1,1,2,2,1,1,1,4,4,4,4" defines a sequences of 3 full beats, 2 half
beats, again 3 full beats and 4 quarter beat repeated 8 times. You may also
follow this with markers to use for each beat. If not all characters are
specified, the default mark will be used. For instance, "4@1,1,1,2,2 X,-,-,O,O"
will display an "X" for the first beat of the sequence, two dashes for the next
two beats and finally two "O" for the last two beats, all repeated four times.

Fractional beats can be entered either as fractional numbers (e.g. "0.5") or
with the notation "4/3". Because mkbeat specifies the beat rate and not beat
duration (i.e. a 2 means a half-beat, and 0.5 is a duration of two full beats),
this may be somewhat unintuitive. For instance, "4/3" is a beat duration
equivalent to 3 quarter beats, equivalent to a dotted eighth note in musical
notation.

While timing the beats it is helpful to use a sequence of letters for each
beat entry, so you can quickly see which line a particular beat subtitle
came from in the beat description file. Furthermore, the special code "\R"
uses the beat number for each beat, this is useful to avoid having to count
beat by putting e.g. "999@1 \R" as last line after all beats timed so far.

