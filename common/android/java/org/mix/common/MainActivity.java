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

public class MainActivity extends android.app.Activity {

    public static String TAG = "mix";
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

    public static class NativeCode
    {
        private NativeState m_nativeState = NativeState.None;

        public static native void handleInit(Object surface, int w, int h);
        public static native void handleUpdate(Object surface, int w, int h);
        public static native void handleQuit(Object surface, int w, int h);

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
            m_nativeState = NativeState.Stopping;
        }

        public synchronized void pause() {
            log ("nativePause");

            if (m_nativeState != NativeState.Running)
                return;

            m_nativeState = NativeState.Paused;
        }

        public synchronized void resume() {
            log ("nativeResume");

            if (m_nativeState != NativeState.Paused)
                return;

            m_nativeState = NativeState.Running;
        }

        public synchronized void doFrame(Surface surface, int width, int height) {
            if (NativeState.Starting == m_nativeState) {
                handleInit(surface, width, height);
                m_nativeState = NativeState.Running;
            }
            else if (NativeState.Running == m_nativeState) {
                handleUpdate(surface, width, height);
            }
            else if (NativeState.Stopping == m_nativeState) {
                handleQuit(surface, width, height);
                m_nativeState = NativeState.Stopped;
            }
        }
    }

    public class MainView extends GLSurfaceView implements GLSurfaceView.Renderer {

        private int m_surfaceWidth = -1;
        private int m_surfaceHeight = -1;

        public NativeCode nativeCode;

        public MainView(Context ctx) {
            super(ctx);
            log("MainView()");
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

            m_surfaceWidth = width;
            m_surfaceHeight = height;
        }

        public void onDrawFrame(GL10 gl) {
            nativeCode.doFrame(getHolder().getSurface(), m_surfaceWidth, m_surfaceHeight);
        }
    }

    MainView m_view;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        loadNativeLibraries();

        setContentView(m_view = new MainView(this));
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

    protected String[] getLibraries() {
        return new String[] {
            "gnustl_shared",
            "main"
        };
    }

    public void loadNativeLibraries() {

        final MainActivity self = this;

        String errorMsgBrokenLib = "";
        boolean brokenLibraries = false;
        try {
            for (String lib : getLibraries()) {
                System.loadLibrary(lib);
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
            dlgAlert.setTitle("BGFX Error");
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
