import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    AtomicIntegerArray value;
    GetNSetState(int[] v) { value = new AtomicIntegerArray(v);}
    
    public int size() { return value.length(); }
    
    public int[] current() {
        int[] v_array = new int[value.length()];
        for (int i = 0; i < value.length(); i++) {
            v_array[i] = value.get(i);
        }
        return v_array;
    }

    public boolean swap(int i, int j) {
        if (value.get(i) <= 0) {
            return false;
        }
        if (i > j) {
            int v1 = value.get(j);
            value.set(j, ++v1);
            int v2 = value.get(i);
            //value.set(i, --v2);
            value.set(i, ++v2);
        }
        else {
            int v1 = value.get(i);
            //value.set(i, --v1);
            value.set(i, ++v1);
            int v2 = value.get(j);
            value.set(j, ++v2);
        }
        return true;
    }
}
