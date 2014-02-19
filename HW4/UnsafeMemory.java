class UnsafeMemory {
    public static void main(String args[]) {
	if (args.length < 3)
	    usage(null);
	try {
	    int nThreads = parseInt (args[1], 1);
	    int nTransitions = parseInt (args[2], 0);
	    int[] value = new int[args.length - 3];
	    for (int i = 3; i < args.length; i++)
		value[i - 3] = parseInt (args[i], 0);
	    int[] stateArg = value.clone();
	    State s;
	    if (args[0].equals("Null"))
            s = new NullState(stateArg);
	    else if (args[0].equals("Synchronized"))
            s = new SynchronizedState(stateArg);
        else if (args[0].equals("UnSynchronized"))
            s = new UnSynchronizedState(stateArg);
        else if (args[0].equals("GetNSet"))
            s = new GetNSetState(stateArg);
        else if (args[0].equals("BetterSorry"))
        	s = new BetterSorryState(stateArg);
        else if (args[0].equals("BetterSafe"))
        	s = new BetterSafeState(stateArg);
	    else
            throw new Exception(args[0]);
	    dowork(nThreads, nTransitions, s);
	    test(value, s.current());
	    System.exit (0);
	} catch (Exception e) {
	    usage(e);
	}
    }

    private static void usage(Exception e) {
	if (e != null)
	    System.err.println(e);
	System.err.println("Usage: model nthreads ntransitions n0 n1 ...\n");
	System.exit (1);
    }

    private static int parseInt(String s, int min) {
	int n = Integer.parseInt(s);
	if (n < min)
	    throw new NumberFormatException(s);
	return n;
    }

    private static void dowork(int nThreads, int nTransitions, State s)
      throws InterruptedException {
	Thread[] t = new Thread[nThreads];
	for (int i = 0; i < nThreads; i++) {
	    int threadTransitions =
		(nTransitions / nThreads
		 + (i < nTransitions % nThreads ? 1 : 0));
	    t[i] = new Thread (new SwapTest (threadTransitions, s));
	}
	long start = System.nanoTime();
	for (int i = 0; i < nThreads; i++)
	    t[i].start ();
	for (int i = 0; i < nThreads; i++)
	    t[i].join ();
	long end = System.nanoTime();
	double elapsed_ns = end - start;
	System.out.format("Threads average %g ns/transition\n",
			  elapsed_ns * nThreads / nTransitions);
    }

    private static void test(int[] input, int[] output) {
	if (input.length != output.length)
	    error("length mismatch", input.length, output.length);
	int isum = 0;
	int osum = 0;
	for (int i = 0; i < input.length; i++)
	    {
            isum += input[i];
            osum += output[i];
            if (output[i] < 0)
                error("negative output", output[i], 0);
	    }
	if (isum != osum)
	    error("sum mismatch", isum, osum);
    }

    private static void error(String s, int i, int j) {
	System.err.format("%s (%d != %d)\n", s, i, j);
	System.exit(1);
    }
}
