import java.util.concurrent.locks.ReentrantLock;


class BetterSafeState implements State {
    private int[] value;
    private final ReentrantLock lock = new ReentrantLock();
    
    BetterSafeState(int[] v) {value = v;}
    
    public int size() { return value.length; }
    
    public int[] current() {return value;}
    
    public boolean swap(int i, int j) {
        if (value[i] <= 0) {
            return false;
        }
        lock.lock();
        try {
            //value[i]--;
            value[i]--;
            value[j]++;
        }
        finally{
            lock.unlock();
        }
        return true;
    }
}
