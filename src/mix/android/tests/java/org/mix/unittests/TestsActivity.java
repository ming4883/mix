package org.mix.unittests;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.util.TypedValue;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

public class TestsActivity extends android.app.Activity {

    public static String TAG = "MIX";
    public static void log(String s) {
        Log.i(TAG, s);
    }
    public static void killThisProcess() {
        // wait for a while before killing
        try { Thread.sleep(200); } catch (InterruptedException e) {}
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    public class BaseView extends TextView {

        public BaseView(Context ctx) {
            super(ctx);
            log ("BaseView()");
            Typeface face = Typeface.MONOSPACE;
            setTypeface (face);
            setTextSize (TypedValue.COMPLEX_UNIT_MM, 2.0f);
            setHorizontallyScrolling (true);
            setHorizontalScrollBarEnabled (true);
            setHorizontalFadingEdgeEnabled (true);
            setMovementMethod (new ScrollingMovementMethod());
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

        handleExecute();
    }

    public native void handleExecute();

    public void appendLog(boolean iserror, String text) {
        m_view.append (text);
    }

    @Override
    protected void onDestroy() {
        log("onDestroy()");
        super.onDestroy();
        killThisProcess(); // cleanup any static objects in loaded dll
    }

	protected BaseView onCreateContentView() {
		return new BaseView(this);
	}

    protected String[] getLibraries() {
        return new String[] {
            "gnustl_shared",
            "mix_unit_tests"
        };
    }

    public void loadNativeLibraries() {

        final TestsActivity self = this;

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
