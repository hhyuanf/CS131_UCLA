class BetterSorryState implements State {
    private static volatile int[] value;
    BetterSorryState(int[] v) { value = v;}

    public int size() { return value.length; }

    public int[] current() { return value; }

    public boolean swap(int i, int j) {
	if (value[i] <= 0) {
	    return false;
	}
	if (i > j){
		value[j]++;
	//value[i]--;
		value[i]--;
	}
	else{
			//value[i]--;
		value[i]--;
		value[j]++;
	}
	return true;
    }
}
