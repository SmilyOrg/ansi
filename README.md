ansi
====

Haxe utility for working with ANSI escape sequences.

Provides functions that return a String with the appropriate ANSI escape sequence. This is usually written to standard output for the hosting console to process.

**Note**: If the console doesn't support the escape sequences (e.g. default Command Prompt on Windows), you're going to see garbage.

Tested with the neko target and [ansicon](https://github.com/adoxa/ansicon).


## Examples


### Text Color

```haxe
Sys.stdout().writeString(ANSI.set(ANSI.attr.Green) + "green text");
```
or shortened by importing ANSI and with it the Attribute enum:
```haxe
import ANSI;
...
Sys.stdout().writeString(ANSI.set(Green) + "green text");
```
![example](http://i.imgur.com/6Xkg8ej.png)
<hr/>


```haxe
Sys.stdout().writeString(
	ANSI.set(Green, Bold) + "vivid green text" +
	ANSI.set(DefaultForeground) + " normal text"
);
```
![example](http://i.imgur.com/W7VKnGd.png)
<hr/>


### Move and Delete

```haxe
Sys.stdout().writeString("hello world" + ANSI.moveLeft(5) + ANSI.deleteChars(5) + "ansi");
```
![example](http://i.imgur.com/aChcwwA.png)
<hr/>


### Window Title

```haxe
Sys.stdout().writeString(ANSI.title("Window title goes here"));
```
![example](http://i.imgur.com/1Cs7Tu7.png)
<hr/>


### Particles!

See [Test.hx](test/Test.hx).

![particles gif](http://i.imgur.com/6taTuWO.gif)
