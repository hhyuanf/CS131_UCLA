class UnSynchronizedState implements State {
    private int[] value;
    private int lastSum;
    private int faultNum;
    UnSynchronizedState(int[] v) { value = v;
    for (int i = 0; i < value.length; i++)
    		lastSum += value[i];
    		 }

    public int size() { return value.length; }

    public int[] current() { return value; }

    public int fault(){
    	return faultNum;
    }

    public boolean swap(int i, int j) {
	if (value[i] <= 0) {
	    return false;
	}
	value[i]--;
	value[j]++;
	check(lastSum);
	return true;
    }

    public synchronized void check(int lastSum) {
    	int sum=0;
    	for (int i = 0; i < value.length; i++)
    		sum += value[i];
    	if (sum != lastSum) {
    		faultNum++;
    		lastSum = sum;
    	}
    }
}
