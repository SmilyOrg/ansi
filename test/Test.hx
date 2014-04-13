import ANSI;

class Particle {
	public var x:Float;
	public var y:Float;
	public var vx:Float;
	public var vy:Float;
	public var attr:Array<ANSI.Attribute>;
	public function new() {}
}

class Test {
	
	static private inline function println(s:String) {
		#if sys
		Sys.stdout().writeString(s+"\n");
		#else
		trace(s);
		#end
	}
	
	static function main() {
		
		println(ANSI.title("ANSI Test (this should be the window title)"));
		
		println("Char >x< erased"+ANSI.setX(7)+ANSI.eraseChar());
		println("Char >x< deleted"+ANSI.setX(7)+ANSI.deleteChar());
		
		#if sys
		testParticles();
		#end
		
	}
	
	#if sys
	static private function testParticles() {
		var out = Sys.stdout();
		var pixelAspectRatio = 8/14;
		var w = 80;
		var h = Std.int(25/pixelAspectRatio);
		var cx = w/2;
		var cy = h/2;
		var particles = [];
		var colors = [Black, Red, Green, Yellow, Blue, Magenta, Cyan, White];
		for (i in 0...50) {
			var p = new Particle();
			p.x = Std.random(w);
			p.y = Std.random(h);
			p.vx = (Math.random()-0.5)*10;
			p.vy = (Math.random()-0.5)*10;
			p.attr = [Std.random(2) == 0 ? BoldOff : Bold, colors[Std.random(colors.length)]];
			particles.push(p);
		}
		var drag:Float = 0.99;
		var angular:Float = 0.3;
		var wander:Float = 1;
		var dt:Float = 1/60;
		var time:Float = 0;
		while (true) {
			for (p in particles) {
				var dx:Float;
				var dy:Float;
				var dl:Float;
				
				dx = cx-p.x;
				dy = cy-p.y;
				dl = Math.sqrt(dx*dx+dy*dy);
				dx /= dl; dy /= dl;
				
				p.vx += dx+dy*angular;
				p.vy += dy-dx*angular;
				
				dx = Math.random()-0.5;
				dy = Math.random()-0.5;
				dl = Math.sqrt(dx*dx+dy*dy);
				dx /= dl; dy /= dl;
				
				p.vx += dx*wander;
				p.vy += dy*wander;
				
				p.vx *= drag;
				p.vy *= drag;
				p.x += p.vx*dt;
				p.y += p.vy*dt;
			}
			var cmd = "";
			cmd += ANSI.eraseDisplay();
			cmd += ANSI.set(Off, Green, Bold);
			cmd += ANSI.set(Std.int(time/0.25) & 1 == 0 ? ReverseVideo : NormalVideo);
			var header = "!ANSI PARTICLES!";
			cmd += ANSI.moveRight(Math.round(cx-header.length/2+Math.sin(time*2)*(w-header.length)/2));
			cmd += header;
			cmd += ANSI.set(Off);
			for (p in particles) {
				if (p.x < 0 || p.x > w-1 || p.y < 0 || p.y > h-1) continue;
				cmd += ANSI.setXY(Std.int(p.x), Std.int(p.y*pixelAspectRatio));
				cmd += ANSI.aset(p.attr);
				cmd += "o";
			}
			out.writeString(cmd);
			time += dt;
			Sys.sleep(dt);
		}
	}
	#end
	
}