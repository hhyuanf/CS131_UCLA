class SynchronizedState implements State {
    private int[] value;
    SynchronizedState(int[] v) { value = v;}

    public int size() { return value.length; }

    public int[] current() { return value; }


    public synchronized boolean swap(int i, int j) {
	if (value[i] <= 0) {
	    return false;
	}
	//value[i]--;
	value[i]++;
	value[j]++;
	return true;
    }
}
