package org.mix.common;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.util.Log;
import android.view.Surface;
import android.view.Window;
import android.view.WindowManager;

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

        public static native void handleInit();
        public static native void handleUpdate();
        public static native void handleQuit();
        public static native void handleFrontendEvent(int evt, float param0, float param1);
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

            NativeCode.handleApplicationEvent (NativeApplicationEvent.WillEnterBackground.ordinal());
            m_nativeState = NativeState.Paused;
        }

        public synchronized void resume() {
            log ("nativeResume");

            if (m_nativeState != NativeState.Paused)
                return;

            NativeCode.handleApplicationEvent (NativeApplicationEvent.WillEnterForeground.ordinal());
            m_nativeState = NativeState.Running;
        }

        public synchronized void doFrame() {
            if (NativeState.Starting == m_nativeState) {
                handleInit();
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

        public BaseView(Context ctx) {
            super(ctx);
            log("BaseView()");
            setEGLContextClientVersion(2);
            setRenderer(this);
            setRenderMode(RENDERMODE_CONTINUOUSLY);

            nativeCode = new NativeCode();
            nativeCode.start();
        }

        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
            log("surfaceCreated() " + nativeCode.toString());
        }

        public void onSurfaceChanged(GL10 gl, int width, int height) {
            log("surfaceChanged(" + String.valueOf(width) + "," + String.valueOf(height) +")");
            NativeCode.handleFrontendEvent (NativeFrontendEvent.Resized.ordinal(), (float)width, (float)height);
        }

        public void onDrawFrame(GL10 gl) {
            nativeCode.doFrame();
        }
    }

    protected BaseView m_view;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
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
        NativeCode.handleApplicationEvent (NativeApplicationEvent.LowMemory.ordinal());
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
