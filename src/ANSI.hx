package;

import haxe.macro.Expr;

using StringTools;

enum Attribute {
	Off;
	
	Bold;
	Underline;
	Blink;
	ReverseVideo;
	Concealed;
	
	BoldOff;
	UnderlineOff;
	BlinkOff;
	NormalVideo;
	ConcealedOff;
	
	Black;
	Red;
	Green;
	Yellow;
	Blue;
	Magenta;
	Cyan;
	White;
	DefaultForeground;
	
	BlackBack;
	RedBack;
	GreenBack;
	YellowBack;
	BlueBack;
	MagentaBack;
	CyanBack;
	WhiteBack;
	DefaultBackground;
}

typedef SequenceParam = {
	index:Int,
	name:String
}

typedef Sequence = {
	var val:String;
	var doc:String;
	@:optional var params:Array<SequenceParam>;
}

#if !macro
@:build(ANSI.build())
#end
class ANSI {
	
	public inline static var ESCAPE:String = "\x1B";
	public inline static var BELL:String = "\x07";
	
	public inline static var CSI:String = ESCAPE+"[";
	
	public static var sequences:Map<String, Sequence> = [
	
		"eraseDisplayToEnd"      => { val: CSI+ "J", doc: "Erase from cursor to the end of display." },
		"eraseDisplayToCursor"   => { val: CSI+"1J", doc: "Erase from the start of diplay to cursor (inclusive)." },
		"eraseDisplay"           => { val: CSI+"2J", doc: "Erase display and move cursor to the top-left." },
		
		"eraseLineToEnd"         => { val: CSI+ "K", doc: "Erase from cursor to the end of line." },
		"eraseLineToCursor"      => { val: CSI+"1K", doc: "Erase from the start of line to cursor (inclusive)." },
		"eraseLine"              => { val: CSI+"2K", doc: "Erase line." },
		
		"eraseChar"              => { val: CSI+ "X", doc: "Erase one character." },
		"eraseChars"             => { val: CSI+"#X", doc: "Erase # characters." },
		
		"insertLine"             => { val: CSI+ "L", doc: "Insert one blank line." },
		"insertLines"            => { val: CSI+"#L", doc: "Insert # blank lines." },
		
		"deleteLine"             => { val: CSI+ "M", doc: "Delete one line." },
		"deleteLines"            => { val: CSI+"#M", doc: "Delete # lines." },
		
		"deleteChar"             => { val: CSI+ "P", doc: "Delete one character." },
		"deleteChars"            => { val: CSI+"#P", doc: "Delete # characters." },
		
		"insertChar"             => { val: CSI+ "@", doc: "Insert one blank character." },
		"insertChars"            => { val: CSI+"#@", doc: "Insert # blank characters." },
		
		"moveUp"                 => { val: CSI+"#A", doc: "Move cursor up # lines." },
		"moveDown"               => { val: CSI+"#B", doc: "Move cursor down # lines." },
		"moveRight"              => { val: CSI+"#C", doc: "Move cursor right # characters." },
		"moveLeft"               => { val: CSI+"#D", doc: "Move cursor left # characters." },
		
		"moveDownReset"          => { val: CSI+"#E", doc: "Move cursor down # lines and to first column." },
		"moveUpReset"            => { val: CSI+"#F", doc: "Move cursor up # lines and to first column." },
		
		"setX"                   => { val: CSI+"#G", doc: "Move cursor to column #." },
		"setY"                   => { val: CSI+"#d", doc: "Move cursor to line #." },
		
		"reset"                  => { val: CSI+ "H", doc: "Move cursor to top-left." },
		"resetY"                 => { val: CSI+"#H", doc: "Move cursor to line # and first column." },
		
		"setXY"                  => { val: CSI+"#;#H", doc: "Move cursor to line #, column #.", params: [{ index: 1, name: "column" }, { index: 0, name: "line" }] },
		
		"saveCursor"             => { val: CSI+ "s", doc: "Save cursor position." },
		"loadCursor"             => { val: CSI+ "u", doc: "Move cursor to saved position." },
		
		"showCursor"             => { val: CSI+"?25h", doc: "Show cursor." },
		"hideCursor"             => { val: CSI+"?25l", doc: "Hide cursor." },
		
	];
	
