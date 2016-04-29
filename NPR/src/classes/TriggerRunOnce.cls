public class TriggerRunOnce 
{
    private static boolean ran = false;

    // has this Id been processed? 
    public static boolean isAlreadyDone() 
    {
        return ran;
    }

    // set that this Id has been processed.
    public static void setAlreadyDone()
    {
        ran=true;
    }

    // empty set if we need to for some reason. 
    public static void resetAlreadyDone() 
    {
        ran=false;
    }
}