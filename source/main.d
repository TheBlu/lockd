import dlangui.platforms.common.platform;
import dlangui.widgets.controls,
       dlangui.widgets.layouts;

mixin APP_ENTRY_POINT;
class Lever(T) : VerticalLayout
{
	import engine;
	
	T[] _values;
	RadioButton[] _options;
	ConnectedValue!T value;
	
	this(T[] values)
	{
		_values = values;
		value = new ConnectedValue!T;
		initOptions();
		super();
	}
	
	@property
	{
		auto values()
		{
			return _values;
		}
	}
	
	private:
		void initOptions()
		{
			import dlangui.widgets.controls : RadioButton;
			import std.conv : to;
			foreach(idx, v; _values)
			{
				auto rb = new RadioButton;
				rb.id = to!string(idx);
				rb.onCheckChangeListener = &checkChangeListener;
				this.addChild(rb);
			}
		}
		
		bool checkChangeListener(Widget widget, bool checked)
		{
			import std.conv : to;
			if (checked)
			{
				value = _values[to!T(widget.id)];
			}
			return false;
		}
}

class ValueDisplay(T) : TextWidget
{
	import engine;
	ConnectedValue!T value;
	this()
	{
		value = new ConnectedValue!T;
		value.s.connect(&set);
		super();
	}
	
	void set(int val)
	{
		import std.conv : to;
		text = to!dstring(val);
	}
}

class CheckboxArray(T) : HorizontalLayout
{
	import dlangui.widgets.controls : CheckBox;
	import engine;
	ConnectedValue!T value;
	bool[] _start;
	
	this(bool[] start = [false])
	{
		value = new ConnectedValue!T;
		value.setSignal.connect(&set);
		_start = start;
		init();
	}
	
	void init()
	{
		foreach (state; _start)
		{
			auto cb = new CheckBox;
			cb.checked = state;
			cb.enabled = false;
			addChild(cb);
		}
	}
	
	void set(T val)
	{
		import std.stdio : writeln;
		writeln(val);
		foreach (idx; 0..childCount)
		{
			auto cb = child(idx);
			switch (idx)
			{
				case 0:
					cb.checked = (val % 4) == 0 ? true : false;
					break;
				case 1:
					cb.checked = (val % 2) == 0 ? true : false;
					break;
				case 2:
					cb.checked = (val % 3) == 0 ? true : false;
					break;
				default:
					break;
			}
		}
	}
}
extern (C) int UIAppMain(string[] args) {
	import std.conv;
	import std.stdio : writeln;
	
	import dlangui.widgets.controls,
		   dlangui.widgets.layouts,
		   dlangui.widgets.editors,
		   dlangui.core.types,
		   dlangui.core.signals,
		   dlangui.core.logger;
	
	import engine;
	
	dstring title = "DlangUIDemo"d;
	uint width = 800;
	uint height = 600;
	Window window = Platform.instance.createWindow(title, null, WindowFlag.Resizable, width, height);
	
	auto text = new TextWidget;
	text.text = "Welcome to the program.";
	
	auto lv = new Lever!int([1, 3, 6]);
	
	auto lv2 = new Lever!int([14, 20, 21]);
	
	auto lv3 = new Lever!int([23, 3, 2]);
	
	auto lv4 = new Lever!int([8, 12, 31]);
	
	auto lv5 = new Lever!int([24, 9, 15]);
	
	auto hl = new HorizontalLayout;
	hl.layoutHeight = WRAP_CONTENT;
	hl.layoutWidth = FILL_PARENT;
	hl.addChild(lv);
	hl.addChild(lv2);
	hl.addChild(lv3);
	hl.addChild(lv4);
	hl.addChild(lv5);
	
	auto arr = new CheckboxArray!int([0, 0, 0]);
	
	auto acc = new AccumulatedValue!int([lv.value, lv2.value, lv3.value, lv4.value, lv5.value]);
	acc.connect(arr.value);
	
	auto vl = new VerticalLayout;
	vl.addChild(text);
	vl.addChild(hl);
	vl.addChild(arr);
	//vl.addChild(vd);
	
	window.mainWidget = vl;
	
	window.show();
	/*
	entry.keyEvent = delegate(Widget w, KeyEvent event) {
		text2.text = w.text;
		return false;
	};
	*/
	
	return Platform.instance.enterMessageLoop();
}