	#if macro
	/**
	 * Builds fields out of the sequences above.
	 */
	macro public static function build():Array<Field> {
		var pos = haxe.macro.Context.currentPos();
		var fields = haxe.macro.Context.getBuildFields();
		
		var tint = TPath({ pack: [], name: "Int" });
		var tstr = TPath({ pack: [], name: "String" });
		
		for (seq in sequences.keys()) {
			var s = sequences[seq];
			var hasParams = s.val.indexOf("#") != -1;
			var doc = s.doc;
			
			var pieces = s.val.split("#");
			var args:Array<FunctionArg>;
			var expr:Expr;
			if (pieces.length == 1) {
				args = [];
				expr = macro return $v{pieces[0]};
			} else if (pieces.length == 2) {
				var arg = { name: "num", type: tint, opt: false, value: macro 1 };
				args = [arg];
				expr = macro return $v{pieces[0]} + $i{arg.name} + $v{pieces[1]};
			} else {
				if (s.params == null) throw "Sequence definition with multiple params missing required `params` field.";
				if (s.params.length < pieces.length-1) throw "Not enough params in sequence definition.";
				
				var pieceIndex = 0;
				args = [];
				expr = macro $v{pieces[pieceIndex++]};
				for (param in s.params) {
					var arg = { name: param.name, type: tint, opt: false, value: null };
					args.push(arg);
					expr = macro $expr + $i{s.params[param.index].name} + $v{pieces[pieceIndex++]};
				}
				
				expr = macro return $expr;
			};
			
			var index = doc.length;
			var arg = args.length-1;
			while ((index = doc.lastIndexOf("#", index-1)) != -1) {
				var argIndex = s.params == null ? arg : s.params[arg].index;
				doc = doc.substr(0, index) + "`" + args[argIndex].name + "`" + doc.substr(index+1);
				arg--;
				if (arg < 0) break;
			}
			
			var kind = FFun({ args: args, ret: tstr, expr: expr }); //FVar(tstr, macro $v{s.val});
			
			var names = seq.split("|");
			for (name in names) {
				fields.push({
					name: name,
					doc:
						'${doc}\n' +
						(names.length == 1 ? "" : "Aliases: "+[for (n in names) if (name != n) n].join(", ")) +
						'ANSI sequence: ${s.val}',
					access: [APublic, AStatic, AInline],
					kind: kind,
					pos: pos
				});
			}
		}
		
		return fields;
	}
	#end
	
	private static var values:Map<Attribute, Int> = [
		Off               => 0,
		
		Bold              => 1,
		Underline         => 4,
		Blink             => 5,
		ReverseVideo      => 7,
		Concealed         => 8,
		
		BoldOff           => 22,
		UnderlineOff      => 24,
		BlinkOff          => 25,
		NormalVideo       => 27,
		ConcealedOff      => 28,
		
		Black             => 30,
		Red               => 31,
		Green             => 32,
		Yellow            => 33,
		Blue              => 34,
		Magenta           => 35,
		Cyan              => 36,
		White             => 37,
		DefaultForeground => 39,
		
		BlackBack         => 40,
		RedBack           => 41,
		GreenBack         => 42,
		YellowBack        => 43,
		BlueBack          => 44,
		MagentaBack       => 45,
		CyanBack          => 46,
		WhiteBack         => 47,
		DefaultBackground => 49
		
	];
	
	public static var attr = Attribute;
	
	public static function __init__() {
		set = Reflect.makeVarArgs(aset);
	}

	public static var set:Dynamic;
	public static function aset(attributes:Array<Dynamic>):String {
		return CSI+[for (arg in attributes) {
			if (!Std.is(arg, Attribute)) throw "Set argument is not an Attribute: "+arg;
			values.get(arg);
		}].join(";")+"m";
	}

	public inline static function title(str:String):String {
		return ESCAPE+"]0;" + str + BELL;
	}
	
	/*
	public static function replaceLine():String {
		return eraseLine()+moveToColumn();
	}
	
	public static function replaceLastLine():String {
		return moveUp()+eraseLine()+moveToColumn();
	}
	*/
	
}