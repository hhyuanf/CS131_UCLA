import java.util.concurrent.ThreadLocalRandom;

class SwapTest implements Runnable {
    private int nTransitions;
    private State state;

    SwapTest(int n, State s) {
	nTransitions = n;
	state = s;
    }

    public void run() {
	int n = state.size();
	if (n != 0)
	    for (int i = 0; i < nTransitions; ) {
		int a = ThreadLocalRandom.current().nextInt(n);
		int b = ThreadLocalRandom.current().nextInt(n - 1);
		if (a == b)
		    b = n - 1;
		if (state.swap(a, b))
		    i++;
	    }
    }
}
