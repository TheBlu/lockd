module engine;

class ConnectedValue(T)
{
	class SetSignal
	{
		import std.signals;
		mixin Signal!(T);
	}
	
	this()
	{
		setSignal = new SetSignal;
	}
	
	void set(T rhs)
	{
		_value = rhs;
		emitSet();
	}
	
	void connect(ref ConnectedValue other)
	{
		setSignal.connect(&other.set);
	}
	
	void emitSet()
	{
		setSignal.emit(_value);
	}
	
	override string toString()
	{
		import std.conv : to;
		return to!string(_value);
	}
	
	@property {
		auto value() {
			return _value;
		}
		auto value(T rhs) {
			set(rhs);
			return value;
		}
	}
	void opAssign(T rhs)
	{
		value = rhs;
	}
	
	SetSignal setSignal;
	private:
		T _value;
}


class AccumulatedValue(T) : ConnectedValue!T
{
	ConnectedValue!(T)[] _terms;
	
	this(ConnectedValue!(T)[] terms ...)
	{
		_terms = terms;
		super();
		init();
	}
	
	void init()
	{
		foreach (term; _terms)
		{
			term.setSignal.connect(&update);
		}
		update(0);
	}
	
	void update(T val)
	{
		import std.stdio : writeln;
		T sum = 0;
		foreach (term; _terms)
		{
			sum += term.value;
		}
		value = sum;
	}
}
