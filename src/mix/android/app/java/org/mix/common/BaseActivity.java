package org.mix.common;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.Window;
import android.view.WindowManager;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class BaseActivity extends android.app.Activity {

    public static String TAG = "MIX";
    public static void log(String s) {
        Log.i(TAG, s);
    }
    public static void killThisProcess() {
        // wait for a while before killing
        try { Thread.sleep(200); } catch (InterruptedException e) {}
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    public enum NativeState
    {
        None,
        Starting,
        Running,
        Paused,
        Stopping,
        Stopped,
    }

    public enum NativeFrontendEvent
    {
        Resized,
        Closed,
        TouchDown,
        TouchMove,
        TouchUp,
        TouchCancel,
        SwipeLeft,
        SwipeRight,
        SwipeUp,
        SwipeDown,
    }

    public enum NativeApplicationEvent
    {
        Terminating,
        LowMemory,
        WillEnterBackground,
        DidEnterBackground,
        WillEnterForeground,
        DidEnterForeground,
    }

    public static class NativeCode
    {
        private NativeState m_nativeState = NativeState.None;

        public static native void handleInit(String apkLocation);
        public static native void handleUpdate();
        public static native void handleQuit();
        public static native void handleFrontendEvent(int evt, int touchid, float param0, float param1);
        public static native void handleApplicationEvent(int evt);

        @Override
        public String toString() {
            return m_nativeState.toString();
        }

        public void waitForStopped() {
            boolean stopped = false;
            while (!stopped) {
                synchronized(this){
                    stopped = (m_nativeState == NativeState.Stopped);
                }
                try { Thread.sleep(0, 1); } catch (InterruptedException e) {}
            }
        }

        public synchronized void start() {
            m_nativeState = NativeState.Starting;
        }

        public synchronized void stop() {

            NativeCode.handleApplicationEvent(NativeApplicationEvent.Terminating.ordinal());
            m_nativeState = NativeState.Stopping;
        }

        public synchronized void pause() {
            log ("nativePause");

            if (m_nativeState != NativeState.Running)
                return;

            NativeCode.handleApplicationEvent(NativeApplicationEvent.WillEnterBackground.ordinal());
            m_nativeState = NativeState.Paused;
        }

        public synchronized void resume() {
            log ("nativeResume");

            if (m_nativeState != NativeState.Paused)
                return;

            NativeCode.handleApplicationEvent (NativeApplicationEvent.WillEnterForeground.ordinal());
            m_nativeState = NativeState.Running;
        }

        public synchronized void doFrame(Context context) {
            if (NativeState.Starting == m_nativeState) {
                handleInit(context.getApplicationInfo().sourceDir);
                m_nativeState = NativeState.Running;
            }
            else if (NativeState.Running == m_nativeState) {
                handleUpdate();
            }
            else if (NativeState.Stopping == m_nativeState) {
                handleQuit();
                m_nativeState = NativeState.Stopped;
            }
        }
    }

    public class BaseView extends GLSurfaceView implements GLSurfaceView.Renderer {

        public NativeCode nativeCode;

        private GestureDetector gestureDetector;

        public BaseView(Context ctx) {
            super(ctx);
            log("BaseView()");
            setEGLContextClientVersion(2);
            setRenderer(this);
            setRenderMode(RENDERMODE_CONTINUOUSLY);

            nativeCode = new NativeCode();
            nativeCode.start();

            gestureDetector = new GestureDetector(ctx, new GestureDetector.SimpleOnGestureListener() {
                public boolean onFling(MotionEvent e1, MotionEvent e2, float velo_x, float velo_y) {
                    float attr_x = Math.abs(velo_x);
                    float attr_y = Math.abs(velo_y);

                    if (attr_x > attr_y)
                    {
                        NativeFrontendEvent evt_type = (velo_x > 0 ? NativeFrontendEvent.SwipeRight : NativeFrontendEvent.SwipeLeft);
                        NativeCode.handleFrontendEvent(evt_type.ordinal(), 0, velo_x, velo_y);
                    }
                    else
                    {
                        NativeFrontendEvent evt_type = (velo_y > 0 ? NativeFrontendEvent.SwipeDown : NativeFrontendEvent.SwipeUp);
                        NativeCode.handleFrontendEvent(evt_type.ordinal(), 0, velo_x, velo_y);
                    }
                    return true;
                }
            });
        }

        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
            log("surfaceCreated() " + nativeCode.toString());
        }

        public void onSurfaceChanged(GL10 gl, int width, int height) {
            log("surfaceChanged(" + String.valueOf(width) + "," + String.valueOf(height) +")");
            NativeCode.handleFrontendEvent(NativeFrontendEvent.Resized.ordinal(), 0, (float) width, (float) height);
        }

        public void onDrawFrame(GL10 gl) {
            nativeCode.doFrame(getContext());
        }

        @Override
        public boolean onTouchEvent (MotionEvent evt) {

            gestureDetector.onTouchEvent(evt);
            // https://developer.android.com/training/gestures/multi.html
            // http://www.vogella.com/tutorials/AndroidTouch/article.html
            int actionType = evt.getActionMasked();
            int actionIndex = evt.getActionIndex();

            if (MotionEvent.ACTION_DOWN==actionType||MotionEvent.ACTION_POINTER_DOWN==actionType) {
                int touchId = evt.getPointerId(actionIndex);
                NativeCode.handleFrontendEvent(NativeFrontendEvent.TouchDown.ordinal(), touchId, evt.getX(actionIndex), evt.getY(actionIndex));
            }
            if (MotionEvent.ACTION_UP==actionType||MotionEvent.ACTION_POINTER_UP==actionType) {
                int touchId = evt.getPointerId(actionIndex);
                NativeCode.handleFrontendEvent(NativeFrontendEvent.TouchUp.ordinal(), touchId, evt.getX(actionIndex), evt.getY(actionIndex));
            }

            if (MotionEvent.ACTION_MOVE==actionType) {
                for (int i = 0; i < evt.getPointerCount(); ++i) {
                    int touchId = evt.getPointerId(i);
                    NativeCode.handleFrontendEvent(NativeFrontendEvent.TouchMove.ordinal(), touchId, evt.getX(i), evt.getY(i));
                }
            }

            if (MotionEvent.ACTION_CANCEL==actionType) {
                for (int i = 0; i < evt.getPointerCount(); ++i) {
                    int touchId = evt.getPointerId(i);
                    NativeCode.handleFrontendEvent(NativeFrontendEvent.TouchCancel.ordinal(), touchId, evt.getX(i), evt.getY(i));
                }
            }
            /*
            StringBuilder sb = new StringBuilder();

            sb.append("index=").append(evt.getActionIndex());
            sb.append(";action=").append(MotionEvent.actionToString(evt.getAction()));

            for (int i = 0; i < evt.getPointerCount(); ++i) {
                int name = evt.getPointerId(i);
                sb.append(";name=").append(name);
            }

            log (sb.toString());
            */
            return true;
        }
    }

    protected BaseView m_view;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        workarounds(); // various workarounds for the Android platform x_x

        log("Android runtime = " + getCurrentRuntime());
        log("APK path = " + getApplicationInfo().sourceDir);

        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        loadNativeLibraries();

        setContentView(m_view = onCreateContentView());
    }

    @Override
    protected void onDestroy() {
        log("onDestroy()");
        super.onDestroy();
        killThisProcess(); // cleanup any static objects in loaded dll
    }

    @Override
    protected void onPause() {

        if (isFinishing()) {
            // invoke stop here, so that the shutdown code can be executed in the renderer's thread
            m_view.nativeCode.stop();
            m_view.nativeCode.waitForStopped();
        }
        else {
            m_view.nativeCode.pause();
        }
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        m_view.nativeCode.resume();
    }

    @Override
    public void onTrimMemory (int level) {
        NativeCode.handleApplicationEvent(NativeApplicationEvent.LowMemory.ordinal());
    }
	
	protected BaseView onCreateContentView() {
		return new BaseView(this);
	}

    protected String[] getLibraries() {
        return new String[] {
            "gnustl_shared",
            //"main"
        };
    }

    protected void workarounds() {

        // fix NoClassDefFoundError android.os.AsyncTask for google play service
        // http://stackoverflow.com/questions/6968744/getting-noclassdeffounderror-android-os-asynctask
        try {
            Class.forName("android.os.AsyncTask");
        }
        catch(Throwable ignore) {
            // ignored
        }
    }

    private String getCurrentRuntime() {
        final String SELECT_RUNTIME_PROPERTY = "persist.sys.dalvik.vm.lib";

        try {
            Class<?> systemProperties = Class.forName("android.os.SystemProperties");
            try {
                Method get = systemProperties.getMethod("get",
                        String.class, String.class);
                if (get == null) {
                    return "WTF?!";
                }
                try {
                    return (String)get.invoke(systemProperties, SELECT_RUNTIME_PROPERTY, "Dalvik");
                } catch (IllegalAccessException e) {
                    return "IllegalAccessException";
                } catch (IllegalArgumentException e) {
                    return "IllegalArgumentException";
                } catch (InvocationTargetException e) {
                    return "InvocationTargetException";
                }
            } catch (NoSuchMethodException e) {
                return "SystemProperties.get(String key, String def) method is not found";
            }
        } catch (ClassNotFoundException e) {
            return "SystemProperties class is not found";
        }
    }

    public void loadNativeLibraries() {

        final BaseActivity self = this;

        String errorMsgBrokenLib = "";
        boolean brokenLibraries = false;
        try {
            for (String lib : getLibraries()) {
                System.loadLibrary(lib);
                log (lib + " is loaded");
            }
        } catch(UnsatisfiedLinkError e) {
            System.err.println(e.getMessage());
            brokenLibraries = true;
            errorMsgBrokenLib = e.getMessage();
        } catch(Exception e) {
            System.err.println(e.getMessage());
            brokenLibraries = true;
            errorMsgBrokenLib = e.getMessage();
        }

        if (brokenLibraries) {
            AlertDialog.Builder dlgAlert  = new AlertDialog.Builder(this);
            dlgAlert.setMessage("An error occurred while trying to start the application. Please try again and/or reinstall."
                    + System.getProperty("line.separator")
                    + System.getProperty("line.separator")
                    + "Error: " + errorMsgBrokenLib);
            dlgAlert.setTitle("MIX Error");
            dlgAlert.setPositiveButton("Exit",
                    new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int id) {
                            // if this button is clicked, close current activity
                            self.finish();
                        }
                    });
            dlgAlert.setCancelable(false);
            dlgAlert.create().show();

            return;
        }
    }
}
