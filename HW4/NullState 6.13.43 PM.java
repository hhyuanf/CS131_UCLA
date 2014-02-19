// This is a dummy implementation, useful for
// deducing the overhead of the testing framework.
class NullState implements State {
    private int[] value;
    NullState(int[] v) { value = v; }
    public int size() { return value.length; }
    public int[] current() { return value; }
    public boolean swap(int i, int j) { return true; }
    public int fault() {return 0;}
}
